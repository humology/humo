defmodule Humo.Authorizer.Mock do
  use Humo.Authorizer.Behaviour

  @key :mock_authorizer_funs

  def with_mock(fun, mock_funs) do
    Process.put(@key, mock_funs)
    fun.()
    Process.delete(@key)
  end

  @impl true
  def can_all(authorization, action, resource_module) do
    mock_can_all = Process.get(@key, [])[:can_all]
    unless mock_can_all do
      raise """
      Please use with_mock and pass :can_all function
      """
    end
    mock_can_all.(authorization, action, resource_module)
  end

  @impl true
  def can_actions(authorization, resource) do
    mock_can_actions = Process.get(@key, [])[:can_actions]
    unless mock_can_actions do
      raise """
      Please use with_mock and pass :can_actions function
      """
    end
    mock_can_actions.(authorization, resource)
  end
end
