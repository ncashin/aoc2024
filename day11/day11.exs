{:ok, input} = File.read("input.txt")

stones = input |> String.split([" ", "\n"], trim: true) |> Enum.map(&String.to_integer/1)

stone_rule_func = fn stones ->
  stones
  |> Enum.reverse()
  |> Enum.reduce([], fn value, acc ->
    if value == 0 do
      [1 | acc]
    else
      string = value |> Integer.to_string()
      str_len = String.length(string)

      if Integer.mod(str_len, 2) == 0 do
        {left, right} =
          string |> String.split_at(floor(str_len / 2))

        [left |> String.to_integer() | [right |> String.to_integer() | acc]]
      else
        [value * 2024 | acc]
      end
    end
  end)
end

part1 =
  1..25
  |> Enum.reduce(stones, fn _, acc ->
    acc
    |> stone_rule_func.()
  end)
  |> Enum.map(fn _ -> 1 end)
  |> Enum.sum()

stone_map =
  stones
  |> Enum.reduce(Map.new(), fn value, map ->
    map |> Map.update(value, 1, fn existing_value -> existing_value + 1 end)
  end)

stone_map_func = fn map ->
  map
  |> Enum.reduce(Map.new(), fn {value, count}, map ->
    if value == 0 do
      map |> Map.update(1, count, fn existing_count -> existing_count + count end)
    else
      string = value |> Integer.to_string()
      str_len = String.length(string)

      if Integer.mod(str_len, 2) == 0 do
        {left, right} =
          string |> String.split_at(floor(str_len / 2))

        map
        |> Map.update(left |> String.to_integer(), count, fn existing_count ->
          existing_count + count
        end)
        |> Map.update(right |> String.to_integer(), count, fn existing_count ->
          existing_count + count
        end)
      else
        map |> Map.update(value * 2024, count, fn existing_count -> existing_count + count end)
      end
    end
  end)
end

part2 =
  1..75
  |> Enum.reduce(stone_map, fn _, acc ->
    acc
    |> stone_map_func.()
  end)
  |> Enum.map(fn {_, c} -> c end)
  |> Enum.sum()

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
