{:ok, input} = File.read("input.txt")

defmodule Main do
  def get_mul_value(string) do
    Regex.scan(~r/mul\(\d+,\d+\)/, string)
    |> List.flatten()
    |> Enum.map(&Regex.scan(~r/\d+/, &1))
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
  end

  def concat_not_nil(array, value) do
    if value != nil,
      do: [value | array],
      else: array
  end

  def unpack_reverse(x) do
    {:ok, value} = Enum.fetch(x, 0)
    String.reverse(value)
  end
end

part1 = Main.get_mul_value(input)

instructions =
  Regex.scan(
    ~r/(?s)(?<=^|do\(\))(.*?)(?=$|don't\(\))/,
    input
  )
  |> List.flatten()

part2 =
  instructions
  |> Enum.reduce(0, fn ins, accumulator ->
    accumulator + Main.get_mul_value(ins)
  end)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2 / 2}")

"""
def get_mul_value(string) do
Regex.scan(~r/mul\(\d+,\d+\)/, string)
|> Enum.map(fn [x] -> Regex.scan(~r/\d+/, x) end)
|> Enum.flat_map(fn a -> a end)
|> Enum.map(fn [x] -> String.to_integer(x) / 1 end)
|> Enum.chunk_every(2, 2, :discard)
|> Enum.map(fn [a, b] -> a * b end)
|> Enum.sum()
end
"""
