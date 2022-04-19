# Kafka Dispatcher

A simple group of reusable modules for dispatching data into a Kafka instance.

Features:

* automatic partitioning
* connection pooling

## Installation

```elixir
def deps do
  [
    {:kafka_dispatcher, gitub: "zubale-oss/kafka-dispatcher"}
  ]
end
```

## Configuration

```elixir
# file: lib/my_app/application.ex
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ...
      {KafkaDispatcher.Supervisor, kafka_dispatcher_config()},
      ...
    ]

    opts = [strategy: :one_for_one, name: BatchingService.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp kafka_dispatcher_config do
    [
      kafka: [
        hosts: "localhost:9092",
        client_config: [
          sasl: :undefined
          # # or:
          # sasal: {:plain, "username", "secret"}
        ]
      ]
    ]
  end
end
```
