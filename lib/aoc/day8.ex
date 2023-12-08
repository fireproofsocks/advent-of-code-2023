defmodule Aoc.Day8 do
  @moduledoc """
  Haunted Wasteland
  https://adventofcode.com/2023/day/8


  """

  # This special module attribute will trigger a recompile if the file changes
  @external_resource "priv/day8.txt"

  @doc """

  ## Examples

      iex> Aoc.Day8.solve_pt1("priv/day8.txt")
      iex> Aoc.Day8.solve_pt1("priv/day8_ex1.txt")
      iex> Aoc.Day8.solve_pt1("priv/day8_ex2.txt")

  """
  def solve_pt1(input \\ @external_resource) do
    [lr_str, nodes_str] =
      input
      |> File.read!()
      |> String.split("\n\n")

    node_map = parse_nodes(nodes_str)

    IO.puts("Starting at #{DateTime.utc_now()}")

    lr_str
    |> String.graphemes()
    |> Stream.cycle()
    |> Enum.reduce_while({"AAA", 0}, fn
      _, {"ZZZ", steps_taken} ->
        IO.puts("Finishing at #{DateTime.utc_now()}")
        {:halt, steps_taken}

      step, {current_node_id, steps_taken} ->
        fork = Map.fetch!(node_map, current_node_id)

        next_node_id =
          case step do
            "L" -> elem(fork, 0)
            "R" -> elem(fork, 1)
          end

        {:cont, {next_node_id, steps_taken + 1}}
    end)
  end

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

  # def solve_pt2(input \\ @external_resource) do

  # end
end
