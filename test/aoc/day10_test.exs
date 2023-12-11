defmodule Aoc.Day10Test do
  use ExUnit.Case, async: false
  alias Aoc.Day10
  alias Aoc.Day10.Grid
  alias Aoc.Day10.Node

  describe "solve_pt1/1" do
    test "example 1 (simple)" do
      assert 4 = Day10.solve_pt1("priv/day10_ex1.txt")
    end

    test "example 2 (a little harder)" do
      assert 8 = Day10.solve_pt1("priv/day10_ex2.txt")
    end
  end

  describe "Node.neighbors/2" do
    test "ok" do
      grid = Grid.from_file("priv/day10_ex2.txt")

      node = %Node{
        loc: {4, 2},
        symbol: "F",
        visited?: false,
        distance: :infinity
      }

      expected =
        MapSet.new([
          %Node{loc: {3, 2}, symbol: "J"},
          %Node{loc: {5, 2}, symbol: "J"},
          %Node{loc: {4, 3}, symbol: "-"},
          %Node{loc: {4, 1}, symbol: "|"}
        ])

      actual = Node.neighbors(grid, node.loc)
      assert MapSet.equal?(actual, expected)
    end
  end

  describe "Node.open_neighbors/2" do
    test "ok 1" do
      grid = Grid.from_file("priv/day10_ex2.txt")

      node = %Node{
        loc: {4, 2},
        symbol: "F",
        visited?: false,
        distance: :infinity
      }

      expected =
        MapSet.new([
          %Node{loc: {5, 2}, symbol: "J"},
          %Node{loc: {4, 3}, symbol: "-"}
        ])

      actual = Node.open_neighbors(grid, node.loc)
      assert MapSet.equal?(actual, expected)
    end

    test "ok 2" do
      grid = Grid.from_file("priv/day10_ex2.txt")

      node = %Node{
        loc: {3, 2},
        symbol: "J"
      }

      expected =
        MapSet.new([
          %Node{loc: {3, 1}, symbol: "S"},
          %Node{loc: {2, 2}, symbol: "F"}
        ])

      actual = Node.open_neighbors(grid, node.loc)
      assert MapSet.equal?(actual, expected)
    end
  end

  describe "Node.open?/2" do
    test "J is open west to S" do
      start = %Node{loc: {3, 2}, symbol: "J"}
      west = %Node{loc: {3, 1}, symbol: "S"}
      assert Node.open?(start, west)
    end

    test "J is open north to F" do
      start = %Node{loc: {3, 2}, symbol: "J"}
      north = %Node{loc: {2, 2}, symbol: "F"}
      assert Node.open?(start, north)
    end

    test "S not open south to L" do
      start = %Node{loc: {1, 1}, symbol: "S"}
      north = %Node{loc: {1, 2}, symbol: "L"}
      refute Node.open?(start, north)
    end
  end

  describe "Grid.from_file/1" do
    test "ok" do
      assert %{
               {1, 1} => %Node{loc: {1, 1}, symbol: "|"},
               {1, 2} => %Node{loc: {1, 2}, symbol: "F"},
               {2, 1} => %Node{loc: {2, 1}, symbol: "L"},
               {2, 2} => %Node{loc: {2, 2}, symbol: "J"}
             } = Grid.from_file("priv/day10_ex0.txt")
    end
  end
end
