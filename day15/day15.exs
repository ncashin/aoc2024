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

defmodule Bobot do
  def move_push_recursive(grid, x, y, dx, dy) do
    case grid |> Griddy.get(x + dx, y + dy) do
      "#" ->
        grid

      "." ->
        grid
        |> Griddy.put(x + dx, y + dy, grid |> Griddy.get(x, y))
        |> Griddy.put(x, y, ".")

      _ ->
        new_grid = Bobot.move_push_recursive(grid, x + dx, y + dy, dx, dy)

        if new_grid != grid do
          new_grid
          |> Griddy.put(x + dx, y + dy, grid |> Griddy.get(x, y))
          |> Griddy.put(x, y, ".")
        else
          grid
        end
    end
  end

  def expanded_move_push_recursive(grid, x, y, dx, dy) do
    normal_func = fn ->
      case grid |> Griddy.get(x + dx, y + dy) do
        "#" ->
          grid

        "." ->
          grid
          |> Griddy.put(x + dx, y + dy, grid |> Griddy.get(x, y))
          |> Griddy.put(x, y, ".")

        _ ->
          new_grid = Bobot.expanded_move_push_recursive(grid, x + dx, y + dy, dx, dy)

          if new_grid != grid do
            new_grid
            |> Griddy.put(x + dx, y + dy, grid |> Griddy.get(x, y))
            |> Griddy.put(x, y, ".")
          else
            grid
          end
      end
    end

    left_move_func = fn grid ->
      grid
      |> Griddy.put(x + dx, y + dy, grid |> Griddy.get(x, y))
      |> Griddy.put(x, y, ".")
      |> Griddy.put(x + dx + 1, y + dy, grid |> Griddy.get(x + 1, y))
      |> Griddy.put(x + 1, y, ".")
    end

    right_move_func = fn grid ->
      grid
      |> Griddy.put(x + dx - 1, y + dy, grid |> Griddy.get(x - 1, y))
      |> Griddy.put(x - 1, y, ".")
      |> Griddy.put(x + dx, y + dy, grid |> Griddy.get(x, y))
      |> Griddy.put(x, y, ".")
    end

    case grid |> Griddy.get(x, y) do
      "]" ->
        case({grid |> Griddy.get(x + dx - 1, y + dy), grid |> Griddy.get(x + dx, y + dy)}) do
          {".", "."} ->
            grid |> right_move_func.()

          {"[", "]"} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              new_grid_1 |> right_move_func.()
            end

          {"]", "["} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx - 1, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              new_grid_2 =
                new_grid_1
                |> Bobot.expanded_move_push_recursive(x + dx, y + dy, dx, dy)

              if new_grid_2 == new_grid_1 do
                grid
              else
                right_move_func.(new_grid_2)
              end
            end

          {"]", "."} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx - 1, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              right_move_func.(new_grid_1)
            end

          {".", "["} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              right_move_func.(new_grid_1)
            end

          _ ->
            grid
        end

      "[" ->
        case {grid |> Griddy.get(x + dx, y + dy), grid |> Griddy.get(x + dx + 1, y + dy)} do
          {".", "."} ->
            left_move_func.(grid)

          {"[", "]"} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              new_grid_1 |> left_move_func.()
            end

          {"]", "["} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              new_grid_2 =
                new_grid_1
                |> Bobot.expanded_move_push_recursive(x + dx + 1, y + dy, dx, dy)

              if new_grid_2 == new_grid_1 do
                grid
              else
                new_grid_2 |> left_move_func.()
              end
            end

          {"]", "."} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              left_move_func.(new_grid_1)
            end

          {".", "["} ->
            new_grid_1 =
              grid
              |> Bobot.expanded_move_push_recursive(x + dx + 1, y + dy, dx, dy)

            if new_grid_1 == grid do
              grid
            else
              left_move_func.(new_grid_1)
            end

          _ ->
            grid
        end

      _ ->
        normal_func.()
    end
  end
end

{:ok, input} = File.read("input.txt")

[raw_map, directions] = input |> String.split("\n\n", trim: true)

grid =
  raw_map
  |> Griddy.new_from_string()

{x1, y1} =
  grid
  |> Griddy.find("@")

dir_array =
  directions
  |> String.graphemes()

part1 =
  dir_array
  |> Enum.reduce({grid, x1, y1}, fn direction, {grid, x, y} ->
    case direction do
      "^" ->
        updated_grid = grid |> Bobot.move_push_recursive(x, y, 0, -1)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x, y - 1}
        end

      "v" ->
        updated_grid = grid |> Bobot.move_push_recursive(x, y, 0, 1)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x, y + 1}
        end

      "<" ->
        updated_grid = grid |> Bobot.move_push_recursive(x, y, -1, 0)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x - 1, y}
        end

      ">" ->
        updated_grid = grid |> Bobot.move_push_recursive(x, y, 1, 0)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x + 1, y}
        end

      "\n" ->
        {grid, x, y}
    end
  end)
  |> then(fn {grid, _, _} -> grid end)
  |> Griddy.reduce(0, fn value, acc, x, y ->
    if value == "O" do
      acc + y * 100 + x
    else
      acc
    end
  end)

expanded_grid =
  raw_map
  |> String.graphemes()
  |> Enum.reduce("", fn char, acc ->
    case char do
      "#" -> acc <> "##"
      "." -> acc <> ".."
      "@" -> acc <> "@."
      "O" -> acc <> "[]"
      "\n" -> acc <> "\n"
    end
  end)
  |> Griddy.new_from_string()

{x2, y2} =
  expanded_grid
  |> Griddy.find("@")

part2 =
  dir_array
  |> Enum.reduce({expanded_grid, x2, y2}, fn direction, {grid, x, y} ->
    case direction do
      "^" ->
        updated_grid = grid |> Bobot.expanded_move_push_recursive(x, y, 0, -1)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x, y - 1}
        end

      "v" ->
        updated_grid = grid |> Bobot.expanded_move_push_recursive(x, y, 0, 1)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x, y + 1}
        end

      "<" ->
        updated_grid = grid |> Bobot.move_push_recursive(x, y, -1, 0)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x - 1, y}
        end

      ">" ->
        updated_grid = grid |> Bobot.move_push_recursive(x, y, 1, 0)

        if updated_grid == grid do
          {updated_grid, x, y}
        else
          {updated_grid, x + 1, y}
        end

      _ ->
        {grid, x, y}
    end
  end)
  |> then(fn {grid, _, _} -> grid end)
  |> Griddy.reduce(0, fn value, acc, x, y ->
    if value == "[" do
      acc + y * 100 + x
    else
      acc
    end
  end)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
