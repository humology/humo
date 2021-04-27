defmodule ExcmsCore.GlobalAccess do
  @moduledoc """
  Global access
  """

  defmodule Helpers do
    use ExcmsCore.ResourceHelpers

    def name(), do: "global_access"

    def actions(), do: ["cms"]
  end
end
