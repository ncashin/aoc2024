{:ok, input} = File.read("input.txt")

defmodule Main do
end

[page_ordering, lists] =
  input
  |> String.split("\n\n", trim: true)

page_ordering_map =
  page_ordering
  |> String.split(["|", "\n"], trim: true)
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(2)
  |> Enum.reduce(Map.new(), fn [k, v], map ->
    map |> Map.update(k, [v], fn ev -> [v | ev] end)
  end)

page_lists =
  lists
  |> String.split("\n", trim: true)
  |> Enum.map(&(String.split(&1, ",", trim: true) |> Enum.map(fn a -> String.to_integer(a) end)))
  |> IO.inspect()

part1 =
  page_lists
  |> Enum.reduce(0, fn list, acc ->
    {:ok, value} = list |> Enum.fetch(floor(length(list) / 2))

    {_, is_correct} =
      list
      |> Enum.reduce(
        {list |> Map.new(fn k -> {k, false} end), true},
        fn page_number, {page_map, is_correct} ->
          {page_map |> Map.put(page_number, true),
           is_correct &&
             (page_ordering_map[page_number] == nil ||
                page_ordering_map[page_number]
                |> Enum.reduce(true, fn number, acc ->
                  acc && !page_map[number]
                end))}
        end
      )

    if is_correct,
      do: acc + value,
      else: acc
  end)

part2 =
  (page_lists
   |> Enum.map(fn page_list ->
     page_list
     |> Enum.sort(fn a, b ->
       page_ordering_map[a] != nil &&
         page_ordering_map[a]
         |> Enum.reduce(false, fn number, acc ->
           acc || number == b
         end)
     end)
     |> then(fn list ->
       IO.inspect(list)
       {:ok, value} = list |> Enum.fetch(floor(length(list) / 2))
       value
     end)
   end)
   |> Enum.sum()) - part1

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
