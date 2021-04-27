defmodule ExcmsCore.EctoResourceHelpersTest do
  use ExUnit.Case
  alias ExcmsCore.Warehouse
  alias ExcmsCore.EctoResourceHelpers
  doctest EctoResourceHelpers

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field :name, :string
    end

    defmodule Helpers do
      use ExcmsCore.EctoResourceHelpers
    end
  end

  test "module exists" do
    assert "users" = Warehouse.to_resource_helpers(User).name()
  end
end
