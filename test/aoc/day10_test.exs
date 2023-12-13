defmodule Aoc.Day10Test do
  use ExUnit.Case, async: false
  alias Aoc.Day10
  alias Aoc.Day10.Grid
  alias Aoc.Day10.Node
  alias Aoc.Day10.Transformer

  describe "solve_pt1/1" do
    test "example 1 (simple)" do
      assert 4 = Day10.solve_pt1("priv/day10_ex1.txt")
    end

    test "example 2 (a little harder)" do
      assert 8 = Day10.solve_pt1("priv/day10_ex2.txt")
    end
  end

  describe "solve_pt2/1" do
    test "example 1 (simple)" do
      assert 1 = Day10.solve_pt2("priv/day10_ex1.txt")
    end

    test "example 2 (a little harder)" do
      assert 1 = Day10.solve_pt1("priv/day10_ex2.txt")
    end
  end

  ###############################################################
  describe "Node.connections/2" do
    test "ok" do
      grid = Grid.from_file("priv/day10_ex2.txt")

      node = %Node{
        loc: {4, 2},
        symbol: "F"
      }

      expected = MapSet.new([{4, 3}, {5, 2}])

      actual = Node.connections(grid, node.loc)
      assert MapSet.equal?(actual, expected)
    end
  end

  describe "Node.neighbors/2" do
    test "ok" do
      actual =
        MapSet.new([
          {1, 1},
          {1, 2},
          {1, 3},
          {2, 1},
          {2, 2},
          {2, 3},
          {3, 1},
          {3, 2},
          {3, 3}
        ])
        |> Node.neighbors({2, 2})

      expected = MapSet.new([{1, 2}, {2, 1}, {2, 3}, {3, 2}])
      assert MapSet.equal?(actual, expected)
    end

    test "ok for corners" do
      actual =
        MapSet.new([
          {1, 1},
          {1, 2},
          {1, 3},
          {2, 1},
          {2, 2},
          {2, 3},
          {3, 1},
          {3, 2},
          {3, 3}
        ])
        |> Node.neighbors({1, 3})

      expected = MapSet.new([{1, 2}, {2, 3}])
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

  describe "Transformer.convert_s/2" do
    test "ok F" do
      grid = Grid.from_file("priv/day10_ex1.txt")
      start_node = Grid.start_node(grid)
      assert "F" == Transformer.convert_s(grid, start_node.loc)
    end
  end

  describe "erase/2" do
    test "ok" do
      actual =
        Day10.erase(
          MapSet.new([
            {1, 1},
            {1, 3},
            {2, 1},
            {2, 3},
            {3, 1},
            {3, 3}
          ]),
          {1, 1}
        )

      expected =
        MapSet.new([
          {1, 3},
          {2, 3},
          {3, 3}
        ])

      assert MapSet.equal?(actual, expected)
    end
  end

  describe "transforming file" do
    test "foo" do
      grid = Transformer.zoom_in("priv/day10_ex1.txt", "F")
      IO.inspect(grid)
    end
  end
end
