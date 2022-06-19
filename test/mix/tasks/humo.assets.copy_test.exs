defmodule Mix.Tasks.Humo.Assets.CopyTest do
  use ExUnit.Case, async: false

  import MixHelper

  alias Mix.Tasks.Humo.Assets.Copy

  setup_all do
    # Get Mix output sent to the current
    # process to avoid polluting tests.
    Mix.shell(Mix.Shell.Process)
  end

  setup do
    old_config = Application.fetch_env!(:humo, Humo)

    Application.put_env(:humo, Humo,
      apps: [
        %{app: :core, path: "deps/core"},
        %{app: :users, path: "deps/users"},
        %{app: :my_app, path: "./"}
      ],
      server_app: :my_app
    )

    on_exit(fn ->
      Application.put_env(:humo, Humo, old_config)
    end)
  end

  test "files are not overriden" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core")
      mkdir_write_file("deps/users/assets/static/some_file.txt", "some_file.txt users")
      mkdir_write_file("assets/static/another_file.txt", "another_file.txt my_app")

      Copy.run([])

      assert_received {:mix_shell, :info, ["Running task humo.assets.copy"]}
      assert_received {:mix_shell, :info, ["* creating priv/static/robots.txt"]}
      assert_received {:mix_shell, :info, ["* creating priv/static/some_file.txt"]}
      assert_received {:mix_shell, :info, ["* creating priv/static/another_file.txt"]}

      assert_file("priv/static/robots.txt", "robots.txt core")
      assert_file("priv/static/some_file.txt", "some_file.txt users")
      assert_file("priv/static/another_file.txt", "another_file.txt my_app")
    end)
  end

  test "file in deep path is overriden by all apps, only last is copied" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/some/path/robots.txt", "robots.txt core")
      mkdir_write_file("deps/users/assets/static/some/path/robots.txt", "robots.txt users")
      mkdir_write_file("assets/static/some/path/robots.txt", "robots.txt my_app")

      Copy.run([])

      assert_received {:mix_shell, :info, ["Running task humo.assets.copy"]}
      assert_received {:mix_shell, :info, ["* creating priv/static/some/path/robots.txt"]}

      assert_file("priv/static/some/path/robots.txt", "robots.txt my_app")
    end)
  end

  test "file is overriden only by last app" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core")
      mkdir_write_file("assets/static/robots.txt", "robots.txt my_app")

      Copy.run([])

      assert_received {:mix_shell, :info, ["Running task humo.assets.copy"]}
      assert_received {:mix_shell, :info, ["* creating priv/static/robots.txt"]}

      assert_file("priv/static/robots.txt", "robots.txt my_app")
    end)
  end

  test "file is overriden only by second app" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core")
      mkdir_write_file("deps/users/assets/static/robots.txt", "robots.txt users")

      Copy.run([])

      assert_received {:mix_shell, :info, ["Running task humo.assets.copy"]}
      assert_received {:mix_shell, :info, ["* creating priv/static/robots.txt"]}

      assert_file("priv/static/robots.txt", "robots.txt users")
    end)
  end
end
