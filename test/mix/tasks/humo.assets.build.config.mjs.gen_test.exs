defmodule Mix.Tasks.Humo.Assets.Build.Config.Mjs.GenTest do
  use ExUnit.Case, async: false

  import MixHelper

  alias Mix.Tasks.Humo.Assets.Build.Config.Mjs.Gen

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

  test "generated build.config.mjs file exports sassLoadPaths and nodePaths" do
    in_tmp("mix_humo_assets_build_config_mjs_gen", fn ->
      mkdir_write_file("deps/core/package.json", "")

      Gen.run([])

      assert_received {:mix_shell, :info, ["* creating assets/build.config.mjs"]}

      assert_file(
        "assets/build.config.mjs",
        """
        // Automatically generated

        const sassLoadPaths = [
            '../deps/core/node_modules',
            '../deps/users/node_modules',
            '../node_modules'
        ]

        const nodePaths = [
            '../deps',
            '../..'
        ]

        export { sassLoadPaths, nodePaths }
        """
      )
    end)
  end
end
