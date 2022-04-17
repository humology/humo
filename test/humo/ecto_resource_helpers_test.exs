defmodule Humo.EctoResourceHelpersTest do
  use ExUnit.Case
  alias Humo.Warehouse
  alias Humo.EctoResourceHelpers
  doctest EctoResourceHelpers

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field :name, :string
    end

    defmodule Helpers do
      use Humo.EctoResourceHelpers
    end
  end

  test "module exists" do
    assert "users" = Warehouse.resource_helpers(User).name()
  end
end
