{:ok, input} = File.read("input.txt")

split_int_arrays =
  input
  |> String.split(["\n", "\r", "\r\n"], trim: true)
  |> Enum.map(fn x -> String.split(x, " ", trim: true) |> Enum.map(&String.to_integer/1) end)

part1 =
  split_int_arrays
  |> Enum.reduce(0, fn x, accumulator ->
    if Enum.chunk_every(x, 2, 1, :discard)
       |> Enum.map(fn [x, y] -> y - x end)
       |> Enum.reduce({0, true}, fn z, {diff, is_safe} ->
         {z, diff == 0 || (is_safe && z > 0 == diff > 0 && z != 0 && abs(z) < 4)}
       end)
       |> elem(1),
       do: accumulator + 1,
       else: accumulator
  end)

IO.puts(part1)
