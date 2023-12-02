defmodule Aoc.Day1 do
  @moduledoc """
  https://adventofcode.com/2023/day/1
  No regexes; tail-recursion for string parsing.
  My use of `String.slice` is sloppy and I could do this without the intermediary
  lists and/or `Enum.reverse/1`, but the result is reasonably performant.
  """

  @digits ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

  @doc """
  ## Examples

      iex> Aoc.Day1.solve("priv/day1.2.txt")
      123
  """
  def solve(file \\ "priv/day1.txt") do
    file
    |> File.stream!()
    |> Enum.map(fn l ->
      l
      |> acc_digits([])
      |> concat_first_and_last()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  defp acc_digits("", acc), do: Enum.reverse(acc)

  defp acc_digits(<<char::binary-size(1)>> <> tail, acc) when char in @digits do
    acc_digits(tail, [char | acc])
  end

  # Remember the edge case of overlaps: oneight -> ["1", "8"]
  # that's why we don't just pass the tail, we have to advance the parser 1 char and continue
  defp acc_digits("one" <> _ = line, acc), do: acc_digits(String.slice(line, 1, 100), ["1" | acc])
  defp acc_digits("two" <> _ = line, acc), do: acc_digits(String.slice(line, 1, 100), ["2" | acc])

  defp acc_digits("three" <> _ = line, acc),
    do: acc_digits(String.slice(line, 1, 100), ["3" | acc])

  defp acc_digits("four" <> _ = line, acc),
    do: acc_digits(String.slice(line, 1, 100), ["4" | acc])

  defp acc_digits("five" <> _ = line, acc),
    do: acc_digits(String.slice(line, 1, 100), ["5" | acc])

  defp acc_digits("six" <> _ = line, acc), do: acc_digits(String.slice(line, 1, 100), ["6" | acc])

  defp acc_digits("seven" <> _ = line, acc),
    do: acc_digits(String.slice(line, 1, 100), ["7" | acc])

  defp acc_digits("eight" <> _ = line, acc),
    do: acc_digits(String.slice(line, 1, 100), ["8" | acc])

  defp acc_digits("nine" <> _ = line, acc),
    do: acc_digits(String.slice(line, 1, 100), ["9" | acc])

  # on to the next char
  defp acc_digits(<<_::binary-size(1)>> <> tail, acc), do: acc_digits(tail, acc)

  # If there's only 1 digit in the list, count it twice!
  defp concat_first_and_last([digit]), do: digit <> digit

  defp concat_first_and_last(list) do
    List.first(list) <> List.last(list)
  end
end
