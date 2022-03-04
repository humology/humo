defmodule ExcmsCoreWeb.AuthorizeViewHelpersBaseTest do
  use ExcmsCoreWeb.ConnCase
  use Phoenix.HTML

  defmodule TestRouteAuthorizer do
    def can_path?(_conn, "/can", [key: :value]), do: true
    def can_path?(_conn, "/can", [key: :value, method: :delete]), do: true
    def can_path?(_conn, "/cannot", [key: :value]), do: false
  end

  defmodule TestBase do
    use ExcmsCoreWeb.AuthorizeViewHelpersBase,
      route_authorizer: TestRouteAuthorizer
  end

  describe "can_link/3" do
    test "when text link pass authorization renders link", %{conn: conn} do
      opts = [to: "/can", can_params: [key: :value]]
      assert TestBase.can_link(conn, "Index", opts) ==
        link("Index", to: "/can")
    end

    test "when image link pass authorization renders link", %{conn: conn} do
      opts = [to: "/can", can_params: [key: :value]]
      assert TestBase.can_link(conn, opts, do: raw("<img/>")) ==
        link(raw("<img/>"), to: "/can")
    end

    test "when text link fail authorization renders link", %{conn: conn} do
      opts = [to: "/cannot", can_params: [key: :value]]
      assert TestBase.can_link(conn, "Index", opts) == ""
    end

    test "when image link fail authorization renders link", %{conn: conn} do
      opts = [to: "/cannot", can_params: [key: :value]]
      assert TestBase.can_link(conn, opts, do: raw("<img/>")) == ""
    end

    test "when delete link pass authorization renders link", %{conn: conn} do
      opts = [to: "/can", method: :delete, can_params: [key: :value]]
      assert TestBase.can_link(conn, "Index", opts) ==
        link("Index", to: "/can", method: :delete)
    end
  end
end
