defmodule ExcmsCore.Authorizer.AllAccessTest do
  use ExcmsCore.DataCase
  alias ExcmsCore.Authorizer.AllAccess

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
      use ExcmsCore.ResourceHelpers

      def actions(), do: ["create", "read", "update", "delete", "publish"]
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
    test "when resource record is given, returns all resource actions" do
      assert AllAccess.can_actions(%User{}, %Page{}) ==
             ["create", "read", "update", "delete", "publish"]
    end

    test "when resource module is given, returns all resource actions" do
      assert AllAccess.can_actions(%User{}, Page) ==
             ["create", "read", "update", "delete", "publish"]
    end
  end
end
