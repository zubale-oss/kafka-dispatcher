defmodule KafkaDispatcher.Supervisor do
  @moduledoc false

  alias KafkaDispatcher.Partition
  alias KafkaDispatcher.KafkaClient
  alias KafkaDispatcher.Options

  use Supervisor

  def start_link(options) do
    Options.validate!(options)

    Supervisor.start_link(__MODULE__, options)
  end

  @impl true
  def init(options) do
    name = Keyword.fetch!(options, :name)
    topic = Keyword.fetch!(options, :topic)
    pool_name = Options.pool_name(name)

    children = [
      {Registry, keys: :unique, name: Options.reg_name(name)},
      {KafkaClient, Keyword.put(options, :pool_name, pool_name)},
      {Partition, name: Options.partitioner_name(name), topic: topic, pool_name: pool_name}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
