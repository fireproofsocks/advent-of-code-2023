defmodule Aoc.Day9 do
  @moduledoc """
  Mirage Maintenance
  https://adventofcode.com/2023/day/9

  """
  @doc """

  ## Examples

      iex> Aoc.Day9.solve_pt1("priv/day9_example.txt")
      iex> Aoc.Day9.solve_pt1("priv/day9.txt")
  """
  def solve_pt1(input \\ @external_resource) do
    input
    |> parse_as_lists_of_ints()
    |> Enum.map(&find_next_predicted_val/1)
    |> Enum.sum()
  end

  @doc """

  ## Examples

      iex> Aoc.Day9.solve_pt2("priv/day9.txt")
      iex> Aoc.Day9.solve_pt2("priv/day9_example.txt")
  """
  def solve_pt2(input) do
    # TODO
    input
  end

  defp parse_as_lists_of_ints(file) do
    file
    |> File.stream!()
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(fn num_str ->
        num_str |> String.trim() |> String.to_integer()
      end)
    end)
  end

  defp find_next_predicted_val(list) do
    process(list)
  end

  @doc """
  1   3   6  10  15  21
   2   3   4   5   6
    1   1   1   1
      0   0   0
  """
  def process(list, acc_diffs \\ [])

  def process([last_member], acc_diffs) do
    if Enum.all?(acc_diffs, fn x -> x == 0 end) do
      last_member
    else
      last_member + (acc_diffs |> Enum.reverse() |> process([]))
    end
  end

  def process([a, b | tail], acc_diffs) do
    process([b] ++ tail, [b - a | acc_diffs])
  end
end
