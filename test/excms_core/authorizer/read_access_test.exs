defmodule ExcmsCore.Authorizer.ReadAccessTest do
  use ExcmsCore.DataCase, async: true
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

  describe "can?/3" do
    test "when %Page{} with read action is given, returns true" do
      assert ReadAccess.can?(%User{}, "read", %Page{})
    end

    test "when %Page{} with action != read is given, returns false" do
      for action <- ["create", "update", "delete", "publish"], do:
        refute ReadAccess.can?(%User{}, action, %Page{})
    end

    test "when {:list, Page} with read action is given, returns true" do
      assert ReadAccess.can?(%User{}, "read", {:list, Page})
    end

    test "when {:list, Page} with action != read is given, returns false" do
      for action <- ["create", "update", "delete", "publish"], do:
        refute ReadAccess.can?(%User{}, action, {:list, Page})
    end

    test "when Page with read action is given, returns true" do
      ReadAccess.can?(%User{}, "read", Page)
    end

    test "when Page with action != read is given, returns true, otherwise false" do
      for action <- ["create", "update", "delete", "publish"], do:
        refute ReadAccess.can?(%User{}, action, Page)
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
    test "when %Page{} is given, returns read action" do
      assert ReadAccess.can_actions(%User{}, %Page{}) == ["read"]
    end

    test "when {:list, Page} is given, returns read action" do
      assert ReadAccess.can_actions(%User{}, Page) == ["read"]
    end

    test "when Page is given, returns read action" do
      assert ReadAccess.can_actions(%User{}, Page) == ["read"]
    end

    test "when %Log{} doesn't support read, returns no action" do
      assert ReadAccess.can_actions(%User{}, %Log{}) == []
    end

    test "when {:list, Log} doesn't support read, returns no action" do
      assert ReadAccess.can_actions(%User{}, {:list, Log}) == []
    end

    test "when Log doesn't support read, returns no action" do
      assert ReadAccess.can_actions(%User{}, Log) == []
    end
  end
end
