defmodule ExcmsCoreWeb.RouteAuthorizerTest do
  use ExcmsCoreWeb.ConnCase
  alias ExcmsCoreWeb.RouteAuthorizer

  describe "can_path?/3" do
    test "not existing link raises NoRouteError", %{conn: conn} do
      expected_message =
        "no route found for DELETE /not-exists (#{inspect ExcmsCoreWeb.router()})"
      assert_raise Phoenix.Router.NoRouteError, expected_message, fn ->
        RouteAuthorizer.can_path?(conn, "/not-exists", [method: :delete])
      end
    end
  end
end
