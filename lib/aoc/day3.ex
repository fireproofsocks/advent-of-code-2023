defmodule Aoc.Day3 do
  @moduledoc """
  https://adventofcode.com/2023/day/3

  The strategy here is to parse the "schematic" of parts into a `%SchematicMap{}`
  struct that uses coordinates to track if a given location contains a part-number
  or a symbol. I tracked symbols not only as a point, but as ALL THE SPACE around
  that point (i.e. 9 coordinates). This made it easy to rely on MapSet to return
  any overlapping coordinates (i.e. any part-numbers adjacent with a symbol).
  """

  # This special module attribute will trigger a recompile if the file changes
  @external_resource "priv/day3.txt"
  @default_puzzle_input @external_resource
                        |> File.stream!()
                        |> Enum.to_list()

  defmodule SchematicMap do
    @digits ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    @ignored [".", "\n"]

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

    # Advance the parser
    def parse_line(<<char::binary-size(1)>> <> tail, x, y, acc) when char in @ignored do
      parse_line(tail, x + 1, y, acc)
    end

    # Everything not a digit and not ignored is a symbol...
    def parse_line(<<_char::binary-size(1)>> <> tail, x, y, acc) do
      # Register the symbol AND the area around it
      this_symbol_coords =
        for x2 <- (x - 1)..(x + 1), y2 <- (y - 1)..(y + 1), reduce: acc.symbols_coords do
          acc2 ->
            MapSet.put(acc2, {x2, y2})
        end

      parse_line(tail, x + 1, y, %{
        acc
        | symbols_coords: MapSet.union(acc.symbols_coords, this_symbol_coords)
      })
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

      iex> Aoc.Day3.solve_pt1()
  """
  def solve_pt1(opts \\ []) do
    puzzle_input = Keyword.get(opts, :input, @schematic)

    puzzle_input
    |> SchematicMap.build_from_input()
    |> find_parts_adjacent_to_symbol()
    |> Enum.sum()
  end

  defp find_parts_adjacent_to_symbol(%SchematicMap{} = schema) do
    schema.parts_coords
    |> Map.keys()
    |> MapSet.new()
    |> MapSet.intersection(schema.symbols_coords)
    |> Enum.map(fn xy_coord ->
      Map.fetch!(schema.parts_coords, xy_coord)
    end)
    |> Enum.uniq()
    |> Enum.map(fn number_id ->
      Map.fetch!(schema.num_registry, number_id)
    end)
  end
end
