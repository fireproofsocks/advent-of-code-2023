defmodule Aoc.Day10 do
  @moduledoc """
  Pipe Maze
  https://adventofcode.com/2023/day/10
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

  @doc """
  There COULD be 4 paths out of the start node (2 of them could be dead-ends, or
  there could 2 loops are defined), but the puzzle input doesn't appear that sinister:
  only *ONE* loop is defined (i.e. "S" has 2 connections). So the puzzle here is
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
end
