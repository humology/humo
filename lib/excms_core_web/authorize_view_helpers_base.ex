defmodule ExcmsCoreWeb.AuthorizeViewHelpersBase do
  defmacro __using__(opts) do
    lazy_can_path =
      opts[:lazy_can_path] || raise ":lazy_can_path is expected to be given"

    quote do
      alias ExcmsCoreWeb.RouteAuthorizer
      use Phoenix.HTML

      def can_link(conn, opts, do: contents) when is_list(opts),
        do: can_link(conn, contents, opts)

      def can_link(conn, text, opts) do
        path = Keyword.fetch!(opts, :to)
        {can_params, opts} = Keyword.pop(opts, :can_params, [])

        can_params = Keyword.merge(can_params, Keyword.take(opts, [:method]))

        if can_path?(conn, path, can_params) do
          link(text, opts)
        else
          ""
        end
      end

      defp can_path?(conn, path, can_params) do
        apply(unquote(lazy_can_path), [conn, path, can_params])
      end
    end
  end
end
