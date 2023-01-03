defmodule Mix.Tasks.Humo.Npm.InstallTest do
  use ExUnit.Case, async: false

  import MixHelper

  alias Mix.Tasks.Humo.Npm.Install

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

  test "npm install" do
    in_tmp("mix_humo_npm_install", fn ->
      mkdir_write_file(
        "deps/core/package.json",
        ~S({"dependencies": {"@popperjs/core": "^2.9.2"}})
      )

      mkdir_write_file(
        "./package.json",
        ~S({"devDependencies": {"bootstrap": "^5.0.1"}})
      )

      Install.run([])

      assert_received {:mix_shell, :info, ["Running task humo.npm.install"]}

      assert_file(
        "deps/core/node_modules/@popperjs/core/package.json",
        ~S("name": "@popperjs/core")
      )

      assert_file(
        "node_modules/bootstrap/package.json",
        ~S("name": "bootstrap")
      )
    end)
  end
end
