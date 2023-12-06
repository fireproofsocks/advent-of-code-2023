defmodule Aoc.Day6 do
  @moduledoc """
  https://adventofcode.com/2023/day/6

  Your toy boat has a starting speed of zero millimeters per millisecond.
  For each whole millisecond you spend at the beginning of the race holding down
  the button, the boat's speed increases by one millimeter per millisecond.

  I didn't waste time parsing for this one since the input was so simple.

  ## Part 1

      iex> Aoc.Day6.solve_pt1()
      633080

  ## Part 2

      iex> Aoc.Day6.count_ways_to_win(%Aoc.Day6.Race{duration: 34908986, distance_to_beat: 204171312101780}
      20048741
  """
  defmodule Race do
    defstruct [:duration, :distance_to_beat]
  end

  def example_input do
    [
      %Race{duration: 7, distance_to_beat: 9},
      %Race{duration: 15, distance_to_beat: 40},
      %Race{duration: 30, distance_to_beat: 200}
    ]
  end

  def actual_input do
    [
      %Race{duration: 34, distance_to_beat: 204},
      %Race{duration: 90, distance_to_beat: 1713},
      %Race{duration: 89, distance_to_beat: 1210},
      %Race{duration: 86, distance_to_beat: 1780}
    ]
  end

  def example_input_pt1 do
    %Race{duration: 71530, distance_to_beat: 940_200}
  end

  def actual_input_pt2 do
    %Race{duration: 34_908_986, distance_to_beat: 204_171_312_101_780}
  end

  # mmpms = millimeter per millisecond
  @spec count_ways_to_win(%Race{}) :: non_neg_integer()
  def count_ways_to_win(%Race{} = race) do
    1..race.duration
    |> Enum.reduce(0, fn hold_button_ms, acc ->
      speed_mmpms = hold_button_ms
      time_remaining_in_race = race.duration - hold_button_ms
      total_distance_traveled = time_remaining_in_race * speed_mmpms

      if total_distance_traveled > race.distance_to_beat do
        acc + 1
      else
        acc
      end
    end)
  end

  def multiply(list), do: Enum.reduce(list, 1, fn x, acc -> x * acc end)

  def solve_pt1(input \\ actual_input()) do
    input
    |> Enum.map(&count_ways_to_win/1)
    |> multiply()
  end
end
