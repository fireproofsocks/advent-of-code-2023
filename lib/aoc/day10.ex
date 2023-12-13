defmodule Aoc.Day10 do
  @moduledoc """
  Pipe Maze
  https://adventofcode.com/2023/day/10

  This is a mess of different modules... some functions should be moved
  """

  defmodule Node do
    alias Aoc.Day10.Grid
    @type t :: %__MODULE__{}
    @typedoc """
    I'm abandoning the usual mathematical x,y stuff in favor of readability:
    - `line` is the line number starting with 1
    - `column` is the character offset within a given line, starting with 1
    """
    @type loc :: {line :: non_neg_integer(), column :: non_neg_integer()}
    defstruct loc: nil, symbol: nil

    @doc """
    Returns an unordered set (i.e. a MapSet) of the location coordinates of nodes
    connected to the given location coordinate. The orientation of symbols in the
    neighboring nodes (to the North, South, East, and West) must be open to the
    connection.  Because this is a pipe maze thing, any node on the path should
    have exactly 2 connections: one in, and one out.
    """
    @spec connections(grid :: Grid.t(), loc :: loc()) :: MapSet.t()
    def connections(grid, {line, col}) do
      node1 = Map.fetch!(grid, {line, col})
      # north, south, east, west
      [
        Map.get(grid, {line - 1, col}),
        Map.get(grid, {line + 1, col}),
        Map.get(grid, {line, col + 1}),
        Map.get(grid, {line, col - 1})
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.filter(fn node2 -> open?(node1, node2) end)
      |> Enum.map(fn %Node{loc: loc} -> loc end)
      |> MapSet.new()
    end

    # Connections -- is it possible to connect from node1 to node2?
    # heading North, South, East, or West
    def open?(%Node{loc: {l1, c1}, symbol: sym1}, %Node{loc: {l2, c2}, symbol: sym2})
        when c1 == c2 and l1 - 1 == l2 and sym1 in ["S", "|", "J", "L"] and
               sym2 in ["S", "|", "7", "F"],
        do: true

    def open?(%Node{loc: {l1, c1}, symbol: sym1}, %Node{loc: {l2, c2}, symbol: sym2})
        when c1 == c2 and l1 + 1 == l2 and sym1 in ["S", "|", "F", "7"] and
               sym2 in ["S", "|", "L", "J"],
        do: true

    def open?(%Node{loc: {l1, c1}, symbol: sym1}, %Node{loc: {l2, c2}, symbol: sym2})
        when l1 == l2 and c1 + 1 == c2 and sym1 in ["S", "-", "L", "F"] and
               sym2 in ["S", "-", "7", "J"],
        do: true

    def open?(%Node{loc: {l1, c1}, symbol: sym1}, %Node{loc: {l2, c2}, symbol: sym2})
        when l1 == l2 and c1 - 1 == c2 and sym1 in ["S", "-", "J", "7"] and
               sym2 in ["S", "-", "L", "F"],
        do: true

    def open?(_, _), do: false

    @doc """
    Returns an unordered set (i.e. a MapSet) of the location coordinates of nodes
    neighboring to the given location coordinate. Every node in the grid will have
    2, 3, or 4 neighbors: corner nodes have only 2 neighbors, edge nodes have 3,
    and every other node has 4 (to the North, South, East, and West).
    Unlike `connections/2`, no criteria is evaluated to filter out nodes.
    """
    @spec neighbors(all_locs :: MapSet.t(), loc :: loc()) :: MapSet.t()
    def neighbors(all_locs, {line, col}) do
      # north, south, east, west
      [
        {line - 1, col},
        {line + 1, col},
        {line, col + 1},
        {line, col - 1}
      ]
      |> Enum.filter(fn loc -> MapSet.member?(all_locs, loc) end)
      |> MapSet.new()
    end
  end

  defmodule Grid do
    alias Aoc.Day10.Node

    @type t :: %{required(Node.loc()) => Node.t()}

    @doc """
    Parses the given file as a grid of characters using line_number, char_offset
    coordinates
    """
    @spec from_file(file :: String.t()) :: t()
    def from_file(file) do
      file
      |> File.stream!()
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {line, line_number}, acc ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.reduce(acc, fn {char, column}, acc ->
          Map.put(acc, {line_number, column}, %Node{
            loc: {line_number, column},
            symbol: char
          })
        end)
      end)
    end

    @spec start_node(grid :: t()) :: Node.t()
    def start_node(grid) do
      grid
      |> Enum.find(:not_found, fn {_coords, node} -> node.symbol == "S" end)
      |> elem(1)
    end
  end

  defmodule Transformer do
    alias Aoc.Day10.Node

    @map %{
      "|" => [
        ".|.",
        ".|.",
        ".|."
      ],
      "-" => [
        "...",
        "---",
        "..."
      ],
      "L" => [
        ".|.",
        ".L-",
        "..."
      ],
      "J" => [
        ".|.",
        "-J.",
        "..."
      ],
      "7" => [
        "...",
        "-7.",
        ".|."
      ],
      "F" => [
        "...",
        ".F-",
        ".|."
      ],
      "." => [
        "...",
        "...",
        "..."
      ],
      ## ???
      "S" => [
        "???",
        "???",
        "???"
      ]
    }
    @doc """
    Transforms the input in the given file to stretch it out by zooming in on it.

    We need to know how the `S` start character is behaving.
    """
    @spec zoom_in(file :: String.t(), s_as :: String.t()) :: Grid.t()
    def zoom_in(file, s_as) do
      file
      |> File.stream!()
      |> Enum.flat_map(fn line -> convert_line(line, s_as) end)
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {line, line_number}, acc ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.reduce(acc, fn {char, column}, acc ->
          Map.put(acc, {line_number, column}, %Node{
            loc: {line_number, column},
            symbol: char
          })
        end)
      end)
    end

    @doc """
    s_as is the character that "S" actually behaves as. We need to know its actual
    function for the conversion.
    """
    def convert_line(line, s_as) do
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(fn
        "S" ->
          [l1, <<c1::binary-size(1), _::binary-size(1), c3::binary-size(1)>>, l3] =
            Map.fetch!(@map, s_as)

          [l1, c1 <> "S" <> c3, l3]

        char ->
          Map.fetch!(@map, char)
      end)
      |> Enum.reduce(["", "", ""], fn [l1, l2, l3], [acc1, acc2, acc3] ->
        [acc1 <> l1, acc2 <> l2, acc3 <> l3]
      end)
    end

    @doc """
    S is ambiguous: its actual symbol depends on its context in the grid.
    This is sort of the opposite business logic in the `open?/2` function.
    """
    def convert_s(grid, {s_line, s_col} = s_loc) do
      connections = Node.connections(grid, s_loc)

      Enum.reduce(connections, %{}, fn
        {l, c}, acc when l == s_line and s_col - 1 == c -> Map.put(acc, :west, true)
        {l, c}, acc when l == s_line and s_col + 1 == c -> Map.put(acc, :east, true)
        {l, c}, acc when c == s_col and s_line + 1 == l -> Map.put(acc, :south, true)
        {l, c}, acc when c == s_col and s_line - 1 == l -> Map.put(acc, :north, true)
      end)
      |> case do
        %{north: _, south: _} -> "|"
        %{east: _, west: _} -> "-"
        %{north: _, east: _} -> "L"
        %{north: _, west: _} -> "J"
        %{south: _, west: _} -> "7"
        %{south: _, east: _} -> "F"
      end
    end
  end

  # special case for the starting node (where no locs have been accumulated; there
  # is no prev_loc)
  def walk(this_node, grid, []) do
    next_loc =
      grid
      |> Node.connections(this_node.loc)
      # You can run the loop in either direction... just pick one
      |> Enum.at(0)

    grid
    |> Map.fetch!(next_loc)
    |> walk(grid, [this_node.loc])
  end

  def walk(%Node{symbol: "S"}, _grid, acc), do: acc

  def walk(%Node{} = this_node, grid, [prev_loc | _] = acc) do
    # When we remove the prev_loc, there should only be 1 way forward
    [next_loc] =
      grid
      |> Node.connections(this_node.loc)
      |> MapSet.delete(prev_loc)
      |> MapSet.to_list()

    grid
    |> Map.fetch!(next_loc)
    |> walk(grid, [this_node.loc | acc])
  end

  @doc """
  There COULD be 4 paths out of the start node (2 of them could be dead-ends, or
  there could 2 loops are defined), but the puzzle input doesn't appear that sinister:
  only *ONE* loop is defined (i.e. "S" has only 2 connections). So the puzzle here is
  to traverse the pipes until we get back to "S" and see how long the path was.
  Divide by 2 will tell you how far away the furthest node was from the start.

  Find the tile (i.e node) in the loop that is farthest from the starting position.

  ## Examples

      iex> Aoc.Day10.solve_pt1("priv/day10_example.txt")
      iex> Aoc.Day10.solve_pt1("priv/day10_ex1.txt")
      iex> Aoc.Day10.solve_pt1("priv/day10.txt")
  """
  def solve_pt1(file) do
    grid = Grid.from_file(file)

    path =
      grid
      |> Grid.start_node()
      |> walk(grid, [])

    trunc(length(path) / 2)
  end

  @doc """
  In part 2 the pipe defines a boundary; How many tiles are enclosed by its loop?

  The annoying gotcha example they give is this (where `O` indicates "Outside" and
  `I` indicates "inside"):

   ```
        ..........
        .S------7.
        .|F----7|.
        .||OOOO||.
        .||OOOO||.
        .|L-7F-J|.
        .|II||II|.
        .L--JL--J.
        ..........
  ```

  That shape is subtly communicating that there is a "leak" down the bottom; i.e.
  that there is more information there that is NOT in the raw data.
  """
  def solve_pt2(file) do
    grid = Grid.from_file(file)

    # Set of all coords that are on the pipe's continuous path
    path_set =
      grid
      |> Grid.start_node()
      |> walk(grid, [])
      |> MapSet.new()

    IO.inspect(path_set)
    # #  We need the initial grid to solve for S
    # grid = Grid.from_file(file)
    # start_node = Grid.start_node(grid)

    # # What is S functioning as?
    # s_as = Transformer.convert_s(grid, start_node.loc)

    # # Now we operate on the larger grid
    # grid = Transformer.zoom_in(file, s_as)
    # # The list of loc's indicating where the pipe runs
    # pipe_keys =
    #   grid
    #   |> Grid.start_node()
    #   |> walk(grid, [])

    # # non_pipe_keys =
    # non_pipe_set = grid |> Map.drop(pipe_keys) |> Map.keys() |> MapSet.new()

    # # With the zoomed in variant, {1, 1} is guaranteed to be outside the loop
    # erase(non_pipe_set, {1, 1})
  end

  @doc """
  The functionality here is similar to a "flood" or "fill" operation in a drawing
  program: you click on a point, and all the points adjacent to it get filled
  with a color.  In our case, however, we are REMOVING points from the given set
  of points.
  """
  def erase(set, this_loc) do
    set
    |> Node.neighbors(this_loc)
    |> Enum.reduce(MapSet.delete(set, this_loc), fn loc, acc ->
      erase(acc, loc)
    end)
  end
end
