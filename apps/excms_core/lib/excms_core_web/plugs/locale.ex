defmodule ExcmsCoreWeb.LocalePlug do
  import Plug.Conn

  @locales Gettext.known_locales(ExcmsCoreWeb.Gettext) # TODO fix
  @default_locale "en"

  def init(params), do: params

  def call(conn, _opts) do
    params_locale = Map.get(conn.params, "locale")
    accept_locale = extract_accept_language(conn)

    conn = assign(conn, :known_locales, @locales)

    locale = cond do
      approved_locale(params_locale) ->
        params_locale
      approved_locale(accept_locale) ->
        accept_locale
      true ->
        @default_locale
    end

    assign_locale(conn, locale)
  end

  defp assign_locale(conn, locale) do
    Gettext.put_locale(locale)

    conn
    |> assign(:locale, locale)
  end

  defp extract_accept_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> ensure_language_fallbacks()
        |> Enum.find(nil, &approved_locale/1)
      _ ->
        nil
    end
  end

  defp parse_language_option(string) do
    captures = ~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i
    |> Regex.named_captures(string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp ensure_language_fallbacks(tags) do
    Enum.flat_map(tags, fn tag ->
      [language | _] = String.split(tag, "-")
      if Enum.member?(tags, language), do: [tag], else: [tag, language]
    end)
  end

  defp approved_locale(locale) do
    locale in @locales
  end
end
