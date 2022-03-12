defmodule ExcmsCore.Authorizer.BehaviourTest do
  use ExcmsCore.DataCase

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field :is_admin, :boolean, default: false
    end
  end

  defmodule Page do
    use Ecto.Schema

    schema "pages" do
      field :title, :string
      field :published, :boolean, default: false
      belongs_to :owner, User
    end

    defmodule Helpers do
      use ExcmsCore.ResourceHelpers

      def actions(), do: ["create", "read", "update", "delete", "publish", "unpublish"]
    end
  end

  defmodule SimpleAdminAuthorizer do
    use ExcmsCore.Authorizer.Behaviour
    alias ExcmsCore.Repo

    @moduledoc """
    Admin User can do all actions.
    Regular User can:
    - read all owned or published pages
    - change owned pages
    - cannot change published page
    - has possibility to do all actions
    """

    @impl true
    def can_all(%User{is_admin: true}, _action, Page) do
      Page
    end

    def can_all(%User{id: user_id}, "read", Page) do
      from p in Page,
        where: p.owner_id == ^user_id or p.published
    end

    def can_all(%User{id: user_id}, _action, Page) do
      from p in Page,
        where: p.owner_id == ^user_id,
        where: not(p.published)
    end

    @impl true
    def can_actions(%User{is_admin: true}, %Page{}) do
      resource_actions(Page)
    end

    def can_actions(
          %User{id: user_id},
          %Page{id: page_id, owner_id: user_id, published: false}
        ) when not is_nil(page_id) do
      ["read", "update", "delete", "publish"]
    end

    def can_actions(%User{id: user_id}, %Page{id: nil, owner_id: user_id}) do
      ["create"]
    end

    def can_actions(_user, %Page{published: true}) do
      ["read"]
    end

    def can_actions(_user, %Page{}) do
      []
    end

    def can_actions(%User{is_admin: true}, Page) do
      resource_actions(Page)
    end

    def can_actions(_user, Page) do
      resource_actions(Page) -- ["unpublish"]
    end
  end

  defp can?(authorization, action, resource_or_module) do
    SimpleAdminAuthorizer.can?(authorization, action, resource_or_module)
  end

  defp can_all(authorization, action, resource_module) do
    SimpleAdminAuthorizer.can_all(authorization, action, resource_module)
  end

  defp can_actions(authorization, resource_or_module) do
    SimpleAdminAuthorizer.can_actions(authorization, resource_or_module)
  end

  describe "can?/3" do
    test "when user is admin, user can do all resource actions" do
      for action <- ~w(create read update delete publish unpublish), do:
        assert can?(%User{is_admin: true}, action, %Page{})
    end

    test "when user owns draft page, user can read and change" do
      for action <- ~w(create read update delete publish), do:
        assert can?(
                 %User{id: 5},
                 action,
                 %Page{id: 1, owner_id: 5, published: false}
               ) == (action != "create")
    end

    test "when page is new, user can create it" do
      for action <- ~w(create read update delete publish), do:
        assert can?(
                 %User{id: 5},
                 action,
                 %Page{id: nil, owner_id: 5, published: false}
               ) == (action == "create")
    end

    test "when user doesn't own published page, user can read it" do
      for action <- ~w(create read update delete publish), do:
        assert can?(
                 %User{id: 5},
                 action,
                 %Page{id: 1, owner_id: 7, published: true}
               ) == (action == "read")
    end

    test "when user doesn't own draft page, no action is available" do
      for action <- ~w(create read update delete publish), do:
        refute can?(
                 %User{id: 5},
                 action,
                 %Page{id: 1, owner_id: 7, published: false}
               )
    end

    test "admin can unpublish page" do
      for action <- ~w(create read update delete publish unpublish), do:
        assert can?(%User{is_admin: true}, action, Page)
    end

    test "user cannot unpublish page" do
      for action <- ~w(create read update delete publish unpublish), do:
        assert can?(%User{is_admin: false}, action, Page) ==
               (action != "unpublish")
    end
  end

  describe "can_all/3" do
    setup do
      """
      CREATE TABLE users(
        id SERIAL,
        is_admin BOOLEAN
      );
      """ |> Repo.query!()

      """
      CREATE TABLE pages(
        id SERIAL,
        title TEXT,
        published BOOLEAN,
        owner_id INTEGER
      );
      """ |> Repo.query!()

      admin = Repo.insert!(%User{is_admin: true})
      user1 = Repo.insert!(%User{is_admin: false})
      user2 = Repo.insert!(%User{is_admin: false})

      user1_published_page =
        %Page{
          title: "Greetings from User1",
          owner: user1,
          published: true
        } |> Repo.insert!()

      user1_draft_page =
        %Page{
          title: "Draft page from User1",
          owner: user1,
          published: false
        } |> Repo.insert!()

      user2_published_page =
        %Page{
          title: "Greetings from User2",
          owner: user2,
          published: true
        } |> Repo.insert!()

      user2_draft_page =
        %Page{
          title: "Draft page from User2",
          owner: user2,
          published: false
        } |> Repo.insert!()

      %{
        admin: admin,
        user1: user1,
        user2: user2,
        user1_published_page: user1_published_page,
        user1_draft_page: user1_draft_page,
        user2_published_page: user2_published_page,
        user2_draft_page: user2_draft_page
      }
    end

    test "when user is admin, returns all pages for all actions", params do
      for action <- ["create", "read", "update", "delete", "publish"], do:
        assert params.admin
               |> can_all(action, Page)
               |> Repo.all()
               |> Repo.preload(:owner) ==
                  [
                    params.user1_published_page,
                    params.user1_draft_page,
                    params.user2_published_page,
                    params.user2_draft_page
                  ]
    end

    test "when read action, returns published or user owned pages", params do
      assert params.user1
             |> can_all("read", Page)
             |> Repo.all()
             |> Repo.preload(:owner) ==
                [
                  params.user1_published_page,
                  params.user1_draft_page,
                  params.user2_published_page
                ]
    end

    test "when change action, returns user owned draft pages", params do
      for action <- ["update", "delete", "publish"], do:
        assert params.user1
               |> can_all(action, Page)
               |> Repo.all()
               |> Repo.preload(:owner) == [params.user1_draft_page]
    end
  end

  describe "can_actions/2" do
    test "when user is admin, returns all resource actions" do
      assert can_actions(%User{is_admin: true}, %Page{}) ==
             ["create", "read", "update", "delete", "publish", "unpublish"]
    end

    test "when user owns draft page, returns read and change actions" do
      assert can_actions(
               %User{id: 5},
               %Page{id: 1, owner_id: 5, published: false}
             ) == ["read", "update", "delete", "publish"]
    end

    test "when page is new, user can create it" do
      assert can_actions(
               %User{id: 5},
               %Page{id: nil, owner_id: 5, published: false}
             ) == ["create"]
    end

    test "when user doesn't own published page, user can read it" do
      assert can_actions(
               %User{id: 5},
               %Page{id: 1, owner_id: 7, published: true}
             ) == ["read"]
    end

    test "when user doesn't own draft page, user cannot read it" do
      assert can_actions(
               %User{id: 5},
               %Page{id: 1, owner_id: 7, published: false}
             ) == []
    end

    test "admin can do all actions" do
      assert can_actions(%User{is_admin: true}, Page) ==
             ["create", "read", "update", "delete", "publish", "unpublish"]
    end

    test "user cannot unpublish" do
      assert can_actions(%User{is_admin: false}, Page) ==
             ["create", "read", "update", "delete", "publish"]
    end
  end
end
