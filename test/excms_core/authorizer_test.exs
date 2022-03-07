defmodule ExcmsCore.AuthorizerTest do
  use ExcmsCore.DataCase
  alias ExcmsCore.Authorizer

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

  describe "can?/3" do
    test "when resource record is given, no action available to user" do
      for action <- ["create", "read", "update", "delete", "publish"], do:
        refute Authorizer.can?(%User{}, action, %Page{}) == []
    end

    test "when resource module is given, no action available to user" do
      for action <- ["create", "read", "update", "delete", "publish"], do:
        refute Authorizer.can?(%User{}, action, Page) == []
    end
  end

  describe "can_all/3" do
    setup do
      Repo.query!("CREATE TABLE pages(title TEXT);")

      :ok
    end

    test "no page available to user's action" do
      Repo.insert!(%Page{title: "Great News!"})

      for action <- ["create", "read", "update", "delete", "publish"], do:
        assert %User{}
               |> Authorizer.can_all(action, Page)
               |> Repo.all() == []
    end
  end

  describe "can_actions/2" do
    test "when resource record is given, no action available to user" do
      assert Authorizer.can_actions(%User{}, %Page{}) == []
    end

    test "when resource module is given, no action available to user" do
      assert Authorizer.can_actions(%User{}, Page) == []
    end
  end
end
