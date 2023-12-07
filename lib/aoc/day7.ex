defmodule Aoc.Day7 do
  @moduledoc """
  Camel Poker
  https://adventofcode.com/2023/day/7

  I had already worked out a poker implementation for a job interview (!!!)
  and this borrows heavily from that.  The compile-time parsing was a pain in here
  though so I should have moved that to regular old run-time parsing.
  """
  # This special module attribute will trigger a recompile if the file changes
  # @external_resource "priv/day7_example.txt"
  @external_resource "priv/day7.txt"

  defmodule Card do
    @moduledoc """
    Defines a playing card.
    """
    defstruct [:strength, :label]

    @doc """
    Hydrates a new Card struct
    """
    def new("A"), do: %__MODULE__{label: "A", strength: 14}
    def new("K"), do: %__MODULE__{label: "K", strength: 13}
    def new("Q"), do: %__MODULE__{label: "Q", strength: 12}
    # Now J means Joker and by itself it has the weakest strength
    def new("J"), do: %__MODULE__{label: "J", strength: 1}
    def new("T"), do: %__MODULE__{label: "T", strength: 10}
    def new(val), do: %__MODULE__{label: val, strength: String.to_integer(val)}
  end

  defmodule Hand do
    @moduledoc """
    Describes a Poker hand including scoring attributes and a `compare/2` function.
    """
    defstruct [
      :str,
      :bid,
      :cards,
      :type,
      :groups
    ]

    @doc """
    Creates and scores a hand of cards
    """
    def new(raw_line) when is_binary(raw_line) do
      [hand_str, bid_str] = String.split(raw_line, " ")
      cards = hand_str |> String.graphemes() |> Enum.map(&Card.new/1)
      bid = bid_str |> String.trim() |> String.to_integer()

      grouped = group(cards)

      %__MODULE__{
        str: hand_str,
        bid: bid,
        cards: cards,
        type: calc_type(grouped),
        groups: grouped
      }
    end

    defp calc_type(%{5 => 1}), do: :five_of_a_kind
    defp calc_type(%{4 => 1}), do: :four_of_a_kind
    defp calc_type(%{3 => 1, 2 => 1}), do: :full_house
    defp calc_type(%{3 => 1}), do: :three_of_a_kind
    defp calc_type(%{2 => 2}), do: :two_pair
    defp calc_type(%{2 => 1}), do: :pair
    defp calc_type(_), do: :high_card

    @doc """
    Compares 2 `%Hand{}` structs. Used by `Enum.sort/2` to rank hands. This
    function contains all the "business logic" about how we score our poker games.

    If two hands have the same type, a secondary ordering rule takes effect!
    This is where things really start to differ from poker (!!!) -- we switch from
    playing poker to playing "war" (flip one card over at a time -- high card wins).
    I.e. in poker, you'd compare the value of set, e.g. 388 > 755 (a pair of eights
    beats a pair of fives), but in this "Camel Poker" we compare the cards in
    the order they were drawn so that 3 < 7 (based on the first card).

    Returns:

    - `:eq` when both hands are equal
    - `:gt` when hand1 outscores hand2
    - `:lt` when hand1 underscores hand2
    """
    def compare(%__MODULE__{type: t1} = h1, %__MODULE__{type: t2} = h2) when t1 == t2,
      do: secondary_ordering(h1.cards, h2.cards)

    def compare(%__MODULE__{type: :five_of_a_kind}, _), do: :gt
    def compare(_, %__MODULE__{type: :five_of_a_kind}), do: :lt
    def compare(%__MODULE__{type: :four_of_a_kind}, _), do: :gt
    def compare(_, %__MODULE__{type: :four_of_a_kind}), do: :lt
    def compare(%__MODULE__{type: :full_house}, _), do: :gt
    def compare(_, %__MODULE__{type: :full_house}), do: :lt
    def compare(%__MODULE__{type: :three_of_a_kind}, _), do: :gt
    def compare(_, %__MODULE__{type: :three_of_a_kind}), do: :lt
    def compare(%__MODULE__{type: :two_pair}, _), do: :gt
    def compare(_, %__MODULE__{type: :two_pair}), do: :lt
    def compare(%__MODULE__{type: :pair}, _), do: :gt
    def compare(_, %__MODULE__{type: :pair}), do: :lt

    # Fall back (high_card)
    def compare(%__MODULE__{cards: cards1}, %__MODULE__{cards: cards2}) do
      secondary_ordering(cards1, cards2)
    end

    defp secondary_ordering([], []), do: raise("WTF? Exactly equal?")

    defp secondary_ordering([%{strength: r1} | tail1], [%{strength: r2} | tail2]) when r1 == r2 do
      secondary_ordering(tail1, tail2)
    end

    defp secondary_ordering([%{strength: r1} | _], [%{strength: r2} | _]) when r1 > r2, do: :gt
    defp secondary_ordering([%{strength: r1} | _], [%{strength: r2} | _]) when r1 < r2, do: :lt

    # Answer the question of "how many pairs?" "how many three-of-a-kind?" etc.
    # e.g. %{2 => cnt_of_pairs, 3 => cnt_of_three_of_a_kinds} etc
    # E.g. a full house: %{2 => 1, 3 => 1}
    def group(cards) do
      joker_cnt = Enum.count(cards, fn c -> c.label == "J" end)

      groups =
        cards
        |> Enum.reject(&(&1.label == "J"))
        |> Enum.group_by(fn %{strength: strength} -> strength end)
        |> Enum.map(fn {_, cards_of_same_strength} ->
          length(cards_of_same_strength)
        end)
        |> Enum.frequencies()

      # Subtract from the one group and add to the group that includes the jokers
      # Special care for the JJJJJ case where Enum.max() chokes on an empty list
      best_group = groups |> Map.keys() |> Enum.max(&>=/2, fn -> 0 end)

      groups
      |> Map.update(best_group, 0, fn existing_val -> existing_val - 1 end)
      |> Map.update(best_group + joker_cnt, 1, fn existing_val -> existing_val + 1 end)
    end
  end

  # Compile-time fun!
  @puzzle_input @external_resource
                |> File.stream!()
                |> Enum.map(&Hand.new/1)

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
    # |> IO.inspect()
    |> Enum.with_index(1)
    # |> Enum.map(fn hand ->
    #   IO.puts(hand.str <> " " <> Hand.type(hand))
    #   hand
    # end)
    |> Enum.map(fn {%Hand{} = hand, rank} ->
      # IO.puts(String.pad_leading("#{rank}", 4) <> ". #{hand.str} #{hand.type}")
      IO.puts(String.pad_leading("#{rank}", 4) <> ". #{hand.str}")
      hand.bid * rank
    end)
    |> Enum.sum()
  end

  @doc """
  In this version J now means Joker.
  I should have created a separate module or converted to some run-time args for this
  but I didn't... I hard-coded the mapping from `J` to `1` up above and I hacked on the
  `group/1` function to handle jokers.  Have to inspect git history to see pt 1
  """
  def solve_pt2(_opts \\ []) do
    # This part is all the same. Changes are up in `Hand.new/` esp. `group/1`
    solve_pt1()
  end
end
