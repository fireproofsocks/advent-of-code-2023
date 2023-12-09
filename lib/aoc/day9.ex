defmodule Aoc.Day9 do
  @moduledoc """
  Mirage Maintenance
  https://adventofcode.com/2023/day/9

  This problem deals with recursive list processing.
  This one was pretty straight-forward for me; this was the shortest amount of time
  between solving parts 1 and 2 (literally had to add 1 extra line).
  """
  @doc """

  ## Examples

      iex> Aoc.Day9.solve_pt1("priv/day9_example.txt")
      iex> Aoc.Day9.solve_pt1("priv/day9.txt")
  """
  def solve_pt1(input) do
    input
    |> parse_as_lists_of_ints()
    |> Enum.map(&find_next_val/1)
    |> Enum.sum()
  end

  @doc """
  Extrapolate backwards!
  Part 2 is the same as part 1, we just reverse the input lists.

  ## Examples

      iex> Aoc.Day9.solve_pt2("priv/day9.txt")
      iex> Aoc.Day9.solve_pt2("priv/day9_example.txt")
  """
  def solve_pt2(input) do
    input
    |> parse_as_lists_of_ints()
    |> Enum.map(fn list ->
      list
      |> Enum.reverse()
      |> find_next_val()
    end)
    |> Enum.sum()
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

  # Chomp through the lists, generating intermediary lists by accumulating the differences
  # between the first 2 numbers until you get to all zeros.
  # 1   3   6  10  15  21
  #  2   3   4   5   6
  #   1   1   1   1
  #    0   0   0
  defp find_next_val(list, acc_diffs \\ [])

  defp find_next_val([last_member], acc_diffs) do
    if Enum.all?(acc_diffs, fn x -> x == 0 end) do
      last_member
    else
      # we prepended onto the accumulator, so reverse the list before using as
      # input in the next round of processing.
      last_member + (acc_diffs |> Enum.reverse() |> find_next_val())
    end
  end

  defp find_next_val([a, b | tail], acc_diffs) do
    find_next_val([b] ++ tail, [b - a | acc_diffs])
  end
end
