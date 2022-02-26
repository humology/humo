defmodule ExcmsCoreWeb.RouteAuthorizerTest do
  use ExcmsCoreWeb.ConnCase,
    endpoint: ExcmsCoreWeb.RouteAuthorizerTest.TestWebEndpoint

  defmodule User do
    defstruct [is_admin: false]
  end

  defmodule Page do
    defstruct [id: nil, title: nil]

    defmodule Helpers do
      def actions(), do: ["read", "delete"]
    end
  end

  defmodule TestUserExtractor do
    def extract(conn) do
      conn.assigns[:active_user]
    end
  end

  defmodule SimpleAdminAuthorizer do
    use ExcmsCore.Authorizer.Behaviour

    def can_actions(%User{is_admin: true}, %Page{}), do: ["read", "delete"]

    def can_actions(%User{}, Page), do: ["read"]

    def can_actions(_user, _page), do: []
  end

  defmodule TestRouteAuthorizer do
    use ExcmsCoreWeb.RouteAuthorizer.Macro,
      lazy_router: &ExcmsCoreWeb.RouteAuthorizerTest.TestWeb.router/0,
      user_extractor: ExcmsCoreWeb.RouteAuthorizerTest.TestUserExtractor
  end

  defmodule TestWeb do
    def router(), do: ExcmsCoreWeb.RouteAuthorizerTest.TestWebRouter
  end

  defmodule TestWebPageController do
    def can?(user, phoenix_action, params) do
      case phoenix_action do
        :index -> SimpleAdminAuthorizer.can?(user, "read", Page)
        :show -> SimpleAdminAuthorizer.can?(user, "read", params.page)
        :delete -> SimpleAdminAuthorizer.can?(user, "delete", params.page)
      end
    end
  end

  defmodule TestWebRouter do
    use Phoenix.Router
    resources "/pages", TestWebPageController, only: [:index, :show, :delete]
  end

  defmodule TestWebEndpoint do
    use Phoenix.Endpoint, otp_app: :excms_core
    plug TestWebRouter
  end

  setup %{conn: conn} do
    %{
      admin_conn: assign(conn, :active_user, %User{is_admin: true}),
      user_conn: assign(conn, :active_user, %User{})
    }
  end

  describe "can_conn?/2" do
    test "admin user can read Page module", %{admin_conn: conn} do
      conn = Map.put(conn, :request_path, "/pages")
      assert TestRouteAuthorizer.can_conn?(conn)
    end

    test "regular user can read Page module", %{user_conn: conn} do
      conn = Map.put(conn, :request_path, "/pages")
      assert TestRouteAuthorizer.can_conn?(conn)
    end

    test "nil user cannot read Page module", %{conn: conn} do
      conn = Map.put(conn, :request_path, "/pages")
      refute TestRouteAuthorizer.can_conn?(conn)
    end

    test "admin user can read Page record", %{admin_conn: conn} do
      conn = Map.put(conn, :request_path, "/pages/3")
      assert TestRouteAuthorizer.can_conn?(conn, page: %Page{})
    end

    test "regular user can read Page record", %{user_conn: conn} do
      conn = Map.put(conn, :request_path, "/pages/3")
      refute TestRouteAuthorizer.can_conn?(conn, page: %Page{})
    end

    test "nil user cannot read Page record", %{conn: conn} do
      conn = Map.put(conn, :request_path, "/pages/3")
      refute TestRouteAuthorizer.can_conn?(conn, page: %Page{})
    end

    test "admin user can delete Page record", %{admin_conn: conn} do
      conn = Map.put(conn, :request_path, "/pages/3")
      params = [method: :delete, page: %Page{}]
      assert TestRouteAuthorizer.can_conn?(conn, params)
    end

    test "regular user cannot delete Page record", %{user_conn: conn} do
      conn = Map.put(conn, :request_path, "/pages/3")
      params = [method: :delete, page: %Page{}]
      refute TestRouteAuthorizer.can_conn?(conn, params)
    end

    test "nil user cannot delete Page record", %{conn: conn} do
      conn = Map.put(conn, :request_path, "/pages/3")
      params = [method: :delete, page: %Page{}]
      refute TestRouteAuthorizer.can_conn?(conn, params)
    end
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
      assert TestRouteAuthorizer.can_path?(conn, "/pages/3", page: %Page{})
    end

    test "regular user can read Page record", %{user_conn: conn} do
      refute TestRouteAuthorizer.can_path?(conn, "/pages/3", page: %Page{})
    end

    test "nil user cannot read Page record", %{conn: conn} do
      refute TestRouteAuthorizer.can_path?(conn, "/pages/3", page: %Page{})
    end

    test "admin user can delete Page record", %{admin_conn: conn} do
      params = [method: :delete, page: %Page{}]
      assert TestRouteAuthorizer.can_path?(conn, "/pages/3", params)
    end

    test "regular user cannot delete Page record", %{user_conn: conn} do
      params = [method: :delete, page: %Page{}]
      refute TestRouteAuthorizer.can_path?(conn, "/pages/3", params)
    end

    test "nil user cannot delete Page record", %{conn: conn} do
      params = [method: :delete, page: %Page{}]
      refute TestRouteAuthorizer.can_path?(conn, "/pages/3", params)
    end
  end
end
