defmodule KafkaDispatcherTest do
  use ExUnit.Case
  doctest KafkaDispatcher

  setup do
    name = Module.concat(TestDispatcher, random_str())
    {:ok, name: name}
  end

  setup %{name: name} do
    opts = [
      name: name,
      topic: "my_topic",
      kafka: kafka_config()
    ]

    {:ok, _pid} = KafkaDispatcher.Supervisor.start_link(opts)

    :ok
  end

  test "It starts." do
    assert true
  end

  describe "dispatch/3" do
    test "It can dispatch and return offset", %{name: name} do
      assert {:ok, offset} = KafkaDispatcher.dispatch(name, "my_topic", "foo", "bar")
      assert is_integer(offset)
    end
  end

  defp random_str do
    Stream.repeatedly(fn ->
      Enum.random(?A..?Z)
    end)
    |> Stream.map(&<<&1>>)
    |> Stream.take(5)
    |> Enum.join()
  end

  defp kafka_config do
    [
      hosts: System.get_env("KAFKA_HOSTS", "localhost:9092"),
      client_config: [
        sasl: kafka_auth_config()
      ]
    ]
  end

  defp kafka_auth_config do
    case {System.get_env("KAFKA_AUTH_USER"), System.get_env("KAFKA_AUTH_PASS")} do
      {user, pass} when is_binary(user) and is_binary(pass) ->
        {:plain, user, pass}

      {nil, nil} ->
        :undefined
    end
  end
end
