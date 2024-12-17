defmodule Griddy do
  def enum_to_map(enum) do
    Stream.iterate(0, &(&1 + 1)) |> Enum.zip(enum) |> Map.new()
  end

  def new_from_string(string) do
    Griddy.enum_to_map(
      string
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&Griddy.enum_to_map/1)
    )
  end

  def reduce(grid, initial, func) do
    grid
    |> Enum.reduce(initial, fn {y, sub_map}, acc ->
      sub_map
      |> Enum.reduce(acc, fn {x, value}, acc ->
        func.(value, acc, x, y)
      end)
    end)
  end

  def get(grid, x, y) do
    grid[y][x]
  end

  def put(grid, x, y, value) do
    grid |> Map.update(y, nil, fn sub_map -> sub_map |> Map.put(x, value) end)
  end

  def update(grid, x, y, default, func) do
    grid |> Map.update(y, nil, fn sub_map -> sub_map |> Map.update(x, default, func) end)
  end

  def find(map, value) do
    map
    |> Enum.reduce({0, 0}, fn {y, sub_map}, acc ->
      sub_map
      |> Enum.reduce(acc, fn {x, _}, acc ->
        if map[y][x] == value, do: {x, y}, else: acc
      end)
    end)
  end

  def to_string(grid) do
    {string, _} =
      grid
      |> Griddy.reduce({"", nil}, fn value, {acc, prev_y}, _, y ->
        if y != prev_y do
          {acc <> "\n" <> value, y}
        else
          {acc <> value, y}
        end
      end)

    string
  end

  def print(grid) do
    grid |> Griddy.to_string() |> IO.puts()

    grid
  end
end
