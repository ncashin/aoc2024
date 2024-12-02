{:ok, input} = File.read("input.txt")
split_ints = String.split(input) |> Enum.map(&String.to_integer/1)
left_array = Enum.take_every(split_ints, 2) |> Enum.sort()
right_array = Enum.drop_every(split_ints, 2) |> Enum.sort()

part1 = Enum.zip(left_array, right_array) |> Enum.map(fn {x, y} -> abs(x - y) end) |> Enum.sum()

right_number_of_occurences =
  Enum.reduce(right_array, %{}, fn x, accumulator ->
    Map.update(accumulator, x, 1, &(&1 + 1))
  end)

part2 =
  Enum.map(left_array, fn x -> x * Map.get(right_number_of_occurences, x, 0) end)
  |> Enum.sum()

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
