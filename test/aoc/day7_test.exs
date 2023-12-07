defmodule Aoc.Day7Test do
  use ExUnit.Case, async: false
  alias Aoc.Day7
  alias Aoc.Day7.Hand

  describe "solve_pt2" do
    test "correct" do
      245_576_185 = Day7.solve_pt2()
    end
  end

  describe "new/1" do
    test "full house" do
      assert %Hand{
               str: "J2J35",
               bid: 14,
               cards: [
                 %Aoc.Day7.Card{strength: 1, label: "J"},
                 %Aoc.Day7.Card{strength: 2, label: "2"},
                 %Aoc.Day7.Card{strength: 1, label: "J"},
                 %Aoc.Day7.Card{strength: 3, label: "3"},
                 %Aoc.Day7.Card{strength: 5, label: "5"}
               ],
               type: :three_of_a_kind
             } = Hand.new("J2J35 14")
    end

    test "full house w joker" do
      assert %Hand{
               type: :full_house,
               groups: %{2 => 1, 3 => 1}
             } = Hand.new("J3QQ3 14")
    end

    test "2 pair" do
      assert %Hand{
               type: :two_pair
             } = Hand.new("227K7 14")
    end

    test "3 of a kind" do
      assert %Hand{
               type: :three_of_a_kind,
               groups: %{1 => 2, 3 => 1}
             } = Hand.new("J282T 14")
    end

    test "4 of a kind" do
      assert %Hand{
               type: :four_of_a_kind
             } = Hand.new("AAA3A 14")
    end

    test "4 of a kind w joker makes 5 of a kind" do
      assert %Hand{
               type: :five_of_a_kind
             } = Hand.new("AAAAJ 14")
    end

    test "5 jokers is 5 of a kind" do
      assert %Hand{type: :five_of_a_kind, groups: %{5 => 1}} = Hand.new("JJJJJ 14")
    end
  end
end
