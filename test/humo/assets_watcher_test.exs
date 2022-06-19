defmodule Humo.AssetsWatcherTest do
  use ExUnit.Case, async: false

  import MixHelper

  alias Humo.AssetsWatcher

  setup_all do
    Mix.shell(Mix.Shell.Quiet)
  end

  setup do
    old_config = Application.fetch_env!(:humo, Humo)

    Application.put_env(:humo, Humo,
      apps: [
        %{app: :core, path: "deps/core"},
        %{app: :my_app, path: "./"}
      ],
      server_app: :my_app
    )

    on_exit(fn -> Application.put_env(:humo, Humo, old_config) end)
  end

  test "on start assets are copied" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core")
      mkdir_write_file("assets/static/robots.txt", "robots.txt my_app")

      AssetsWatcher.start_link([])
      Process.sleep(100)

      assert_file("priv/static/robots.txt", "robots.txt my_app")
    end)
  end

  test "last app asset changed, it's copied" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core")
      mkdir_write_file("assets/static/robots.txt", "robots.txt my_app")

      AssetsWatcher.start_link([])
      Process.sleep(100)

      mkdir_write_file("assets/static/robots.txt", "robots.txt my_app 2")
      Process.sleep(600)

      assert_file("priv/static/robots.txt", "robots.txt my_app 2")
    end)
  end

  test "first app asset changed, not copied" do
    in_tmp("mix_humo_assets_copy", fn ->
      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core")
      mkdir_write_file("assets/static/robots.txt", "robots.txt my_app")

      AssetsWatcher.start_link([])
      Process.sleep(100)

      mkdir_write_file("deps/core/assets/static/robots.txt", "robots.txt core 2")
      Process.sleep(600)

      assert_file("priv/static/robots.txt", "robots.txt my_app")
    end)
  end
end
