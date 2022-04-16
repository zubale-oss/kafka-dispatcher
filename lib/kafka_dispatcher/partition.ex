defmodule KafkaDispatcher.Partition do
  @moduledoc """
  This module caches the partition number of the Kafka topic.
  """
  alias KafkaDispatcher.KafkaClient

  use GenServer
  require Logger

  @default_interval Application.get_env(
                      :kafka_dispatcher,
                      :defualt_interval_for_getting_partition,
                      :timer.minutes(1)
                    )

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl GenServer
  def init(opts) do
    topic = Keyword.fetch!(opts, :topic)

    send(self(), :refresh)

    {:ok,
     %{
       options: opts,
       max_partition: 1,
       topic: topic
     }}
  end

  @impl GenServer
  def handle_info(:refresh, state) do
    max_partition = fetch_max_partition(state.topic, state.options)
    Process.send_after(self(), :refresh, interval(state.options))
    {:noreply, %{state | max_partition: max_partition}}
  end

  def fetch_max_partition(topic, opts) do
    pool_name = Keyword.fetch!(opts, :pool_name)

    KafkaClient.run(pool_name, fn client_id ->
      case :brod.get_partitions_count(client_id, topic) do
        {:ok, partitions} ->
          partitions

        {:error, reason} ->
          Logger.error(["Error getting Kafka partition count, reason: ", inspect(reason)])

          1
      end
    end)
  end

  defp interval(opts),
    do: Keyword.get(opts, :interval, @default_interval)

  @doc """
  Get max partition id
  """
  def max_partition(pid) do
    GenServer.call(pid, :get_max_partition)
  end

  @doc """
  Get a random partition number between 0 and max partition id
  """
  def random_partition(pid) do
    Enum.random(1..max_partition(pid)) - 1
  end

  @impl GenServer
  def handle_call(:get_max_partition, _from, state) do
    {:reply, state.max_partition, state}
  end
end
