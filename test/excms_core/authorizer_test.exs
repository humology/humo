defmodule ExcmsCore.AuthorizerTest do
  use ExcmsCore.DataCase, async: true
  alias ExcmsCore.Authorizer
  alias ExcmsCore.Authorizer.Mock
  alias ExcmsCore.Authorizer.AllAccess
  alias ExcmsCore.Authorizer.NoAccess

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

      def actions(), do: ~w(create read update delete publish)
    end
  end

  @actions ~w(create read update delete publish)

  describe "can?/3" do
    test "when no access, no record action available to user" do
      Mock.with_mock(fn ->
          for action <- @actions, do:
            refute Authorizer.can?(%User{}, action, %Page{})
        end,
        can_actions: &NoAccess.can_actions/2
      )
    end

    test "when no access, no module action available to user" do
      Mock.with_mock(fn ->
          for action <- @actions, do:
            refute Authorizer.can?(%User{}, action, Page)
        end,
        can_actions: &NoAccess.can_actions/2
      )
    end

    test "when all access, all record actions available to user" do
      Mock.with_mock(fn ->
          for action <- @actions, do:
            assert Authorizer.can?(%User{}, action, %Page{})
        end,
        can_actions: &AllAccess.can_actions/2
      )
    end

    test "when all access, all module actions available to user" do
      Mock.with_mock(fn ->
          for action <- @actions, do:
            assert Authorizer.can?(%User{}, action, Page)
        end,
        can_actions: &AllAccess.can_actions/2
      )
    end
  end

  describe "can_all/3" do
    setup do
      Repo.query!("CREATE TABLE pages(title TEXT);")

      :ok
    end

    test "when no access, no records available to user's action" do
      Repo.insert!(%Page{title: "Great News!"})

      Mock.with_mock(fn ->
          for action <- @actions, do:
            assert %User{}
                   |> Authorizer.can_all(action, Page)
                   |> Repo.all() == []
        end,
        can_all: &NoAccess.can_all/3
      )
    end

    test "when all access, all records available to user's action" do
      page = Repo.insert!(%Page{title: "Great News!"})

      Mock.with_mock(fn ->
          for action <- @actions, do:
            assert %User{}
                   |> Authorizer.can_all(action, Page)
                   |> Repo.all() == [page]
        end,
        can_all: &AllAccess.can_all/3
      )
    end
  end

  describe "can_actions/2" do
    test "when no access, no record action available to user" do
      Mock.with_mock(fn ->
          assert Authorizer.can_actions(%User{}, %Page{}) == []
        end,
        can_actions: &NoAccess.can_actions/2
      )
    end

    test "when no access, no module action available to user" do
      Mock.with_mock(fn ->
          assert Authorizer.can_actions(%User{}, Page) == []
        end,
        can_actions: &NoAccess.can_actions/2
      )
    end

    test "when all access, all record actions available to user" do
      Mock.with_mock(fn ->
          assert Authorizer.can_actions(%User{}, %Page{}) == @actions
        end,
        can_actions: &AllAccess.can_actions/2
      )
    end

    test "when all access, all module actions available to user" do
      Mock.with_mock(fn ->
          assert Authorizer.can_actions(%User{}, Page) == @actions
        end,
        can_actions: &AllAccess.can_actions/2
      )
    end
  end
end
