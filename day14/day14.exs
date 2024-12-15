{:ok, input} = File.read("input.txt")

# robot = x, y, vx, vy

width = 101
height = 103

time_before_bathroom = 100

robots =
  Regex.scan(~r/-?\d+/, input)
  |> List.flatten()
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(4)

middle_x = floor(width / 2)
middle_y = floor(height / 2)

foo = fn y ->
  if y < middle_y do
    "top"
  else
    "bottom"
  end
end

part1 =
  1..time_before_bathroom
  |> Enum.reduce(robots, fn _, robot_acc ->
    robot_acc
    |> Enum.map(fn [x, y, vx, vy] ->
      [Integer.mod(x + vx, width), Integer.mod(y + vy, height), vx, vy]
    end)
  end)
  |> Enum.filter(fn [x, y, _, _] ->
    x != middle_x &&
      y != middle_y
  end)
  |> Enum.group_by(fn [x, y, _, _] ->
    if x < middle_x do
      "left_" <> foo.(y)
    else
      "right_" <> foo.(y)
    end
  end)
  |> Enum.map(fn {key, value} -> {key, value |> Enum.count()} end)
  |> Enum.reduce(1, fn {_, value}, acc -> value * acc end)

robots_console_output =
  robots
  |> Enum.reduce(
    Map.new(
      Enum.zip(
        0..(width - 1),
        0..(width - 1)
        |> Enum.map(fn _ ->
          Map.new(Enum.zip(0..(height - 1), 0..(height - 1) |> Enum.map(fn _ -> "." end)))
        end)
      )
    ),
    fn [x, y, _, _], map ->
      map |> Map.update(x, ".", fn value -> value |> Map.put(y, "#") end)
    end
  )
  |> Enum.map("", fn value, acc -> value |> Enum.reduce(fn {_, v} -> IO.inspect(v) end) end)

IO.puts()

part2 = ""

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
