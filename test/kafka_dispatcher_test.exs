defmodule KafkaDispatcherTest do
  use ExUnit.Case
  doctest KafkaDispatcher

  test "greets the world" do
    assert KafkaDispatcher.hello() == :world
  end
end
