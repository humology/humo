defmodule Mix.Tasks.Humo.Assets.AllPlugins.Scss.GenTest do
  use ExUnit.Case, async: false

  import MixHelper

  alias Mix.Tasks.Humo.Assets.AllPlugins.Scss.Gen

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
      otp_app: :my_app
    )

    on_exit(fn ->
      Application.put_env(:humo, Humo, old_config)
    end)
  end

  test "generated all_plugins.scss file imports dependencies with plugin.scss" do
    in_tmp("mix_humo_assets_all_plugins_scss_gen", fn ->
      mkdir_write_file("deps/core/assets/css/plugin.scss", "")

      Gen.run([])

      assert_received {:mix_shell, :info, ["* creating assets/css/all_plugins.scss"]}

      assert_file(
        "assets/css/all_plugins.scss",
        """
        // Automatically generated
        // Imports plugins with assets/css/plugin.scss file

        @import "../../deps/core/assets/css/plugin.scss";
        """
      )
    end)
  end

  test "generated all_plugins.scss file imports dependencies with plugin.scss and current app plugin.scss" do
    in_tmp("mix_humo_assets_all_plugins_scss_gen", fn ->
      mkdir_write_file("deps/core/assets/css/plugin.scss", "")
      mkdir_write_file("assets/css/plugin.scss", "")

      Gen.run([])

      assert_received {:mix_shell, :info, ["* creating assets/css/all_plugins.scss"]}

      assert_file(
        "assets/css/all_plugins.scss",
        """
        // Automatically generated
        // Imports plugins with assets/css/plugin.scss file

        @import "../../deps/core/assets/css/plugin.scss";
        @import "./plugin.scss";
        """
      )
    end)
  end
end
