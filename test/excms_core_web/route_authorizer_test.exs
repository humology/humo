defmodule ExcmsCoreWeb.RouteAuthorizerTest do
  use ExcmsCoreWeb.ConnCase
  alias ExcmsCoreWeb.RouteAuthorizer

  describe "can_conn?/2" do
    test "not existing link raises NoRouteError", %{conn: conn} do
      expected_message =
        "no route found for DELETE /not-exists (#{inspect ExcmsCoreWeb.router()})"
      assert_raise Phoenix.Router.NoRouteError, expected_message, fn ->
        %{conn | request_path: "/not-exists", method: :delete}
        |> RouteAuthorizer.can_conn?()
      end
    end
  end

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
