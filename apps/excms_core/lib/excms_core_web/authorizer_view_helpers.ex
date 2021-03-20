defmodule ExcmsCoreWeb.AuthorizerViewHelpers do
  alias ExcmsCoreWeb.Authorizer
  use Phoenix.HTML

  def clink(conn, text, opts), do: plink(conn, :new, text, opts)

  def rlink(conn, text, opts), do: plink(conn, :show, text, opts)

  def ulink(conn, text, opts), do: plink(conn, :edit, text, opts)

  def dlink(conn, text, opts), do: plink(conn, :delete, text, opts)

  def plink(conn, action, opts, do: contents) when is_list(opts) do
    plink(conn, action, contents, opts)
  end

  def plink(conn, action, text, opts) do
    authorization = conn.assigns.authorization
    path = Keyword.fetch!(opts, :to)
    if Authorizer.do?(authorization, path, action) do
      link(text, opts)
    else
      ""
    end
  end

  def can_access?(conn, path, action)
  when action in [:index, :new, :create, :show, :edit, :update, :delete], do:
    Authorizer.do?(conn.assigns.authorization, path, action)
end
