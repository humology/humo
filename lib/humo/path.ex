defmodule Humo.Path do
  def normalize(paths) when is_list(paths) do
    Path.join(paths)
    |> Path.split()
    |> do_normalize([])
    |> Path.join()
  end

  defp do_normalize([], acc), do: Enum.reverse(acc)

  defp do_normalize(["." | rest], acc) do
    do_normalize(rest, acc)
  end

  defp do_normalize([".." | rest], [last | acc]) when last != ".." do
    do_normalize(rest, acc)
  end

  defp do_normalize([item | rest], acc) do
    do_normalize(rest, [item | acc])
  end
end
