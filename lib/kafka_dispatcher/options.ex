defmodule KafkaDispatcher.Options do
  def validate!(opts) do
    ensure_option!(opts, :name, """
      `:name` option is required
    """)

    ensure_option!(opts, :topic, """
      `:topic` option is required
    """)

    ensure_option!(opts, :kafka, """
      `:kafka` option is required
    """)

    ensure_option!(opts[:kafka], :hosts, """
      `:hosts` option is required in Kafka configuration
    """)
  end

  defp ensure_option!(opts, key, err_msg) do
    Keyword.get(opts, key) || raise err_msg
  end

  def reg_name(name),
    do: Module.concat(name, Registry)

  def pool_name(name),
    do: Module.concat(name, ConnPool)

  def partitioner_name(name),
    do: Module.concat(name, PartitionAgent)
end
