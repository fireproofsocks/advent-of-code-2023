defmodule Aoc.Day7 do
  @moduledoc """
  Camel Poker
  https://adventofcode.com/2023/day/7
  """
  # This special module attribute will trigger a recompile if the file changes
  # @external_resource "priv/day7_example.txt"
  @external_resource "priv/day7.txt"

  defmodule Card do
    @moduledoc """
    Defines a playing card.
    """
    defstruct [:rank, :label]

    @doc """
    Hydrates a new Card struct
    """
    def new("A"), do: %__MODULE__{label: "A", rank: 14}
    def new("K"), do: %__MODULE__{label: "K", rank: 13}
    def new("Q"), do: %__MODULE__{label: "Q", rank: 12}
    def new("J"), do: %__MODULE__{label: "J", rank: 11}
    def new("T"), do: %__MODULE__{label: "T", rank: 10}
    def new(val), do: %__MODULE__{label: val, rank: String.to_integer(val)}

    @doc """
    Compares 2 `%Card{}` structs. Used by `Enum.sort/2` to rank cards.

    Returns:

    - `:eq` when both cards are equal
    - `:gt` when card1 is greater than card2
    - `:gl` when card1 is less than card2
    """
    def compare(%__MODULE__{rank: rank1}, %__MODULE__{rank: rank2}) when rank1 == rank2,
      do: :eq

    def compare(%__MODULE__{rank: rank1}, %__MODULE__{rank: rank2}) when rank1 > rank2,
      do: :gt

    def compare(%__MODULE__{rank: rank1}, %__MODULE__{rank: rank2}) when rank1 < rank2,
      do: :lt
  end

  defmodule Hand do
    @moduledoc """
    Describes a Poker hand including scoring attributes and a `compare/2` function.
    """
    defstruct [
      :bid,
      :cards,
      :five_of_a_kind?,
      :four_of_a_kind?,
      :full_house?,
      :three_of_a_kind?,
      :two_pair?,
      :pair?,
      # :high_card_in_set,
      :high_card
    ]

    @doc """
    Creates and scores a hand of cards
    """
    def new(cards, bid \\ 0) when is_list(cards) do
      grouped = group(cards)

      %__MODULE__{
        bid: bid,
        cards: cards,
        five_of_a_kind?: Map.has_key?(grouped, 5),
        four_of_a_kind?: Map.has_key?(grouped, 4),
        full_house?: Map.has_key?(grouped, 3) and Map.has_key?(grouped, 2),
        three_of_a_kind?: Map.has_key?(grouped, 3),
        two_pair?: length(Map.get(grouped, 2, [])) == 2,
        pair?: Map.has_key?(grouped, 2),
        # high_card_in_set: high_card_in_set(grouped),
        high_card: all_distinct?(cards)
      }
    end

    @doc """
    Compares 2 `%Hand{}` structs. Used by `Enum.sort/2` to rank hands. This
    function contains all the "business logic" about how we score our poker games.

    Returns:

    - `:eq` when both hands are equal
    - `:gt` when hand1 outscores hand2
    - `:gl` when hand1 underscores hand2
    """
    def compare(%__MODULE__{five_of_a_kind?: true}, %__MODULE__{five_of_a_kind?: false}), do: :gt
    def compare(%__MODULE__{five_of_a_kind?: false}, %__MODULE__{five_of_a_kind?: true}), do: :lt
    def compare(%__MODULE__{four_of_a_kind?: true}, %__MODULE__{four_of_a_kind?: false}), do: :gt
    def compare(%__MODULE__{four_of_a_kind?: false}, %__MODULE__{four_of_a_kind?: true}), do: :lt
    def compare(%__MODULE__{full_house?: true}, %__MODULE__{full_house?: false}), do: :gt
    def compare(%__MODULE__{full_house?: false}, %__MODULE__{full_house?: true}), do: :lt

    def compare(%__MODULE__{three_of_a_kind?: true}, %__MODULE__{three_of_a_kind?: false}),
      do: :gt

    def compare(%__MODULE__{three_of_a_kind?: false}, %__MODULE__{three_of_a_kind?: true}),
      do: :lt

    def compare(%__MODULE__{two_pair?: true}, %__MODULE__{two_pair?: false}), do: :gt
    def compare(%__MODULE__{two_pair?: false}, %__MODULE__{two_pair?: true}), do: :lt
    def compare(%__MODULE__{pair?: true}, %__MODULE__{pair?: false}), do: :gt
    def compare(%__MODULE__{pair?: false}, %__MODULE__{pair?: true}), do: :lt

    # A little weird here... this should only kick in when all cards' labels are
    # all distinct see all_distinct?/1
    def compare(%__MODULE__{high_card: true}, %__MODULE__{high_card: false}), do: :gt
    def compare(%__MODULE__{high_card: false}, %__MODULE__{high_card: true}), do: :lt


    # If two hands have the same type, a second ordering rule takes effect.
    # This is where things really start to differ from poker (!!!) -- we
    # basically switch from playing poker to playing "war".
    # Normally you'd compare the high card in a set (e.g. 3888 > 7555),
    # but here we compare the cards in the hand in the order they were drawn
    # so that 3 < 7 (based on the first card)
    def compare(%__MODULE__{cards: cards1}, %__MODULE__{cards: cards2}) do
      secondary_ordering(cards1, cards2)
    end

    defp secondary_ordering([], []), do: raise "WTF? Exactly equal?"
    defp secondary_ordering([%{rank: r1} | tail1], [%{rank: r2} | tail2]) when r1 == r2 do
      secondary_ordering(tail1, tail2)
    end
    defp secondary_ordering([%{rank: r1} | _], [%{rank: r2} | _]) when r1 > r2, do: :gt
    defp secondary_ordering([%{rank: r1} | _], [%{rank: r2} | _]) when r1 < r2, do: :lt

    defp all_distinct?(cards) when is_list(cards) do
      uniques_len = cards
      |> Enum.map(& &1.rank)
      |> Enum.uniq()
      |> length()

      uniques_len == length(cards)
    end

    # group any pairs, triples, four-of-a-kind, five-of-a-kind together
    # e.g. %{2 => [pair1], 3 => [three_of_a_kind]}
    defp group(cards) do
      cards
      |> Enum.group_by(fn %{rank: rank} -> rank end)
      |> Enum.reduce(%{}, fn {_, vals}, acc ->
        case length(vals) do
          1 ->
            acc

          x ->
            existing = Map.get(acc, x, [])
            Map.put(acc, x, [vals | existing])
        end
      end)
    end
  end

  @puzzle_input @external_resource
                |> File.stream!()
                |> Enum.map(fn line ->
                  [hand_str, bid_str] = String.split(line, " ")
                  cards = hand_str |> String.graphemes() |> Enum.map(&Card.new/1)
                  bid = bid_str |> String.trim() |> String.to_integer()
                  Hand.new(cards, bid)
                end)

  @doc """
  Determine the total winnings of this set of hands by adding up the result of
  multiplying each hand's bid with its rank

  ## Examples

      iex> Aoc.Day7.solve_pt1()

  Using Sample input: 6440
  Actual input: 248217452
  """
  def solve_pt1() do
    @puzzle_input
    |> Enum.sort({:asc, Hand})
    |> IO.inspect()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {%Hand{bid: bid}, i}, acc -> acc + bid * i end)
  end

  def solve_pt2(_opts \\ []) do
  end
end
