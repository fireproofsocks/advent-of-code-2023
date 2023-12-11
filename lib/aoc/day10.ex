defmodule Aoc.Day10 do
  @moduledoc """
  Pipe Maze
  https://adventofcode.com/2023/day/10

  https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
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
    defstruct loc: nil, symbol: nil, visited?: false, distance: :infinity

    @doc """
    Get a MapSet (i.e. unordered set) of the nodes neighboring the given location
    coordinate. Each point in the graph may have 2 to 4 neighbors. Corner points
    have 2, edge points have 3, and all others have 4.
    """
    @spec neighbors(grid :: Grid.t(), loc :: loc()) :: MapSet.t()
    def neighbors(grid, {line, col}) do
      # north, south, east, west
      [
        Map.get(grid, {line - 1, col}),
        Map.get(grid, {line + 1, col}),
        Map.get(grid, {line, col + 1}),
        Map.get(grid, {line, col - 1})
      ]
      |> Enum.reject(&is_nil/1)
      |> MapSet.new()
    end

    def open_neighbors(grid, loc) do
      this_node = Map.fetch!(grid, loc)
      grid
      |> neighbors(loc)
      |> Enum.filter(fn next_node -> open?(this_node, next_node) end)
      |> MapSet.new()
    end

    def unvisited_open_neighbors(grid, loc) do
      grid
      |> open_neighbors(loc)
      |> Enum.reject(fn next_node -> next_node.visited? end)
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

    def visit(grid, loc) do
      this_node = Map.fetch!(grid, loc)
      IO.inspect(this_node, label: "ARRIVING AT THIS NODE")
      # Update this node as visited
      grid = Grid.update!(grid, this_node, visited?: true)

      open_neighbors = open_neighbors(grid, loc)
      tentative_distance = this_node.distance + 1

      IO.inspect(open_neighbors, label: "ALL OPEN NEIGHBORS (#{tentative_distance})")
      # Update distances to all open neighbors, even ones we may have already visited!
      # This is important so we can update them with the shortest path
      grid =
        open_neighbors
        |> Enum.reduce(grid, fn next_node, grid ->
          # Compare the newly calculated tentative distance to the one currently assigned
          # to the neighbor and assign it the smaller one.
          # tentative_distance = this_node.distance + 1

          new_distance =
            cond do
              next_node.distance == :infinity -> tentative_distance
              next_node.distance < tentative_distance -> next_node.distance
              true -> tentative_distance
            end

          Grid.update!(grid, next_node, distance: new_distance)
        end)

      # Requery the grid to ensure we have updated data
      unvisited_neighbors = unvisited_open_neighbors(grid, loc)

      IO.inspect(unvisited_neighbors, label: "Unvisited Open NEIGHBORS")

      unvisited_neighbors
      |> Enum.reduce(grid, fn next_node, grid ->
        visit(grid, next_node.loc)
      end)
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

    @spec update!(grid :: t(), node :: Node.t(), new_data :: keyword()) :: t()
    def update!(grid, %Node{loc: loc}, new_data) do
      node = Map.fetch!(grid, loc)
      Map.put(grid, loc, Enum.reduce(new_data, node, fn {k, v}, acc -> Map.put(acc, k, v) end))
    end
  end

  @doc """

  There COULD be 4 paths out of the start node (2 of them could be dead-ends, or
  there could 2 loops are defined), but the puzzle input isn't that sinister: only
  one loop is defined, so the S node has only 2 paths.

  Find the tile (i.e node) in the loop that is farthest from the starting position.
  ## Examples

      iex> Aoc.Day10.solve_pt1("priv/day10_example.txt")
      iex> Aoc.Day10.solve_pt1("priv/day10_ex1.txt")
      iex> Aoc.Day10.solve_pt1("priv/day10.txt")
  """
  def solve_pt1(file) do
    grid = Grid.from_file(file)
    start_node = Grid.start_node(grid)

    grid
    |> Grid.update!(start_node, distance: 0)
    |> Node.visit(start_node.loc)
    |> Enum.reject(fn {_, %Node{distance: distance}} -> distance == :infinity end)
    |> Enum.map(fn {_, %Node{distance: distance}} -> distance end)
    |> Enum.max()
  end
end
