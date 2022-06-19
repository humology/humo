defmodule HumoWeb.AuthorizeViewHelpersTest do
  use HumoWeb.ConnCase, async: true
  alias HumoWeb.AuthorizeViewHelpers

  describe "can_link/3" do
    test "not existing link raises NoRouteError", %{conn: conn} do
      expected_message = "no route found for DELETE /not-exists (#{inspect(HumoWeb.router())})"

      assert_raise Phoenix.Router.NoRouteError, expected_message, fn ->
        opts = [to: "/not-exists", method: :delete]
        AuthorizeViewHelpers.can_link(conn, "Index", opts)
      end
    end
  end
end
