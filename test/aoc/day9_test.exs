defmodule Aoc.Day9Test do
  use ExUnit.Case, async: false
  alias Aoc.Day9

  describe "solve_p1/1" do
    test "example" do
      114 = Day9.solve_pt1("priv/day9_example.txt")
    end

    test "full input" do
      1_993_300_041 = Day9.solve_pt1("priv/day9.txt")
    end
  end

  describe "solve_p1/2" do
    test "example" do
      2 = Day9.solve_pt2("priv/day9_example.txt")
    end

    test "full input" do
      1038 = Day9.solve_pt2("priv/day9.txt")
    end
  end
end
