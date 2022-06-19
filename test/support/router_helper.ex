defmodule RouterHelper do
  @moduledoc """
  Conveniences for testing routers and controllers.
  Must not be used to test endpoints as it does some
  pre-processing (like fetching params) which could
  skew endpoint tests.

  Source https://github.com/phoenixframework/phoenix/blob/master/test/support/router_helper.exs

  MIT License

  Copyright (c) 2014 Chris McCord
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
  associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all copies or substantial
  portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  """

  import Plug.Test

  defmacro __using__(_) do
    quote do
      use Plug.Test
      import RouterHelper
    end
  end

  def call(router, verb, path, assigns \\ [], params \\ nil, script_name \\ []) do
    verb
    |> conn(path, params)
    |> then(fn conn ->
      assigns
      |> Enum.reduce(conn, fn {key, value}, acc ->
        Plug.Conn.assign(acc, key, value)
      end)
    end)
    |> Plug.Conn.fetch_query_params()
    |> Map.put(:script_name, script_name)
    |> router.call(router.init([]))
  end

  def action(controller, verb, action, params \\ nil) do
    conn = conn(verb, "/", params) |> Plug.Conn.fetch_query_params()
    controller.call(conn, controller.init(action))
  end
end
