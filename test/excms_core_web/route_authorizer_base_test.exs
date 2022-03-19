defmodule ExcmsCoreWeb.RouteAuthorizerBaseTest do
  use ExcmsCoreWeb.ConnCase, async: true

  defmodule User do
    defstruct [is_admin: false]
  end

  defmodule Page do
    defstruct [id: nil, title: nil]

    defmodule Helpers do
      def actions(), do: ["read", "delete"]
    end
  end

  defmodule AuthorizationExtractor do
    @behaviour ExcmsCoreWeb.AuthorizationExtractor.Behaviour

    def extract(conn) do
      conn.assigns[:active_user]
    end
  end

  defmodule SimpleAdminAuthorizer do
    use ExcmsCore.Authorizer.Behaviour

    def can_all(_, _, _), do: raise "Not tested"

    def can_actions(%User{is_admin: true}, %Page{}), do: ["read", "delete"]

    def can_actions(%User{}, {:list, Page}), do: ["read"]

    def can_actions(_user, _page), do: []
  end

  defmodule PageController do
    use ExcmsCoreWeb, :controller

    use ExcmsCoreWeb.AuthorizeControllerHelpers,
      resource_module: Page,
      resource_assign_key: :page,
      authorizer: SimpleAdminAuthorizer,
      authorization_extractor: AuthorizationExtractor

    def required_permissions(phoenix_action, params) do
      case phoenix_action do
        :index -> {"read", {:list, Page}}
        :show -> {"read", params.page}
      end
    end
  end

  defmodule PageDeleteController do
    use ExcmsCoreWeb, :controller

    use ExcmsCoreWeb.AuthorizeControllerHelpers,
      resource_module: Page,
      resource_assign_key: :page,
      authorizer: SimpleAdminAuthorizer,
      authorization_extractor: AuthorizationExtractor

    def required_permissions(phoenix_action, params) do
      case phoenix_action do
        :delete -> {"delete", params.page}
      end
    end
  end

  defmodule TestWebRouter do
    use Phoenix.Router
    resources "/pages", PageController, only: [:index, :show]
    resources "/pages-del", PageDeleteController, only: [:delete]
  end

  defmodule TestWebEndpoint do
    use Phoenix.Endpoint, otp_app: :excms_core
    plug TestWebRouter
  end

  defmodule TestWeb do
    def router(), do: TestWebRouter
  end

  defmodule TestRouteAuthorizer do
    use ExcmsCoreWeb.RouteAuthorizerBase,
      lazy_web_router: &TestWeb.router/0
  end

  setup %{conn: conn} do
    %{
      admin_conn: assign(conn, :active_user, %User{is_admin: true}),
      user_conn: assign(conn, :active_user, %User{})
    }
  end

  describe "can_path?/3" do
    test "admin user can read Page module", %{admin_conn: conn} do
      assert TestRouteAuthorizer.can_path?(conn, "/pages")
    end

    test "regular user can read Page module", %{user_conn: conn} do
      assert TestRouteAuthorizer.can_path?(conn, "/pages")
    end

    test "nil user cannot read Page module", %{conn: conn} do
      refute TestRouteAuthorizer.can_path?(conn, "/pages")
    end

    test "admin user can read Page record", %{admin_conn: conn} do
      conn = assign(conn, :page, %Page{})
      assert TestRouteAuthorizer.can_path?(conn, "/pages/3")
    end

    test "regular user can read Page record", %{user_conn: conn} do
      conn = assign(conn, :page, %Page{})
      refute TestRouteAuthorizer.can_path?(conn, "/pages/3")
    end

    test "nil user cannot read Page record", %{conn: conn} do
      conn = assign(conn, :page, %Page{})
      refute TestRouteAuthorizer.can_path?(conn, "/pages/3")
    end

    test "admin user can delete Page record", %{admin_conn: conn} do
      conn = assign(conn, :page, %Page{})
      assert TestRouteAuthorizer.can_path?(conn, "/pages-del/3", :delete)
    end

    test "regular user cannot delete Page record", %{user_conn: conn} do
      conn = assign(conn, :page, %Page{})
      refute TestRouteAuthorizer.can_path?(conn, "/pages-del/3", :delete)
    end

    test "nil user cannot delete Page record", %{conn: conn} do
      conn = assign(conn, :page, %Page{})
      refute TestRouteAuthorizer.can_path?(conn, "/pages-del/3", :delete)
    end

    test "not existing link raises NoRouteError", %{conn: conn} do
      expected_message =
        "no route found for DELETE /not-exists (#{inspect TestWebRouter})"
      assert_raise Phoenix.Router.NoRouteError, expected_message, fn ->
        TestRouteAuthorizer.can_path?(conn, "/not-exists", :delete)
      end
    end
  end
end
