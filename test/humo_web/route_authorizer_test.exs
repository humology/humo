defmodule HumoWeb.RouteAuthorizerTest do
  use HumoWeb.ConnCase, async: true
  alias HumoWeb.RouteAuthorizer

  describe "can_path?/3" do
    test "not existing link raises NoRouteError", %{conn: conn} do
      expected_message =
        "no route found for DELETE /not-exists (#{inspect HumoWeb.router()})"
      assert_raise Phoenix.Router.NoRouteError, expected_message, fn ->
        RouteAuthorizer.can_path?(conn, "/not-exists", :delete)
      end
    end
  end
end
