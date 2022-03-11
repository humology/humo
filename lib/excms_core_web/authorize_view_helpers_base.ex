defmodule ExcmsCoreWeb.AuthorizeViewHelpersBase do
  defmacro __using__(opts) do
    route_authorizer =
      opts[:route_authorizer] || raise ":route_authorizer is expected to be given"

    quote do
      use Phoenix.HTML

      def can_link(conn, opts, do: contents) when is_list(opts),
        do: can_link(conn, contents, opts)

      def can_link(conn, text, opts) do
        path = Keyword.fetch!(opts, :to)
        method = Keyword.get(opts, :method, :get)

        if unquote(route_authorizer).can_path?(conn, path, method) do
          link(text, opts)
        else
          ""
        end
      end
    end
  end
end
