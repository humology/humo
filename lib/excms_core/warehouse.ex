defmodule ExcmsCore.Warehouse do
  @resources Application.compile_env!(:excms_core, __MODULE__)
             |> Enum.flat_map(fn {_plugin, plugin_resources} when is_list(plugin_resources) ->
               plugin_resources
             end)

  @doc """
  Returns all resources
  """
  def resources(), do: @resources

  @doc """
  Returns resource helpers module
  """
  def resource_to_helpers(resource) do
    try do
      Module.safe_concat([resource, "Helpers"])
    rescue
      ArgumentError -> nil
    end
  end

  @doc """
  Returns map of names to resources
  """
  def names_resources() do
    names_to_resources =
      @resources
      |> Enum.map(fn x ->
        {resource_to_helpers(x).name(), x}
      end)
      |> Map.new()

    if Enum.count(@resources) != Enum.count(names_to_resources) do
      duplicates = @resources -- Map.values(names_to_resources)
      raise "Duplicate annotation of resource #{inspect(duplicates)}"
    end

    names_to_resources
  end
end
