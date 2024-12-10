{:ok, input} = File.read("input.txt")

defmodule Main do
  def enum_to_map(enum) do
    Stream.iterate(0, &(&1 + 1)) |> Enum.zip(enum) |> Map.new()
  end

  def find_attenas(map, initial, func) do
    map
    |> Enum.reduce(initial, fn {y, sub_map}, acc ->
      sub_map
      |> Enum.reduce(acc, fn {x, value}, acc ->
        func.(value, acc, y, x)
      end)
    end)
  end
end

input_map =
  Main.enum_to_map(
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&Main.enum_to_map/1)
  )

antenna_locations =
  input_map
  |> Main.find_attenas(Map.new(), fn value, acc, y, x ->
    if value != ".",
      do: acc |> Map.update(value, [{x, y}], fn existing_value -> [{x, y} | existing_value] end),
      else: acc
  end)

part1 =
  antenna_locations
  |> Enum.reduce(MapSet.new(), fn {_, matching_antenna_list}, set ->
    resonating_attenas =
      for a <- matching_antenna_list,
          b <- matching_antenna_list,
          a != b,
          do: [a, b]

    resonating_attenas
    |> Enum.reduce(set, fn [{x1, y1}, {x2, y2}], set ->
      set
      |> MapSet.put({x1 + (x1 - x2), y1 + (y1 - y2)})
      |> MapSet.put({x2 + (x2 - x1), y2 + (y2 - y1)})
    end)
  end)
  |> MapSet.filter(fn {x, y} -> input_map[x][y] != nil end)
  |> MapSet.size()

part2 =
  antenna_locations
  |> Enum.reduce(MapSet.new(), fn {_, matching_antenna_list}, set ->
    resonating_attenas =
      for a <- matching_antenna_list,
          b <- matching_antenna_list,
          a != b,
          do: [a, b]

    antenna_added_set =
      matching_antenna_list |> Enum.reduce(set, fn antenna, set -> set |> MapSet.put(antenna) end)

    resonating_attenas
    |> Enum.reduce(antenna_added_set, fn [
                                           {x1, y1},
                                           {x2, y2}
                                         ],
                                         set ->
      1..100
      |> Enum.reduce(set, fn value, set ->
        set
        |> MapSet.put({x1 + (x1 - x2) * value, y1 + (y1 - y2) * value})
        |> MapSet.put({x2 + (x2 - x1) * value, y2 + (y2 - y1) * value})
      end)
    end)
  end)
  |> MapSet.filter(fn {x, y} -> input_map[x][y] != nil end)
  |> MapSet.size()

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
