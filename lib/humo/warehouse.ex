defmodule Humo.Warehouse do
  @type resource_module() :: module()
  @type resource_helpers() :: module()

  @doc """
  Returns all resources
  """
  @spec resources :: list(resource_module())
  def resources() do
    for {_app, app_resources} <- apps_resources(),
        resource <- app_resources do
      resource
    end
  end

  @doc """
  Returns resource helpers module
  """
  @spec resource_helpers(resource_module()) :: resource_helpers()
  def resource_helpers(resource) when is_atom(resource) do
    Module.safe_concat([resource, "Helpers"])
  end

  @doc """
  Returns map of names to resources
  """
  @spec names_resources() :: %{String.t() => resource_module()}
  def names_resources() do
    for resource <- resources(), into: %{} do
      {resource_helpers(resource).name(), resource}
    end
  end

  @doc """
  Validates Warehouse config
  Run in otp app, because it requires compiled resource modules
  """
  @spec validate_config(fun()) :: :ok
  def validate_config(apps_resources_fun \\ &apps_resources/0) do
    for {app, app_resources} when is_atom(app) <- apps_resources_fun.(),
        resource <- app_resources do
      resource_helpers = resource_helpers(resource)

      Code.ensure_loaded!(resource_helpers)

      unless function_exported?(resource_helpers, :name, 0), do:
        raise ArgumentError,
          """
          Application: #{inspect(app)}
          #{inspect(resource_helpers)} expected exported function name/0
          """

      resource_name = resource_helpers.name()
      resource_name_prefix = "#{app}_"
      unless String.starts_with?(resource_name, resource_name_prefix), do:
        raise ArgumentError,
          """
          Application: #{inspect(app)}
          #{inspect(resource_helpers)}.name() expected to start with #{inspect(resource_name_prefix)}, actual: #{inspect(resource_name)}
          """

      unless function_exported?(resource_helpers, :actions, 0), do:
        raise ArgumentError,
          """
          Application: #{inspect(app)}
          #{inspect(resource_helpers)} expected exported function actions/0
          """

      resource_actions = resource_helpers.actions()

      if resource_actions == [], do:
        raise ArgumentError,
          """
          Application: #{inspect(app)}
          #{inspect(resource_helpers)}.actions() cannot be empty
          """

      for action <- resource_actions, do:
        unless is_binary(action), do:
          raise ArgumentError,
            """
            Application: #{inspect(app)}
            #{inspect(resource_helpers)} action #{inspect(action)} type expected to be binary
            """
    end

    :ok
  end

  defp apps_resources() do
    Application.fetch_env!(:humo, __MODULE__)
  end
end
