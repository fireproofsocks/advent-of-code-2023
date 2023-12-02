defmodule Aoc.Day2Test do
  use ExUnit.Case, async: false
  alias Aoc.Day2
  alias Aoc.Day2.Handful

  describe "solve_pt1/4" do
    test "example input" do
      assert 8 =
               Day2.solve_pt1(12, 13, 14,
                 input: [
                   "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\n",
                   "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\n",
                   "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\n",
                   "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\n",
                   "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green\n"
                 ]
               )
    end

    test "actual puzzle input" do
      assert 2085 = Day2.solve_pt1(12, 13, 14)
    end
  end

  describe "solve_pt1/1" do
    test "actual puzzle input" do
      assert 79315 = Day2.solve_pt2()
    end
  end

  describe "Handful" do
    test "new/1" do
      assert %Handful{red: 18, blue: 0, green: 2} = Day2.Handful.new(" 18 red, 2 green\n")
    end

    test "gte?" do
      assert Handful.gte?(%Handful{red: 1, blue: 1, green: 1}, %Handful{red: 1, blue: 1, green: 1})

      assert Handful.gte?(%Handful{red: 2, blue: 2, green: 2}, %Handful{red: 1, blue: 1, green: 1})

      refute Handful.gte?(%Handful{red: 2, blue: 2, green: 2}, %Handful{red: 3, blue: 3, green: 3})
    end

    test "max" do
      assert %Handful{red: 6, blue: 7, green: 8} =
               Handful.max(%Handful{red: 6, blue: 1, green: 1}, %Handful{
                 red: 1,
                 blue: 7,
                 green: 8
               })
    end
  end
end
