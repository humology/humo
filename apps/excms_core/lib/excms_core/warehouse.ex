defmodule ExcmsCore.Warehouse do
  @resources Application.compile_env!(:excms_core, __MODULE__)
             |> Enum.flat_map(fn {_plugin, plugin_resources} when is_list(plugin_resources) ->
               plugin_resources
             end)

  @names_resources @resources
                   |> Enum.map(fn x ->
                     {String.to_existing_atom("#{x}.Helpers").name(), x}
                   end)
                   |> Map.new()

  if Enum.count(@resources) != Enum.count(@names_resources),
    do: raise("Duplicate annotation of resource #{@resources -- Map.values(@names_resources)}")

  @doc """
  Returns all resources
  """
  def resources(), do: @resources

  def to_resource_helpers(resource) do
    try do
      Module.safe_concat([resource, "Helpers"])
    rescue
      ArgumentError -> nil
    end
  end

  def name_to_resource!(name), do: Map.fetch!(@names_resources, name)

  def name_to_resource(name), do: Map.get(@names_resources, name)
end
