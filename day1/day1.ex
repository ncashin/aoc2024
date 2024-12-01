{:ok, input} = File.read("input.txt")
split_ints = String.split(input) |> Enum.map(&String.to_integer/1)
left_array = Enum.take_every(split_ints, 2) |> Enum.sort()
right_array = Enum.drop_every(split_ints, 2) |> Enum.sort()

part1 = Enum.zip(left_array, right_array) |> Enum.map(fn {x, y} -> abs(x - y) end) |> Enum.sum()

part2 =
  Enum.map(left_array, fn x -> x * (Enum.filter(right_array, fn y -> x == y end) |> length) end)
  |> Enum.sum()

IO.puts(part1)
IO.puts(part2)
