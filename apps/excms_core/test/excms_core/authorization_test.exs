defmodule ExcmsCore.AuthorizationTest do
  use ExUnit.Case

  alias ExcmsCore.Authorization
  alias ExcmsCore.Permission
  doctest Authorization

  defmodule Page do
    defmodule Helpers do
      use ExcmsCore.ResourceHelpers

      def name(), do: "page"

      def actions(), do: ["create", "read", "update", "delete", "publish"]

      def access_levels("publish"), do: ["no", "own", "team", "all"]
      def access_levels(_), do: ["no", "all"]
    end
  end

  describe "union" do
    test "is_administrator" do
      assert %Authorization{is_administrator: false} =
               Authorization.union([
                 %Authorization{is_administrator: false},
                 %Authorization{is_administrator: false}
               ])

      assert %Authorization{is_administrator: true} =
               Authorization.union([
                 %Authorization{is_administrator: true},
                 %Authorization{is_administrator: false}
               ])
    end

    test "permissions" do
      actual =
        Authorization.union([
          %Authorization{
            permissions: [
              Permission.new(Page, "publish", "own"),
              Permission.new(Page, "create", "all")
            ]
          },
          %Authorization{
            permissions: [
              Permission.new(Page, "publish", "team"),
              Permission.new(Page, "update", "all")
            ]
          }
        ])

      assert 3 = length(actual.permissions)
      assert Permission.new(Page, "publish", "team") in actual.permissions
      assert Permission.new(Page, "create", "all") in actual.permissions
      assert Permission.new(Page, "update", "all") in actual.permissions
    end
  end

  describe "permitted?" do
    test "is_administrator" do
      auth = %Authorization{is_administrator: true}

      assert Authorization.permitted?(auth, [
               Permission.new(Page, "publish", "team"),
               Permission.new(Page, "update", "all")
             ])
    end

    test "permissions" do
      auth = %Authorization{
        permissions: [
          Permission.new(Page, "publish", "team"),
          Permission.new(Page, "create", "all")
        ]
      }

      refute Authorization.permitted?(auth, [
               Permission.new(Page, "publish", "all")
             ])

      refute Authorization.permitted?(auth, [
               Permission.new(Page, "publish", "own"),
               Permission.new(Page, "update", "all")
             ])

      assert Authorization.permitted?(auth, [
               Permission.new(Page, "publish", "own"),
               Permission.new(Page, "create", "all")
             ])
    end
  end
end
