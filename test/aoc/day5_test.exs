defmodule Aoc.Day5Test do
  use ExUnit.Case, async: false
  alias Aoc.Day5

  describe "solve_pt1" do
    test "actual" do
      assert 662_197_086 == Day5.solve_pt1()
    end
  end

  describe "solve_pt2" do
    test "takes a couple mins!" do
      assert 52_510_809 == Day5.solve_pt2()
    end
  end
end
