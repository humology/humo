defmodule ExcmsCore.Authorizer.ReadAccessTest do
  use ExcmsCore.DataCase
  alias ExcmsCore.Authorizer.ReadAccess

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

  defmodule Log do
    defstruct []

    defmodule Helpers do
      use ExcmsCore.ResourceHelpers

      def actions(), do: ["create"]
    end
  end

  describe "can_all/3" do
    setup do
      Repo.query!("CREATE TABLE pages(title TEXT);")
      page = Repo.insert!(%Page{title: "Great News!"})

      %{page: page}
    end

    test "user can read all pages", %{page: page} do
      assert %User{}
             |> ReadAccess.can_all("read", Page)
             |> Repo.all() == [page]
    end

    test "user has no access to change pages" do
      for action <- ["create", "update", "delete", "publish"], do:
        assert %User{}
               |> ReadAccess.can_all(action, Page)
               |> Repo.all() == []
    end
  end

  describe "can_actions/2" do
    test "when resource record is given, returns Page read action" do
      assert ReadAccess.can_actions(%User{}, %Page{}) == ["read"]
    end

    test "when resource module is given, returns Page read action" do
      assert ReadAccess.can_actions(%User{}, Page) == ["read"]
    end

    test "when resource record is given, Log has no read action" do
      assert ReadAccess.can_actions(%User{}, %Log{}) == []
    end

    test "when resource module is given, Log has no read action" do
      assert ReadAccess.can_actions(%User{}, Log) == []
    end
  end
end
