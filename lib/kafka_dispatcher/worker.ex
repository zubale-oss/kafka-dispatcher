defmodule KafkaDispatcher.Worker do
  @moduledoc false

  use GenServer
  require Logger

  def start_link([{pool_size, options}]),
    do: GenServer.start_link(__MODULE__, {pool_size, options})

  @doc """
  Run a given function in a worker process.
  """
  @spec run(GenServer.server(), (pid() -> term())) :: term()
  def run(pid, f),
    do: GenServer.call(pid, {:run, f})

  @impl true
  def init({pool_size, options}) do
    case init_client(pool_size, options) do
      pid when is_pid(pid) ->
        {:ok, pid}

      _ ->
        {:error, :noclient}
    end
  end

  @impl true
  def handle_call({:run, f}, _from, state) when is_function(f, 1) do
    {:reply, f.(state), state}
  end

  defp init_client(pool_size, options) do
    kafka_hosts = hosts_config!(options)

    producer_config = Keyword.get(options, :producer_config, [])

    client_config =
      Keyword.get(options, :client_config, [])
      |> Keyword.put_new(:auto_start_producers, true)
      |> Keyword.put_new(:default_producer_config, producer_config)

    1..pool_size
    |> Enum.find_value(fn id ->
      case :brod.start_link_client(
             kafka_hosts,
             to_client_id(options[:pool_name], id),
             client_config
           ) do
        {:error, {:already_started, _pid}} ->
          nil

        {:ok, pid} ->
          pid
      end
    end)
  end

  defp to_client_id(pool_name, n) do
    Module.concat([pool_name, Worker, :"pub_client_#{n}"])
  end

  defp hosts_config!(config) do
    kafka_cfg = Keyword.get(config, :kafka, [])

    case Keyword.get(kafka_cfg, :hosts) do
      cfg when cfg in [nil, ""] ->
        Logger.error("""
          Kafka hosts is set as `#{inspect(cfg)}`. Please configure kafka hosts.
        """)

        raise "Invalid Kafka hosts"

      str ->
        str
        |> String.split(",")
        |> Enum.map(fn url ->
          %{host: host, port: port} = URI.parse("kafka://" <> url)
          {host, port}
        end)
    end
  end
end
