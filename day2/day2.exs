{:ok, input} = File.read("input.txt")

split_int_arrays =
  input
  |> String.split(["\n", "\r", "\r\n"], trim: true)
  |> Enum.map(fn x -> String.split(x, " ", trim: true) |> Enum.map(&String.to_integer/1) end)

defmodule Main do
  def is_report_safe(array) do
    chunked_array = array |> Enum.chunk_every(2, 1, :discard)

    length(chunked_array) ==
      abs(
        chunked_array
        |> Enum.map(fn [x, y] -> y - x end)
        |> Enum.filter(&(0 < abs(&1) && abs(&1) < 4))
        |> Enum.map(&if &1 >= 0, do: 1, else: -1)
        |> Enum.sum()
      )
  end
end

defmodule Permutations do
  def get(array),
    do: Enum.reduce(array, [array], fn x, accumulator -> [array -- [x] | accumulator] end)
end

part1 =
  split_int_arrays
  |> Enum.reduce(0, fn x, accumulator ->
    if x |> Main.is_report_safe(),
      do: accumulator + 1,
      else: accumulator
  end)

part2 =
  split_int_arrays
  |> Enum.reduce(0, fn array, accumulator ->
    if Enum.reduce(array |> Permutations.get(), false, fn x, is_safe ->
         is_safe || Main.is_report_safe(x)
       end),
       do: accumulator + 1,
       else: accumulator
  end)

IO.puts(part1)
IO.puts(part2)
