defmodule Main do
  def enum_to_map(enum) do
    Stream.iterate(0, &(&1 + 1)) |> Enum.zip(enum) |> Map.new()
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

  def find_xmas(map, x, y, dir_x, dir_y, char_index) do
    xmas_chars = %{0 => "X", 1 => "M", 2 => "A", 3 => "S"}

    if xmas_chars[char_index] == nil do
      1
    else
      if map[y][x] == xmas_chars[char_index] do
        find_xmas(map, x + dir_x, y + dir_y, dir_x, dir_y, char_index + 1)
      else
        0
      end
    end
  end

  def find_mas_x(map, x, y) do
    if map[y][x] == "A" &&
         ((map[y - 1][x - 1] == "S" && map[y + 1][x + 1] == "M") ||
            (map[y - 1][x - 1] == "M" && map[y + 1][x + 1] == "S")) &&
         ((map[y - 1][x + 1] == "S" && map[y + 1][x - 1] == "M") ||
            (map[y - 1][x + 1] == "M" && map[y + 1][x - 1] == "S")) do
      1
    else
      0
    end
  end
end

{:ok, input} = File.read("input.txt")

input_map =
  Main.enum_to_map(
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&Main.enum_to_map/1)
  )

part1 =
  input_map
  |> Main.reduce_nested_map(0, fn value, acc, y, x ->
    if value == "X" do
      acc + Main.find_xmas(input_map, x, y, 1, 0, 0) + Main.find_xmas(input_map, x, y, -1, 0, 0) +
        Main.find_xmas(input_map, x, y, 1, 1, 0) + Main.find_xmas(input_map, x, y, -1, 1, 0) +
        Main.find_xmas(input_map, x, y, 1, -1, 0) + Main.find_xmas(input_map, x, y, -1, -1, 0) +
        Main.find_xmas(input_map, x, y, 0, 1, 0) + Main.find_xmas(input_map, x, y, 0, -1, 0)
    else
      acc
    end
  end)

part2 =
  input_map
  |> Main.reduce_nested_map(0, fn value, acc, y, x ->
    if value == "A" do
      acc + Main.find_mas_x(input_map, x, y)
    else
      acc
    end
  end)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
