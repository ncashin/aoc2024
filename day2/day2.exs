{:ok, input} = File.read("input.txt")

split_int_arrays =
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line -> line |> String.split(" ") |> Enum.map(&String.to_integer/1) end)

defmodule Main do
  def is_report_safe(array) do
    chunked_array = array |> Enum.chunk_every(2, 1, :discard)

    length(chunked_array) ==
      abs(
        chunked_array
        |> Enum.map(fn [x, y] -> y - x end)
        |> Enum.filter(&(0 != &1 && abs(&1) < 4))
        |> Enum.map(&if &1 > 0, do: 1, else: -1)
        |> Enum.sum()
      )
  end

  def get_possible_dampened_reports(array),
    do:
      Enum.reduce(0..(length(array) - 1), [array], fn x, accumulator ->
        [List.delete_at(array, x) | accumulator]
      end)
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
    IO.inspect(
      Enum.reduce(array |> Main.get_possible_dampened_reports(), false, fn x, is_safe ->
        is_safe || Main.is_report_safe(x)
      end)
    )

    if Enum.reduce(array |> Main.get_possible_dampened_reports(), false, fn x, is_safe ->
         is_safe || Main.is_report_safe(x)
       end),
       do: accumulator + 1,
       else: accumulator
  end)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
