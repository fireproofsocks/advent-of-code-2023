defmodule Aoc.Day4 do
  @moduledoc """
  https://adventofcode.com/2023/day/4
  """

  # This special module attribute will trigger a recompile if the file changes
  @external_resource "priv/day4.txt"
  @default_puzzle_input @external_resource
                        |> File.stream!()
                        |> Enum.to_list()

  defmodule Scratchcard do
    defstruct id: nil,
              winning_numbers: MapSet.new(),
              my_numbers: MapSet.new(),
              winners_cnt: 0,
              instance_cnt: 1

    @doc "Builds a map of %Scratchcard{} structs indexed by the card number"
    def build_list([%__MODULE__{} | _] = input), do: input

    def build_list(lines) when is_list(lines) do
      lines
      |> Enum.map(fn line ->
        ["Card " <> card_num, winning_nums_str, my_numbers_str] =
          String.split(line, [":", "|"], trim: true)

        id = card_num |> String.trim() |> String.to_integer()
        winning_numbers = parse_as_mapset(winning_nums_str)
        my_numbers = parse_as_mapset(my_numbers_str)

        %__MODULE__{
          id: id,
          winning_numbers: winning_numbers,
          my_numbers: my_numbers,
          winners_cnt:
            winning_numbers
            |> MapSet.intersection(my_numbers)
            |> MapSet.size()
        }
      end)
    end

    defp parse_as_mapset(str) do
      str |> String.split(" ", trim: true) |> Enum.map(&String.trim/1) |> MapSet.new()
    end
  end

  @schematic Scratchcard.build_list(@default_puzzle_input)

  @doc """

  ## Examples

      iex> Aoc.Day4.solve_pt1()
  """
  def solve_pt1(opts \\ []) do
    puzzle_input = Keyword.get(opts, :input, @schematic)

    puzzle_input
    |> Scratchcard.build_list()
    |> Enum.map(&calc_score/1)
    |> Enum.sum()
  end

  defp calc_score(%Scratchcard{winners_cnt: 0}), do: 0
  defp calc_score(%Scratchcard{winners_cnt: cnt}), do: Integer.pow(2, cnt - 1)

  @doc """
  Gotta duplicate cards and count the number of cards
  """
  def solve_pt2(opts \\ []) do
    puzzle_input = Keyword.get(opts, :input, @schematic)

    puzzle_input
    |> Scratchcard.build_list()
    |> process()
    # Sum the instance count
    |> Enum.reduce(0, fn %Scratchcard{instance_cnt: instance_cnt}, acc -> acc + instance_cnt end)
  end

  defp process([]), do: []

  defp process([%Scratchcard{instance_cnt: instance_cnt, winners_cnt: winners_cnt} = card | tail]) do
    # Grab the next n cards
    {next_cards, rest} = Enum.split(tail, winners_cnt)
    [card | next_cards |> inc_next_cards_by_amt(instance_cnt) |> Kernel.++(rest) |> process()]
  end

  defp inc_next_cards_by_amt(cards, amt) do
    Enum.map(cards, fn c -> %Scratchcard{c | instance_cnt: c.instance_cnt + amt} end)
  end
end
