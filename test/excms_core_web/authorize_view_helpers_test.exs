defmodule ExcmsCoreWeb.AuthorizeViewHelpersTest do
  use ExcmsCoreWeb.ConnCase, async: true
  alias ExcmsCoreWeb.AuthorizeViewHelpers

  describe "can_link/3" do
    test "not existing link raises NoRouteError", %{conn: conn} do
      expected_message =
        "no route found for DELETE /not-exists (#{inspect ExcmsCoreWeb.router()})"
      assert_raise Phoenix.Router.NoRouteError, expected_message, fn ->
        opts = [to: "/not-exists", method: :delete]
        AuthorizeViewHelpers.can_link(conn, "Index", opts)
      end
    end
  end
end
