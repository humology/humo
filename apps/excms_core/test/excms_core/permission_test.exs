defmodule ExcmsCore.PermissionTest do
  use ExUnit.Case
  alias ExcmsCore.Permission
  doctest Permission

  defmodule Page do
    defmodule Helpers do
      use ExcmsCore.ResourceHelpers

      def name(), do: "page"

      def actions(), do: ["create", "read", "update", "delete", "publish"]

      def access_levels("publish"), do: ["no", "own", "team", "all"]
      def access_levels(_), do: ["no", "all"]
    end
  end

  defmodule User do
    defmodule Helpers do
      use ExcmsCore.ResourceHelpers

      def name(), do: "user"
    end
  end

  defmodule WithoutHelpers do
  end

  describe "new" do
    test "success new/2" do
      assert %Permission{
               resource: Page,
               action: "create",
               access_level: "all"
             } = Permission.new(Page, "create")

      assert %Permission{
               resource: Page,
               action: "publish",
               access_level: "own"
             } = Permission.new(Page, "publish")
    end

    test "success new/3" do
      assert %Permission{
               resource: Page,
               action: "publish",
               access_level: "own"
             } = Permission.new(Page, "publish", "own")

      assert %Permission{
               resource: Page,
               action: "create",
               access_level: "all"
             } = Permission.new(Page, "create", "all")
    end

    test "helpers doesn't exist" do
      assert_raise MatchError, fn -> Permission.new(WithoutHelpers, "create", "all") end
    end

    test "action doesn't exist" do
      assert_raise MatchError, fn -> Permission.new(Page, "wrong") end
    end

    test "access_level doesn't exist" do
      assert_raise MatchError, fn -> Permission.new(Page, "publish", "wrong") end
    end
  end

  describe "validate" do
    test "success new/2" do
      assert :ok =
               Permission.new(Page, "create")
               |> Permission.validate()

      assert :ok =
               Permission.new(Page, "publish")
               |> Permission.validate()
    end

    test "success new/3" do
      assert :ok =
               Permission.new(Page, "publish", "own")
               |> Permission.validate()

      assert :ok =
               Permission.new(Page, "create", "all")
               |> Permission.validate()
    end

    test "helpers doesn't exist" do
      assert {:error, :undefined_helpers} =
               %Permission{
                 resource: WithoutHelpers,
                 action: "create",
                 access_level: "all"
               }
               |> Permission.validate()
    end

    test "action doesn't exist" do
      assert {:error, :unknown_action} =
               %Permission{
                 resource: Page,
                 helpers: Page.Helpers,
                 action: "wrong",
                 access_level: "all"
               }
               |> Permission.validate()
    end

    test "access_level doesn't exist" do
      assert {:error, :unknown_access_level} =
               %Permission{
                 resource: Page,
                 helpers: Page.Helpers,
                 action: "publish",
                 access_level: "wrong"
               }
               |> Permission.validate()
    end
  end

  describe "union" do
    test "pick highest access level" do
      actual =
        Permission.union([
          Permission.new(Page, "publish", "own"),
          Permission.new(Page, "publish", "no"),
          Permission.new(Page, "publish", "team")
        ])

      assert [Permission.new(Page, "publish", "team")] == actual
    end

    test "multiple" do
      actual =
        Permission.union([
          [
            Permission.new(Page, "create", "all"),
            Permission.new(User, "create", "all")
          ],
          [
            Permission.new(Page, "create", "no"),
            Permission.new(User, "create", "no")
          ]
        ])

      assert Enum.count(actual) == 2
      assert Permission.new(Page, "create", "all") in actual
      assert Permission.new(User, "create", "all") in actual
    end
  end

  describe "subset?" do
    test "success single required permission" do
      assert Permission.subset?(
               [
                 Permission.new(Page, "update", "all")
               ],
               [
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all"),
                 Permission.new(Page, "update", "all"),
                 Permission.new(Page, "delete", "all")
               ]
             )
    end

    test "success single required permission with lower access level" do
      assert Permission.subset?(
               [
                 Permission.new(Page, "publish", "own")
               ],
               [
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all"),
                 Permission.new(Page, "publish", "team")
               ]
             )
    end

    test "success multiple required permissions" do
      assert Permission.subset?(
               [
                 Permission.new(Page, "publish", "team"),
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all")
               ],
               [
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all"),
                 Permission.new(Page, "update", "all"),
                 Permission.new(Page, "delete", "all"),
                 Permission.new(Page, "publish", "team")
               ]
             )
    end

    test "fails single required permission" do
      refute Permission.subset?(
               [
                 Permission.new(Page, "update", "all")
               ],
               [
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all"),
                 Permission.new(Page, "delete", "all")
               ]
             )
    end

    test "fails single required permission with higher access level" do
      refute Permission.subset?(
               [
                 Permission.new(Page, "publish", "team")
               ],
               [
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all"),
                 Permission.new(Page, "publish", "own")
               ]
             )
    end

    test "fails multiple required permissions" do
      refute Permission.subset?(
               [
                 Permission.new(Page, "publish", "team"),
                 Permission.new(Page, "create", "all"),
                 Permission.new(Page, "read", "all")
               ],
               [
                 Permission.new(Page, "read", "all"),
                 Permission.new(Page, "update", "all"),
                 Permission.new(Page, "delete", "all"),
                 Permission.new(Page, "publish", "own")
               ]
             )
    end
  end
end
