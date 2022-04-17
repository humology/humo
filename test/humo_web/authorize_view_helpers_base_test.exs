defmodule HumoWeb.AuthorizeViewHelpersBaseTest do
  use HumoWeb.ConnCase, async: true
  use Phoenix.HTML

  defmodule TestRouteAuthorizer do
    def can_path?(conn, path, method \\ :get)
    def can_path?(_conn, "/can", :get), do: true
    def can_path?(_conn, "/can", :delete), do: true
    def can_path?(_conn, "/cannot", :get), do: false
  end

  defmodule TestBase do
    use HumoWeb.AuthorizeViewHelpersBase,
      route_authorizer: TestRouteAuthorizer
  end

  describe "can_link/3" do
    test "when text link pass authorization renders link", %{conn: conn} do
      assert TestBase.can_link(conn, "Index", to: "/can") ==
        link("Index", to: "/can")
    end

    test "when image link pass authorization renders link", %{conn: conn} do
      assert TestBase.can_link(conn, [to: "/can"], do: raw("<img/>")) ==
        link(raw("<img/>"), to: "/can")
    end

    test "when text link fail authorization renders link", %{conn: conn} do
      assert TestBase.can_link(conn, "Index", to: "/cannot") == ""
    end

    test "when image link fail authorization renders link", %{conn: conn} do
      assert TestBase.can_link(conn, [to: "/cannot"], do: raw("<img/>")) == ""
    end

    test "when delete link pass authorization renders link", %{conn: conn} do
      assert TestBase.can_link(conn, "Index", to: "/can", method: :delete) ==
        link("Index", to: "/can", method: :delete)
    end
  end
end
