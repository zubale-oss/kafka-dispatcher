defmodule KafkaDispatcher do
  @moduledoc """
  Documentation for `KafkaDispatcher`.
  """

  alias KafkaDispatcher.KafkaClient

  defdelegate dispatch(name, topic, key, payload), to: KafkaClient
end
