defmodule ExcmsCore.Authorizer do
  @behaviour ExcmsCore.Authorizer.Behaviour

  @impl true
  def can?(user, action, resource_or_module, authorizer \\ nil) do
    authorizer(authorizer)
    |> apply(:can?, [user, action, resource_or_module])
  end

  @impl true
  @spec can_all(any, any, any, any) :: any
  def can_all(user, action, resource_module, authorizer \\ nil) do
    authorizer(authorizer)
    |> apply(:can_all, [user, action, resource_module])
  end

  @impl true
  def can_actions(user, resource_or_module, authorizer \\ nil) do
    authorizer(authorizer)
    |> apply(:can_actions, [user, resource_or_module])
  end

  defp authorizer(authorizer) do
    authorizer || Application.fetch_env!(:excms_core, __MODULE__)[:authorizer]
  end
end
