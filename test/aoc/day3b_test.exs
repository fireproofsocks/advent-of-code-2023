defmodule Aoc.Day3bTest do
  use ExUnit.Case, async: false
  alias Aoc.Day3b
  alias Aoc.Day3b.SchematicMap

  describe "solve_pt1/1" do
    test "example data" do
      example = """
      467..114..
      ...*......
      ..35..633.
      ......#...
      617*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
      """

      assert 467_835 = Day3b.solve_pt2(input: example |> String.split("\n"))
    end

    test "actual data" do
      assert 81_709_807 = Day3b.solve_pt2()
    end
  end

  describe "SchematicMap" do
    test "proper number coordinate mapping" do
      example = """
      467..114..
      """

      assert %SchematicMap{
               parts_coords: %{
                 {0, 0} => 0,
                 {1, 0} => 0,
                 {2, 0} => 0,
                 {5, 0} => 1,
                 {6, 0} => 1,
                 {7, 0} => 1
               }
             } = example |> String.split("\n") |> SchematicMap.build_from_input()
    end
  end
end
