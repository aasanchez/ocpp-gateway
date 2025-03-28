defmodule OcppGatewayTest do
  use ExUnit.Case
  doctest OcppGateway

  test "greets the world" do
    assert OcppGateway.hello() == :world
  end
end
