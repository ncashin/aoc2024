{:ok, input} = File.read("testinput.txt")

defmodule CLI do
  def print_file(file) do
    file
    |> Enum.map(fn {k, v} -> {k, v} end)
    |> Enum.sort(fn {a, _}, {b, _} -> a < b end)
    |> Enum.map(fn {_, v} -> if is_integer(v), do: Integer.to_string(v), else: "." end)
    |> List.to_string()
    |> IO.puts()

    file
  end

  def traverse_front(file, front_index, back_index) do
    # CLI.print_file(file)

    if front_index < back_index do
      case file[front_index] do
        "." ->
          traverse_back(
            file
            |> Map.put(front_index, file[back_index])
            |> Map.put(back_index, file[front_index]),
            front_index,
            back_index
          )

        _ ->
          traverse_front(file, front_index + 1, back_index)
      end
    else
      file
    end
  end

  def traverse_back(file, front_index, back_index) do
    case file[back_index] do
      nil ->
        file

      "." ->
        traverse_back(file, front_index, back_index - 1)

      _ ->
        traverse_front(file, front_index, back_index)
    end
  end

  def png(file) do
    file
    |> CLI.traverse_back(0, map_size(file) - 1)
    |> Enum.map(fn {k, v} -> {k, v} end)
    |> Enum.sort(fn {a, _}, {b, _} -> a < b end)
    |> Enum.filter(fn {_, v} -> v != "." end)
  end
end

file_map_array =
  input
  |> String.graphemes()
  |> Enum.filter(fn a -> a != "\n" end)
  |> Enum.map(&String.to_integer/1)

expanded_file =
  file_map_array
  |> Enum.chunk_every(2, 2, [nil])
  |> Enum.reduce({[], 0}, fn [taken_chunks, free_space], {unmapped_file, id} ->
    expanded_file = 0..(taken_chunks - 1) |> Enum.map(fn _ -> id end)
    file_added_disk = [expanded_file | unmapped_file]

    expanded_free_space =
      if free_space == nil || free_space - 1 < 0,
        do: [],
        else: 0..(free_space - 1) |> Enum.map(fn _ -> "." end)

    {[expanded_free_space | file_added_disk], id + 1}
  end)
  |> then(fn {expanded_file, _} -> expanded_file |> List.flatten() |> Enum.reverse() end)

expanded_file_map =
  Stream.iterate(0, &(&1 + 1)) |> Enum.zip(expanded_file) |> Map.new()

part1 =
  expanded_file_map
  |> CLI.png()
  |> Enum.reduce(0, fn {index, id}, total -> total + index * id end)

part2 =
  Stream.iterate(0, &(&1 + 1))
  |> Enum.zip(file_map_array)
  |> Map.new()
  |> Enum.map(fn {key, value} -> {key, {value, if key % 2 == 0, do: floor(key / 2), else: nil}} end)
  |> IO.inspect()

# |> Enum.reduce(file_map_array, fn {index, id}, compressed_array -> total + index * id end)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
