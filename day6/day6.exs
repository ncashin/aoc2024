{:ok, input} = File.read("input.txt")

defmodule Main do
  def enum_to_map(enum) do
    Stream.iterate(0, &(&1 + 1)) |> Enum.zip(enum) |> Map.new()
  end

  def find_guard(map) do
    map
    |> Enum.reduce({0, 0}, fn {y, sub_map}, acc ->
      sub_map
      |> Enum.reduce(acc, fn {x, _}, acc ->
        if map[y][x] == "^", do: {x, y}, else: acc
      end)
    end)
  end

  def reduce_nested_map(map, initial, func) do
    map
    |> Enum.reduce(initial, fn {y, sub_map}, acc ->
      sub_map
      |> Enum.reduce(acc, fn {x, value}, acc ->
        func.(value, acc, y, x)
      end)
    end)
  end

  def patrol(map, x, y, dir, tiles_covered) do
    {dir_x, dir_y} = dir

    dir_map = %{
      {1, 0} => {0, -1},
      {0, -1} => {-1, 0},
      {-1, 0} => {0, 1},
      {0, 1} => {1, 0}
    }

    case map[y][x] do
      "#" ->
        patrol(map, x - dir_x, y + dir_y, dir_map[dir], tiles_covered)

      "." ->
        patrol(
          map |> Map.put(y, map[y] |> Map.put(x, {"X", dir})),
          x + dir_x,
          y - dir_y,
          dir,
          tiles_covered + 1
        )

      "^" ->
        patrol(
          map |> Map.put(y, map[y] |> Map.put(x, {"X", dir})),
          x + dir_x,
          y - dir_y,
          dir,
          tiles_covered + 1
        )

      {"X", prior_dir} ->
        if prior_dir == dir,
          do: "loop",
          else:
            patrol(
              map,
              x + dir_x,
              y - dir_y,
              dir,
              tiles_covered
            )

      _ ->
        tiles_covered
    end
  end
end

input_map =
  Main.enum_to_map(
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&Main.enum_to_map/1)
  )

{start_guard_pos_x, start_guard_pos_y} =
  input_map |> Main.find_guard() |> IO.inspect()

part1 = Main.patrol(input_map, start_guard_pos_x, start_guard_pos_y, {0, 1}, 0)

part2 =
  input_map
  |> Main.reduce_nested_map(0, fn value, acc, y, x ->
    if input_map[y][x] == "." &&
         Main.patrol(
           input_map |> Map.update(y, nil, fn submap -> submap |> Map.put(x, "#") end),
           start_guard_pos_x,
           start_guard_pos_y,
           {0, 1},
           0
         ) == "loop",
       do: acc + 1,
       else: acc
  end)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
