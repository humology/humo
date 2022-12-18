defmodule Humo.WarehouseTest do
  use ExUnit.Case

  alias Humo.EctoResourceHelpers
  alias Humo.Warehouse
  doctest EctoResourceHelpers

  defmodule Page do
    use Ecto.Schema

    schema "humo_pages" do
      field :name, :string
    end

    defmodule Helpers do
      use Humo.EctoResourceHelpers
    end
  end

  describe "resources/0" do
    test "returns Page resource" do
      assert [Page] = Warehouse.resources()
    end
  end

  describe "resource_helpers/1" do
    test "returns schema name from provided resource" do
      assert "humo_pages" = Warehouse.resource_helpers(Page).name()
    end
  end

  describe "names_resources/0" do
    test "returns map of resource names to resource modules" do
      assert %{"humo_pages" => Page} = Warehouse.names_resources()
    end
  end

  describe "validate_config/0" do
    test "test config is valid" do
      assert :ok = Warehouse.validate_config()
    end
  end

  describe "validate_config/1" do
    test "helpers module could not be loaded" do
      defmodule Page0 do
      end

      assert_raise ArgumentError, fn ->
        Warehouse.validate_config(fn -> [app: [Page0]] end)
      end
    end

    test "name/0 is not exported" do
      defmodule Page1 do
        defmodule Helpers do
        end
      end

      expected_message = """
      Application: :app
      Humo.WarehouseTest.Page1.Helpers expected exported function name/0
      """

      assert_raise ArgumentError, expected_message, fn ->
        Warehouse.validate_config(fn -> [app: [Page1]] end)
      end
    end

    test "resource name expected to start with prefix \"app_\"" do
      defmodule Page2 do
        defmodule Helpers do
          def name, do: "pages"
        end
      end

      expected_message = """
      Application: :app
      Humo.WarehouseTest.Page2.Helpers.name() expected to start with "app_", actual: "pages"
      """

      assert_raise ArgumentError, expected_message, fn ->
        Warehouse.validate_config(fn -> [app: [Page2]] end)
      end
    end

    test "actions/0 is not exported" do
      defmodule Page3 do
        defmodule Helpers do
          def name, do: "app_pages"
        end
      end

      expected_message = """
      Application: :app
      Humo.WarehouseTest.Page3.Helpers expected exported function actions/0
      """

      assert_raise ArgumentError, expected_message, fn ->
        Warehouse.validate_config(fn -> [app: [Page3]] end)
      end
    end

    test "actions/0 cannot be empty" do
      defmodule Page4 do
        defmodule Helpers do
          def name, do: "app_pages"
          def actions, do: []
        end
      end

      expected_message = """
      Application: :app
      Humo.WarehouseTest.Page4.Helpers.actions() cannot be empty
      """

      assert_raise ArgumentError, expected_message, fn ->
        Warehouse.validate_config(fn -> [app: [Page4]] end)
      end
    end

    test "actions/0 action type is not binary" do
      defmodule Page5 do
        defmodule Helpers do
          def name, do: "app_pages"
          def actions, do: ["create", "read", :update]
        end
      end

      expected_message = """
      Application: :app
      Humo.WarehouseTest.Page5.Helpers action :update type expected to be binary
      """

      assert_raise ArgumentError, expected_message, fn ->
        Warehouse.validate_config(fn -> [app: [Page5]] end)
      end
    end

    test "validation passed" do
      defmodule Page6 do
        defmodule Helpers do
          def name, do: "app_pages"
          def actions, do: ["create"]
        end
      end

      assert :ok = Warehouse.validate_config(fn -> [app: [Page6]] end)
    end
  end
end
