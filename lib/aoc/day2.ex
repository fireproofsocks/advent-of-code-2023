defmodule Aoc.Day2 do
  @moduledoc """
  https://adventofcode.com/2023/day/2

  ## Examples

  Part 1:

      iex> Aoc.Day2.solve_pt1(12, 13, 14)

  Part 2:

      iex> Aoc.Day2.solve_pt2()
  """

  # This special module attribute will trigger a recompile if the file changes
  @external_resource "priv/day2.txt"
  @default_puzzle_input @external_resource
                        |> File.stream!()
                        |> Enum.to_list()

  defmodule Handful do
    @moduledoc "Represents a handful of cubes of different colors"
    @type t :: %__MODULE__{}
    defstruct red: 0, blue: 0, green: 0

    @doc """
    Parses raw string describing a "set" from a game into `%Handful{}` struct.

    ## Examples

        iex> Handful.new(" 18 red, 2 green\n")
        %Handful{red: 18, blue: 0, green: 2}
    """
    def new(raw_set_str) do
      raw_set_str
      |> String.split(",")
      |> Enum.reduce(%__MODULE__{}, fn raw_color, acc ->
        [num_str, color] = String.split(raw_color, " ", trim: true)

        cnt = String.to_integer(num_str)

        case String.trim(color) do
          "red" -> %{acc | red: cnt}
          "blue" -> %{acc | blue: cnt}
          "green" -> %{acc | green: cnt}
        end
      end)
    end

    @doc """
    Is handful1 greater than or equal to handful2?
    """
    @spec gte?(t(), t()) :: boolean()
    def gte?(%__MODULE__{} = h1, %__MODULE__{} = h2) do
      h1.red >= h2.red && h1.blue >= h2.blue && h1.green >= h2.green
    end

    @doc """
    Returns a struct w each attribute containing the maximum value of the 2 input structs.
    """
    @spec max(t(), t()) :: t()
    def max(%__MODULE__{} = h1, %__MODULE__{} = h2) do
      %__MODULE__{
        red: Enum.max([h1.red, h2.red]),
        blue: Enum.max([h1.blue, h2.blue]),
        green: Enum.max([h1.green, h2.green])
      }
    end
  end

  @doc """
  Which games would have been possible if the bag contained only 12 red cubes,
  13 green cubes, and 14 blue cubes? Return the sum of the game IDs.

  ## Examples

      iex> Aoc.Day2.solve_pt1(12, 13, 14)

  """
  def solve_pt1(avail_red, avail_green, avail_blue, opts \\ [])
      when is_integer(avail_red) and is_integer(avail_green) and is_integer(avail_blue) do
    puzzle_input = Keyword.get(opts, :input, @default_puzzle_input)

    available = %Handful{red: avail_red, blue: avail_blue, green: avail_green}

    puzzle_input
    |> Enum.reduce(0, fn raw_line, acc ->
      ["Game " <> game_id_str, raw_sets_str] = String.split(raw_line, ":", parts: 2)

      if is_game_possible?(raw_sets_str, available) do
        acc + String.to_integer(game_id_str)
      else
        acc
      end
    end)
  end

  @doc """
  What is the fewest number of cubes of each color that could have been in the bag
  to make the game possible?
  Sum the (red count * blue count * green count)'s and return the result.

  ## Examples

      iex> Aoc.Day2.solve_pt2()
  """
  def solve_pt2(opts \\ []) do
    puzzle_input = Keyword.get(opts, :input, @default_puzzle_input)

    puzzle_input
    |> Enum.reduce(0, fn raw_line, acc ->
      [_game_str, raw_sets_str] = String.split(raw_line, ":", parts: 2)
      reqd = game_requirements(raw_sets_str)
      acc + reqd.red * reqd.blue * reqd.green
    end)
  end

  # Returns a handful representing the minimum requirements for the given game
  # E.g. given "5 red, 6 green; 6 red; 2 blue, 3 green, 9 red; 6 green, 2 blue"
  # outputs: %Handful{red: 9, blue: 2, green: 6}
  @spec game_requirements(String.t()) :: Handful.t()
  defp game_requirements(raw_sets_str) do
    raw_sets_str
    |> String.split(";")
    |> Enum.reduce(%Handful{}, fn raw_set_str, acc ->
      Handful.max(acc, Handful.new(raw_set_str))
    end)
  end

  @spec is_game_possible?(String.t(), Handful.t()) :: boolean()
  defp is_game_possible?(raw_sets_str, available) do
    raw_sets_str
    |> String.split(";")
    |> Enum.all?(fn raw_set_str -> is_set_possible?(raw_set_str, available) end)
  end

  @spec is_set_possible?(String.t(), Handful.t()) :: boolean()
  defp is_set_possible?(raw_set_str, available) do
    Handful.gte?(available, Handful.new(raw_set_str))
  end
end
