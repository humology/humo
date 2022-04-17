defmodule Humo.Authorizer.AllAccessTest do
  use Humo.DataCase, async: true
  alias Humo.Authorizer.AllAccess

  defmodule User do
    defstruct []
  end

  defmodule Page do
    use Ecto.Schema

    @primary_key false
    schema "pages" do
      field :title, :string
    end

    defmodule Helpers do
      use Humo.ResourceHelpers

      def actions(), do: ["create", "read", "update", "delete", "publish"]
    end
  end

  describe "can?/3" do
    test "when %Page{} with any action is given, returns false" do
      for action <- ["create", "read", "update", "delete", "publish"], do:
        assert AllAccess.can?(%User{}, action, %Page{})
    end

    test "when {:list, Page} with any action is given, returns false" do
      for action <- ["create", "read", "update", "delete", "publish"], do:
        assert AllAccess.can?(%User{}, action, {:list, Page})
    end

    test "when Page with any action is given, returns false" do
      for action <- ["create", "read", "update", "delete", "publish"], do:
        assert AllAccess.can?(%User{}, action, Page)
    end
  end

  describe "can_all/3" do
    setup do
      Repo.query!("CREATE TABLE pages(title TEXT);")

      :ok
    end

    test "all pages available to user's all actions" do
      page = Repo.insert!(%Page{title: "Great News!"})

      for action <- ["create", "read", "update", "delete", "publish"], do:
        assert %User{}
               |> AllAccess.can_all(action, Page)
               |> Repo.all() == [page]
    end
  end

  describe "can_actions/2" do
    test "when %Page{} is given, returns all resource actions" do
      assert AllAccess.can_actions(%User{}, %Page{}) ==
             ["create", "read", "update", "delete", "publish"]
    end

    test "when {:list, Page} is given, returns all resource actions" do
      assert AllAccess.can_actions(%User{}, {:list, Page}) ==
             ["create", "read", "update", "delete", "publish"]
    end

    test "when Page is given, returns all resource actions" do
      assert AllAccess.can_actions(%User{}, Page) ==
             ["create", "read", "update", "delete", "publish"]
    end
  end
end
