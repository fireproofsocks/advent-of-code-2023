defmodule Aoc.Day5 do
  @moduledoc """
  https://adventofcode.com/2023/day/4

  This solution relies on macros to define Elixir functions to do the mapping
  of the numbers.  We can't define a function clause for each number in the
  mapping, however.  Nor can we define literal maps and do something like
  `Map.get(map, number, number)` -- the ranges of numbers are too freeking big.
  Instead, we define functions with guard clauses and calculate simple offsets.
  This way, mapping has one function clause per range, plus one for the catch-all
  passthru.

  The generated functions will look something like this, where guard clauses
  capture the source range start (123) and the function calculates the output as
  an offset from destination range start (789).

      def seed_to_soil(input) when input >= 123 and input < 456 do
            offset = input - 123
            789 + offset
          end
        end)

      # Any source numbers that aren't mapped correspond to the same destination
      def seed_to_soil(unmapped), do: unmapped

  A special case is made for the `seeds/0` function (it returns a list of integers)

  Note: You have to re-compile if you swap between inputs.
  """

  # This special module attribute will trigger a recompile if the file changes
  # @external_resource "priv/day5_example.txt"
  @external_resource "priv/day5.txt"
  @external_resource
  |> File.read!()
  |> String.split([":", "\n\n"])
  |> Enum.chunk_every(2)
  |> Enum.map(fn [name, raw_input] ->
    fn_name = name |> String.replace("-", "_") |> String.trim_trailing(" map")

    case fn_name do
      "seeds" ->
        def seeds() do
          unquote(raw_input |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1))
        end

      other_fn ->
        dst_src_rng_list =
          raw_input
          |> String.split("\n", trim: true)
          |> Enum.map(fn x -> x |> String.split(" ") |> Enum.map(&String.to_integer/1) end)

        # One function def per range (thanks to guard clauses)
        Enum.each(dst_src_rng_list, fn [dest_rng_start, src_rng_start, rng] ->
          def unquote(:"#{other_fn}")(input)
              when input >= unquote(src_rng_start) and input < unquote(src_rng_start + rng) do
            offset = input - unquote(src_rng_start)
            unquote(dest_rng_start) + offset
          end
        end)

        # Any source numbers that aren't mapped correspond to the same destination
        def unquote(:"#{other_fn}")(unmapped), do: unmapped
    end
  end)

  @doc """

  ## Examples

      iex> Aoc.Day5.solve_pt1()

  """
  def solve_pt1(input \\ seeds()) do
    input
    |> Stream.map(fn seed ->
      seed
      |> seed_to_soil()
      |> soil_to_fertilizer()
      |> fertilizer_to_water()
      |> water_to_light()
      |> light_to_temperature()
      |> temperature_to_humidity()
      |> humidity_to_location()
    end)
    |> Enum.min()
  end

  def solve_pt2(_opts \\ []) do
    seeds()
    |> Stream.chunk_every(2)
    |> Stream.map(fn [range_start, len] ->
      range_end = range_start + len - 1
      range_start..range_end
    end)
    |> Stream.map(&solve_pt1/1)
    |> Enum.min()
  end
end
