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

    @spec row(t(), non_neg_integer()) :: [String.t()]
    def row(grid, row_number) do
      grid
      |> Map.keys()
      |> Enum.filter(fn {row, _col} -> row == row_number end)
      |> Enum.sort()
      |> Enum.map(fn loc -> Map.fetch!(grid, loc).symbol end)
    end

    def row_cnt(grid) do
      grid
      |> Map.keys()
      |> Enum.unzip()
      |> elem(0)
      |> Enum.max()
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
  S is ambiguous: its actual symbol depends on its context in the grid.
  This is sort of the opposite business logic in the `open?/2` function.
  """
  def s_is_a(grid, {s_line, s_col} = s_loc) do
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

  @doc """
  Operates on a cleaned up grid where the `S` has been converted to its functional
  role and any characters not on the pipe-path have been replaced with a `.`.

  F J is equivalent to a full transition (|)... flip state!
  F 7 is sort of a "failed" transition... go back to whatever your state was
  L 7 is equivalent to a full transition (|)
  L J is sort of a "failed" transition... flip state!

  `state` represents whether you are:
    - fully inside the loop (start counting!
    - fully outside the loop

  `opening` is like the "opening tag" of a pair. E.g. the "F" in an "FJ" pair.
  This is need to help us track with being halfway in or out
  """

  def count_inside_tiles_in_row(row_nodes_list, opening \\ nil, state \\ false, cnt \\ 0)
  def count_inside_tiles_in_row([], _, _, cnt), do: cnt

  # Full transition: flip state immediately!
  def count_inside_tiles_in_row(["|" | tail], _opening, state, cnt) do
    count_inside_tiles_in_row(tail, "|", !state, cnt)
  end

  def count_inside_tiles_in_row(["-" | tail], opening, state, cnt) do
    count_inside_tiles_in_row(tail, opening, state, cnt)
  end

  # Open an F tag
  def count_inside_tiles_in_row(["F" | tail], _, state, cnt) do
    count_inside_tiles_in_row(tail, "F", state, cnt)
  end

  # Open an L tag
  def count_inside_tiles_in_row(["L" | tail], _, state, cnt) do
    count_inside_tiles_in_row(tail, "L", state, cnt)
  end

  # complete FJ transition --> flip state!
  def count_inside_tiles_in_row(["J" | tail], "F", state, cnt) do
    count_inside_tiles_in_row(tail, nil, !state, cnt)
  end

  # F7 = incomplete. nil out the opening tag
  def count_inside_tiles_in_row(["7" | tail], "F", state, cnt) do
    count_inside_tiles_in_row(tail, nil, state, cnt)
  end

  # complete L7 transition --> flip state
  def count_inside_tiles_in_row(["7" | tail], "L", state, cnt) do
    count_inside_tiles_in_row(tail, nil, !state, cnt)
  end

  # LJ = incomplete. nil out the opening tag
  def count_inside_tiles_in_row(["J" | tail], "L", state, cnt) do
    count_inside_tiles_in_row(tail, nil, state, cnt)
  end

  # if you are INSIDE the loop, start counting dots!!
  def count_inside_tiles_in_row(["." | tail], opening, true, cnt) do
    count_inside_tiles_in_row(tail, opening, true, cnt + 1)
  end

  # catch-all: just advance the parser
  def count_inside_tiles_in_row([_ | tail], opening, state, cnt) do
    count_inside_tiles_in_row(tail, opening, state, cnt)
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

    start_node = Grid.start_node(grid)

    # Set of all coords that are on the pipe's continuous path
    path_set =
      start_node
      |> walk(grid, [])
      |> MapSet.new()

    # Replace the S with the character it gets used as
    s = s_is_a(grid, start_node.loc)
    grid = Map.put(grid, start_node.loc, %{start_node | symbol: s})

    # Replaces any non-pipe character with a "."
    grid = clean_junk_from_grid(grid, path_set)

    1..Grid.row_cnt(grid)
    |> Enum.map(fn r ->
      grid
      |> Grid.row(r)
      |> count_inside_tiles_in_row()
    end)
    |> Enum.sum()
  end

  @spec clean_junk_from_grid(Grid.t(), MapSet.t()) :: Grid.t()
  def clean_junk_from_grid(grid, path_set) do
    grid
    |> Enum.map(fn {loc, node} ->
      if MapSet.member?(path_set, loc) do
        {loc, node}
      else
        {loc, %{node | symbol: "."}}
      end
    end)
    |> Enum.into(%{})
  end
end
