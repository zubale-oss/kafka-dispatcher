defmodule KafkaDispatcher.KafkaClient do
  @moduledoc false

  @default_pool_size 10

  alias KafkaDispatcher.Options
  alias KafkaDispatcher.Partition
  alias KafkaDispatcher.Worker

  require Logger

  @spec dispatch(atom(), binary(), binary(), binary()) ::
          {:ok, offset :: non_neg_integer()} | {:error, any()}
  def dispatch(name, topic, key, payload) do
    Logger.debug(["--> Dispatching event to Kafka: ", inspect(payload)])

    pool_name = Options.pool_name(name)
    partition = partition(name)

    run(pool_name, fn client_pid ->
      :brod.produce_sync_offset(
        client_pid,
        topic,
        partition,
        key,
        payload
      )
    end)
  end

  defp partition(name),
    do: Partition.random_partition(Options.partitioner_name(name))

  def child_spec(options) do
    pool_size = Keyword.get(options, :pool_size, @default_pool_size)
    pool_name = Keyword.fetch!(options, :pool_name)

    worker_init_arg = [{pool_size, options}]

    :poolboy.child_spec(
      pool_name,
      [
        name: {:local, pool_name},
        worker_module: Worker,
        size: pool_size,
        max_overflow: 0
      ],
      worker_init_arg
    )
  end

  @doc """
  Checkout a client and run the given function in
  that client process.
  """
  @spec run(atom(), (pid -> term())) :: term()
  def run(pool_name, f) do
    :poolboy.transaction(pool_name, fn worker_pid ->
      Worker.run(worker_pid, f)
    end)
  end
end
