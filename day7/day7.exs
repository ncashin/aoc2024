{:ok, input} = File.read("input.txt")

defmodule NLCA do
  def hunt_elephants(desired_value, uncalibrated_sequence, value) do
    if uncalibrated_sequence == [] do
      if value == desired_value do
        desired_value
      else
        false
      end
    else
      [current | tail] = uncalibrated_sequence

      NLCA.hunt_elephants(desired_value, tail, value + current) ||
        NLCA.hunt_elephants(desired_value, tail, value * current)
    end
  end

  def hunt_sneaky_elephants(desired_value, uncalibrated_sequence, value) do
    if uncalibrated_sequence == [] do
      if value == desired_value do
        desired_value
      else
        false
      end
    else
      [current | tail] = uncalibrated_sequence

      NLCA.hunt_sneaky_elephants(desired_value, tail, value + current) ||
        NLCA.hunt_sneaky_elephants(desired_value, tail, value * current) ||
        NLCA.hunt_sneaky_elephants(
          desired_value,
          tail,
          "#{value}#{current}" |> String.to_integer()
        )
    end
  end
end

uncalibrated_mathematics =
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [result, values] = line |> String.split(":", trim: true)

    {result |> String.to_integer(),
     values |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)}
  end)

part1 =
  uncalibrated_mathematics
  |> Enum.map(fn {desired_value, uncalibrated_sequence} ->
    NLCA.hunt_elephants(desired_value, uncalibrated_sequence, 0)
  end)
  |> Enum.filter(fn a -> a end)
  |> Enum.sum()

part2 =
  uncalibrated_mathematics
  |> Enum.map(fn {desired_value, uncalibrated_sequence} ->
    NLCA.hunt_sneaky_elephants(desired_value, uncalibrated_sequence, 0)
  end)
  |> Enum.filter(fn a -> a end)
  |> Enum.sum()

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
