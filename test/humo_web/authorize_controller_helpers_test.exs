defmodule HumoWeb.AuthorizeControllerHelpersTest do
  use HumoWeb.ConnCase, async: true
  use RouterHelper

  defmodule User do
    defstruct [is_admin: false]
  end

  defmodule Page do
    defstruct [id: nil]

    defmodule Helpers do
      def actions(), do: ["create", "read", "update", "delete", "publish"]
    end
  end

  defmodule SimpleAdminAuthorizer do
    use Humo.Authorizer.Behaviour

    def can_all(_, _, _), do: raise "Not tested"

    def can_actions(%User{is_admin: true}, _page), do:
      ["create", "read", "update", "delete", "publish"]

    def can_actions(%User{}, Page), do: ["create"]

    def can_actions(%User{}, {:list, Page}), do: ["read"]

    def can_actions(_user, _page), do: []
  end

  defmodule AuthorizationExtractor do
    @behaviour HumoWeb.AuthorizationExtractor.Behaviour

    def extract(conn) do
      conn.assigns[:active_user]
    end
  end

  defmodule PageController do
    use HumoWeb, :controller

    plug :assign_page when action in [:show, :edit, :update, :delete]

    use HumoWeb.AuthorizeControllerHelpers,
      resource_module: Page,
      resource_assign_key: :page,
      authorizer: SimpleAdminAuthorizer,
      authorization_extractor: AuthorizationExtractor

    def index(conn, _params), do: send_resp(conn, 200, "OK")
    def show(conn, _params), do: send_resp(conn, 200, "OK")
    def new(conn, _params), do: send_resp(conn, 200, "OK")
    def create(conn, _params), do: send_resp(conn, 200, "OK")
    def edit(conn, _params), do: send_resp(conn, 200, "OK")
    def update(conn, _params), do: send_resp(conn, 200, "OK")
    def delete(conn, _params), do: send_resp(conn, 200, "OK")

    defp assign_page(conn, _opts) do
      assign(conn, :page, %Page{id: Map.fetch!(conn.params, "id")})
    end
  end

  defmodule PagePublishController do
    use HumoWeb, :controller

    plug :assign_page

    use HumoWeb.AuthorizeControllerHelpers,
      resource_module: Page,
      resource_assign_key: :page,
      authorizer: SimpleAdminAuthorizer,
      authorization_extractor: AuthorizationExtractor

    def required_permissions(:publish, %{page: page}), do:
      [{"publish", page}, {"publish", Page}]

    def publish(conn, _params), do: send_resp(conn, 200, "OK")

    defp assign_page(conn, _opts) do
      assign(conn, :page, %Page{id: Map.fetch!(conn.params, "id")})
    end
  end

  defmodule Router do
    use Phoenix.Router

    resources "/pages", PageController
    Phoenix.Router.post "/pages/:id/publish", PagePublishController, :publish
  end

  setup do
    %{
      admin_assigns: [active_user: %User{is_admin: true}],
      user_assigns: [active_user: %User{}],
      page: %Page{id: 5}
    }
  end

  describe "authorize/2" do
    test "admin can do all actions", %{admin_assigns: admin_assigns} do
      assert call(Router, :get, "/pages", admin_assigns).status == 200
      assert call(Router, :get, "/pages/5", admin_assigns).status == 200
      assert call(Router, :get, "/pages/new", admin_assigns).status == 200
      assert call(Router, :post, "/pages", admin_assigns).status == 200
      assert call(Router, :get, "/pages/5/edit", admin_assigns).status == 200
      for method <- [:patch, :put], do:
        assert call(Router, method, "/pages/5", admin_assigns).status == 200
      assert call(Router, :delete, "/pages/5", admin_assigns).status == 200
      assert call(Router, :post, "/pages/5/publish", admin_assigns).status == 200
    end

    test "user can do Page module actions, but not record actions",
        %{user_assigns: user_assigns} do
      assert call(Router, :get, "/pages", user_assigns).status == 200
      assert call(Router, :get, "/pages/5", user_assigns).status == 403
      assert call(Router, :get, "/pages/new", user_assigns).status == 200
      assert call(Router, :post, "/pages", user_assigns).status == 200
      assert call(Router, :get, "/pages/5/edit", user_assigns).status == 403
      for method <- [:patch, :put], do:
        assert call(Router, method, "/pages/5", user_assigns).status == 403
      assert call(Router, :delete, "/pages/5", user_assigns).status == 403
      assert call(Router, :post, "/pages/5/publish", user_assigns).status == 403
    end

    test "guest cannot do any action" do
      assert call(Router, :get, "/pages").status == 403
      assert call(Router, :get, "/pages/5").status == 403
      assert call(Router, :get, "/pages/new").status == 403
      assert call(Router, :post, "/pages").status == 403
      assert call(Router, :get, "/pages/5/edit").status == 403
      for method <- [:patch, :put], do:
        assert call(Router, method, "/pages/5").status == 403
      assert call(Router, :delete, "/pages/5").status == 403
      assert call(Router, :post, "/pages/5/publish").status == 403
    end
  end

  describe "required_permissions/2" do
    test "index" do
      assert PageController.required_permissions(:index, %{}) ==
        {"read", {:list, Page}}
    end

    test "show", %{page: page} do
      assert PageController.required_permissions(:show, %{page: page}) ==
        {"read", page}
    end

    test "new" do
      assert PageController.required_permissions(:new, %{}) ==
        {"create", Page}
    end

    test "create" do
      assert PageController.required_permissions(:create, %{}) ==
        {"create", Page}
    end

    test "edit", %{page: page} do
      assert PageController.required_permissions(:edit, %{page: page}) ==
        {"update", page}
    end

    test "update", %{page: page} do
      assert PageController.required_permissions(:update, %{page: page}) ==
        {"update", page}
    end

    test "delete", %{page: page} do
      assert PageController.required_permissions(:delete, %{page: page}) ==
        {"delete", page}
    end

    test "publish", %{page: page} do
      assert PagePublishController.required_permissions(:publish, %{page: page}) ==
        [{"publish", page}, {"publish", Page}]
    end
  end

  describe "Macro required variables" do
    test "requires resource_module" do
      assert_raise RuntimeError, ":resource_module is expected to be given", fn ->
        defmodule TestController do
          use HumoWeb.AuthorizeControllerHelpers
        end
      end
    end

    test "requires resource_assign_key" do
      assert_raise RuntimeError, ":resource_assign_key is expected to be given", fn ->
        defmodule TestController do
          use HumoWeb.AuthorizeControllerHelpers,
            resource_module: Page
        end
      end
    end
  end
end
