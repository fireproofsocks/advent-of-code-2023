defmodule Aoc.Day8 do
  @moduledoc """
  Haunted Wasteland
  https://adventofcode.com/2023/day/8

  I disliked this example.  As it was written, it made several bad assumptions:

  1. That the paths will form a loop
  2. That the loop will only have 1 node that ends in Z
  3. That the distance from the start node to the Z node is the same as to the next Z node.

  See this post for more info https://www.reddit.com/r/adventofcode/comments/18dn3b8/2023_day_8_part_2_a_slightly_more_general/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

  I.e. the problem as written did not rule out several train-wrecking cases that
  would render the calculations below irrelevant.
  """

  # This special module attribute will trigger a recompile if the file changes
  @external_resource "priv/day8.txt"

  @doc """

  ## Examples

      iex> Aoc.Day8.solve_pt1("priv/day8.txt")
      22411
      iex> Aoc.Day8.solve_pt1("priv/day8_ex1.txt")
      iex> Aoc.Day8.solve_pt1("priv/day8_ex2.txt")

  """
  def solve_pt1(input \\ @external_resource) do
    [dir_str, nodes_str] =
      input
      |> File.read!()
      |> String.split("\n\n")

    node_map = parse_nodes(nodes_str)

    IO.puts("Starting at #{DateTime.utc_now()}")
    traverse(dir_str, node_map, "AAA", fn node_id -> node_id == "ZZZ" end)
  end

  # Isolated this for re-use in pt2. Returns number of steps taken
  @spec traverse(
          dir_str :: String.t(),
          node_map :: map(),
          start_node :: String.t(),
          is_end_fn :: fun()
        ) :: non_neg_integer()
  defp traverse(dir_str, node_map, start_node, is_end_fn) do
    dir_str
    |> String.graphemes()
    |> Stream.cycle()
    |> Enum.reduce_while({start_node, 0}, fn
      dir, {current_node_id, steps_taken} ->
        if is_end_fn.(current_node_id) do
          {:halt, steps_taken}
        else
          next_node_id = next_node_id(node_map, current_node_id, dir)
          {:cont, {next_node_id, steps_taken + 1}}
        end
    end)
  end

  defp next_node_id(node_map, node_id, "L"), do: node_map |> Map.fetch!(node_id) |> elem(0)
  defp next_node_id(node_map, node_id, "R"), do: node_map |> Map.fetch!(node_id) |> elem(1)

  defp parse_nodes(nodes_str) do
    nodes_str
    |> String.split("\n")
    |> Enum.map(fn line ->
      <<node_id::binary-size(3)>> <>
        " = (" <> <<l::binary-size(3)>> <> ", " <> <<r::binary-size(3)>> <> _ = line

      {node_id, {l, r}}
    end)
    |> Map.new()
  end

  @doc """
  Parallelism... start on EVERY node that ends in "A". Keep going until every node
  arrived in every process ends in "Z".

  ## Examples

      iex> Aoc.Day8.solve_pt2("priv/day8.txt")
      iex> Aoc.Day8.solve_pt2("priv/day8_ex1.txt")
      iex> Aoc.Day8.solve_pt2("priv/day8_ex2.txt")

  """
  def solve_pt2(input \\ @external_resource) do
    [dir_str, nodes_str] =
      input
      |> File.read!()
      |> String.split("\n\n")

    node_map = parse_nodes(nodes_str)
    starting_nodes = all_node_ids_ending_with(node_map, "A")

    IO.puts("Starting at #{DateTime.utc_now()}")
    IO.inspect(starting_nodes, label: "Starting Nodes")

    # I don't think concurrency helps us much here, but we'll write it up for
    # possible future reference...
    starting_nodes
    |> Task.async_stream(fn start_node_id ->
      traverse(dir_str, node_map, start_node_id, fn node_id -> String.ends_with?(node_id, "Z") end)
    end)
    |> Stream.map(fn {:ok, steps} -> steps end)
    |> Enum.reduce(fn steps_cnt, acc -> trunc(steps_cnt * acc / Integer.gcd(steps_cnt, acc)) end)
  end

  defp all_node_ids_ending_with(node_map, x) do
    node_map
    |> Map.keys()
    |> Enum.filter(fn k -> String.ends_with?(k, x) end)
  end
end
