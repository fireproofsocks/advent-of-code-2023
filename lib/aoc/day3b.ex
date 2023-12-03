defmodule Aoc.Day3b do
  @moduledoc """
  https://adventofcode.com/2023/day/3 PART 2
  in a separate module for my own sanity

  In this one, I tracked coordinates only for the symbol (NOT including its
  surrounding coordinates). Then I looped through those pin-point coordinates and
  used adjacent_coords to figure out the adjacent coordinates. I also switched out
  to an "allow list" for symbols vs. the catch-all "ignored" list used in pt1.

  This tactic is MUCH slower than the optimizations I found in pt1!

  Name               ips        average  deviation         median         99th %
  day3 pt1        956.03        1.05 ms     ±6.28%        1.03 ms        1.20 ms
  day3 pt2          9.04      110.63 ms     ±3.45%      109.55 ms      140.22 ms

  Comparison:
  day3 pt1        956.03
  day3 pt2          9.04 - 105.76x slower +109.58 ms

  Memory usage statistics:

  Name             average  deviation         median         99th %
  day3 pt1         0.60 MB     ±0.00%        0.60 MB        0.60 MB
  day3 pt2        38.95 MB     ±0.00%       38.95 MB       38.95 MB

  Comparison:
  day3 pt1         0.60 MB
  day3 pt2        38.95 MB - 64.67x memory usage +38.35 MB
  """

  # This special module attribute will trigger a recompile if the file changes
  @external_resource "priv/day3.txt"
  @default_puzzle_input @external_resource
                        |> File.stream!()
                        |> Enum.to_list()

  defmodule SchematicMap do
    @digits ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    @symbols ["*"]

    defstruct num_registry: %{}, symbols_coords: MapSet.new(), parts_coords: %{}, i: 0

    def build_from_input(%__MODULE__{} = input), do: input

    def build_from_input(lines) when is_list(lines) do
      lines
      |> Enum.with_index()
      |> Enum.reduce(%__MODULE__{}, fn {line, y}, acc ->
        parse_line(line, 0, y, acc)
      end)
    end

    # End of line
    def parse_line("", _x, _y, acc), do: acc

    def parse_line(<<char::binary-size(1)>> <> tail, x, y, acc) when char in @digits do
      {tail, number_str} = acc_number(tail, char)

      number = String.to_integer(number_str)
      str_len = String.length(number_str)

      # Block out all coordinates that the number occupies, points to registered number i
      number_coords_map =
        1..str_len
        |> Enum.map(fn i ->
          num_x = x + i - 1
          {{num_x, y}, acc.i}
        end)
        |> Map.new()

      acc = %{
        acc
        | num_registry: Map.put(acc.num_registry, acc.i, number),
          parts_coords: Map.merge(acc.parts_coords, number_coords_map),
          i: acc.i + 1
      }

      parse_line(tail, x + str_len, y, acc)
    end

    # only register the symbol as a single point (unlike part 1)
    def parse_line(<<char::binary-size(1)>> <> tail, x, y, acc) when char in @symbols do
      parse_line(tail, x + 1, y, %{acc | symbols_coords: MapSet.put(acc.symbols_coords, {x, y})})
    end

    # Nothing here... advance the parser
    def parse_line(<<_char::binary-size(1)>> <> tail, x, y, acc) do
      parse_line(tail, x + 1, y, acc)
    end

    # If it's a digit, accumulate it as part of the number
    def acc_number(<<char::binary-size(1)>> <> tail, acc) when char in @digits do
      acc_number(tail, acc <> char)
    end

    # Otherwise, we've hit the end of the number
    def acc_number(unparsed, num_acc), do: {unparsed, num_acc}
  end

  @schematic SchematicMap.build_from_input(@default_puzzle_input)

  @doc """
  ## Examples

      iex> Aoc.Day3.solve_pt2()
  """
  def solve_pt2(opts \\ []) do
    puzzle_input = Keyword.get(opts, :input, @schematic)

    puzzle_input
    |> SchematicMap.build_from_input()
    |> find_gear_ratios()
    |> Enum.sum()
  end

  # A gear is any * symbol that is adjacent to exactly two part numbers
  defp find_gear_ratios(%SchematicMap{} = schema) do
    schema.symbols_coords
    |> Enum.map(fn {x, y} ->
      schema.parts_coords
      |> Map.keys()
      |> MapSet.new()
      |> MapSet.intersection(adjacent_coords(x, y))
      |> Enum.map(fn xy_coord -> Map.fetch!(schema.parts_coords, xy_coord) end)
      |> Enum.uniq()
      |> Enum.map(fn number_id ->
        Map.fetch!(schema.num_registry, number_id)
      end)
      |> case do
        # must be adjacent to exactly 2 numbers
        [num1, num2] -> num1 * num2
        _ -> 0
      end
    end)
  end

  defp adjacent_coords(x, y) do
    for x2 <- (x - 1)..(x + 1), y2 <- (y - 1)..(y + 1), reduce: MapSet.new() do
      acc2 ->
        MapSet.put(acc2, {x2, y2})
    end
  end
end
