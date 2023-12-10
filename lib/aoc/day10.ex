defmodule Aoc.Day10 do
  @moduledoc """
  Pipe Maze
  https://adventofcode.com/2023/day/10

  https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
  """

  @type coordinate :: {x :: non_neg_integer(), y :: non_neg_integer()}
  @type grid :: %{required(coordinate) => Node.t()}

  defmodule Node do
    @type t :: %__MODULE__{}
    defstruct x: nil, y: nil, symbol: nil, visited?: false
  end
  @doc """

  There could be 4 paths out of the start node. 2 of them could be dead-ends.
  It's also possible that 2 loops are defined (but perhaps the puzzle input isn't
  that sinister?).

  Find the tile (i.e node) in the loop that is farthest from the starting position.
  ## Examples

      iex> Aoc.Day10.solve_pt1("priv/day9_example.txt")
      iex> Aoc.Day10.solve_pt1("priv/day9.txt")
  """
  def solve_pt1(input) do

    grid = parse_as_grid(input)
    dbg start = find_start(grid)

    grid
    |> neighbors({start.x, start.y})
    |> Enum.filter(fn node -> open?(start, node) end)
    |> Enum.reject(fn node -> node.visited? end)

    # |> Enum.reduce_while(fn node, acc ->
    #   if x < 5 do
    #     {:cont, acc + x}
    #   else
    #     {:halt, acc}
    #   end
    # end)
  end

  def traverse_path(node, path_acc) do

  end
  # Grid uses x, y coordinates:
  # y = the line number (starting w 0)
  # x = the character offset (starting w 0)
  @spec parse_as_grid(file :: String.t()) :: grid()
  def parse_as_grid(file) do
    file
    |> File.stream!()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, x}, acc ->
        Map.put(acc, {x, y}, %Node{
          x: x,
          y: y,
          symbol: char
        })
      end)
    end)
  end

  @spec find_start(grid :: grid()) :: Node.t()
  def find_start(grid) do
    grid
    |> Enum.find(fn {_coords, node} -> node.symbol == "S" end)
    |> elem(1)
  end

  @doc """
  Each point in the graph may have 2 to 4 neighbors. Corner points have 2,
  edge points have 3, and all others have 4.
  """
  @spec neighbors(grid :: grid(), coordinate :: coordinate()) :: [coordinate()]
  def neighbors(grid, {x, y}) do
    # north, south, east, west
    [
      Map.get(grid, {x, y - 1}),
      Map.get(grid, {x, y + 1}),
      Map.get(grid, {x - 1, y}),
      Map.get(grid, {x + 1, y})
    ]
    |> Enum.reject(&is_nil/1)
  end


  # Connections -- is it possible to connect from node1 to node2?
  # heading North, South, East, or West
  def open?(%Node{x: x1, y: y1, symbol: sym1}, %Node{x: x2, y: y2, symbol: sym2}) when x1 == x2 and (y1 - 1) == y2 and sym1 in ["S", "|", "J", "L"] and sym2 in ["S", "|", "7, F"], do: true
  def open?(%Node{x: x1, y: y1, symbol: sym1}, %Node{x: x2, y: y2, symbol: sym2}) when x1 == x2 and (y1 + 1) == y2 and sym1 in ["S", "|", "F", "7"] and sym2 in ["S", "|", "L", "J"], do: true
  def open?(%Node{x: x1, y: y1, symbol: sym1}, %Node{x: x2, y: y2, symbol: sym2}) when y1 == y2 and (x1 + 1) == x2 and sym1 in ["S", "-", "L", "F"] and sym2 in ["-", "7", "J"], do: true
  def open?(%Node{x: x1, y: y1, symbol: sym1}, %Node{x: x2, y: y2, symbol: sym2}) when y1 == y2 and (x1 - 1) == x2 and sym1 in ["S", "-", "J", "7"] and sym2 in ["-", "L", "F"], do: true
  def open?(_, _), do: false
end
