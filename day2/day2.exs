{:ok, input} = File.read("input.txt")

split_int_arrays =
  input
  |> String.split(["\n", "\r", "\r\n"], trim: true)
  |> Enum.map(fn x -> String.split(x, " ", trim: true) |> Enum.map(&String.to_integer/1) end)

defmodule Extract do
  def extract({:ok, term}), do: term
end

defmodule Main do
  def is_report_safe(array),
    do:
      array
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [x, y] -> y - x end)
      |> then(
        &Enum.reduce(&1, {Extract.extract(Enum.fetch(&1, 0)), true}, fn z, {diff, is_safe} ->
          same_dir = z > 0 == diff > 0
          in_range = 0 < abs(z) && abs(z) < 4
          {z, is_safe && same_dir && in_range}
        end)
      )
      |> elem(1)
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
    if Enum.reduce(Permutations.get(array), false, fn x, correct_perm ->
         correct_perm || Main.is_report_safe(x)
       end),
       do: accumulator + 1,
       else: accumulator
  end)

IO.puts(part1)
IO.puts(part2)
