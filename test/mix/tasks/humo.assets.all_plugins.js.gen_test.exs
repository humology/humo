defmodule Mix.Tasks.Humo.Assets.AllPlugins.Js.GenTest do
  use ExUnit.Case, async: false

  import MixHelper

  alias Mix.Tasks.Humo.Assets.AllPlugins.Js.Gen

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

  test "generated all_plugins.js file imports dependencies with package.json" do
    in_tmp("mix_humo_assets_appjs_gen", fn ->
      mkdir_write_file("deps/core/package.json", "")

      Gen.run([])

      assert_received {:mix_shell, :info, ["* creating assets/js/all_plugins.js"]}

      assert_file(
        "assets/js/all_plugins.js",
        """
        // Automatically generated
        // Imports plugins with package.json file

        import "core"
        """
      )
    end)
  end

  test "generated all_plugins.js file imports dependencies with package.json and current app plugin.js" do
    in_tmp("mix_humo_assets_appjs_gen", fn ->
      mkdir_write_file("deps/core/package.json", "")
      mkdir_write_file("assets/js/plugin.js", "")

      Gen.run([])

      assert_received {:mix_shell, :info, ["* creating assets/js/all_plugins.js"]}

      assert_file(
        "assets/js/all_plugins.js",
        """
        // Automatically generated
        // Imports plugins with package.json file

        import "core"
        import "./plugin"
        """
      )
    end)
  end
end
