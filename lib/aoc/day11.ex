defmodule Aoc.Day11 do
  @moduledoc """
  Cosmic Expansion
  https://adventofcode.com/2023/day/11

  https://en.wikipedia.org/wiki/Taxicab_geometry
  https://mathbitsnotebook.com/JuniorMath/RightTriangles/RTdistance.html
  """

  @type loc :: {line_number :: non_neg_integer(), column_number :: non_neg_integer()}

  @doc """
  Not a grid the same way as Day10 (shudder), but a simple MapSet containing
  coordinates `{line_number, column_number}` referencing galaxies (`#` characters)
  """
  @spec galaxy_coords_from_file(file :: String.t()) :: MapSet.new()
  def galaxy_coords_from_file(file) do
    file
    |> File.stream!()
    |> Enum.with_index(1)
    |> Enum.reduce(MapSet.new(), fn {line, line_number}, acc ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index(1)
      |> Enum.reduce(acc, fn
        {"#", column}, acc -> MapSet.put(acc, {line_number, column})
        _, acc -> acc
      end)
    end)
  end

  @doc """
  Returns a MapSet of column numbers representing empty space
  """
  @spec empty_columns(set :: MapSet.t()) :: MapSet.t()
  def empty_columns(set) do
    non_empty_cols = set |> Enum.unzip() |> elem(1) |> MapSet.new()
    max_col = non_empty_cols |> MapSet.to_list() |> Enum.max()
    all_cols = 1..max_col |> MapSet.new()

    MapSet.difference(all_cols, non_empty_cols)
  end

  @doc """
  Returns a MapSet of row numbers representing empty space
  """
  def empty_rows(set) do
    non_empty_rows = set |> Enum.unzip() |> elem(0) |> MapSet.new()
    max_row = non_empty_rows |> MapSet.to_list() |> Enum.max()
    all_rows = 1..max_row |> MapSet.new()

    MapSet.difference(all_rows, non_empty_rows)
  end

  def max_row(set) do
    set |> Enum.unzip() |> elem(0) |> Enum.max()
  end

  def max_col(set) do
    set |> Enum.unzip() |> elem(1) |> Enum.max()
  end

  @doc """
  Calculate the "Taxicab Distance" between 2 points -- fudge the result depending on how many
  empty rows or columns get crossed.
  """
  def distance({r1, c1}, {r2, c2}, empty_rows \\ MapSet.new(), empty_cols \\ MapSet.new()) do
    expand_rows = empty_rows |> MapSet.intersection(MapSet.new(r1..r2)) |> MapSet.size()
    expand_cols = empty_cols |> MapSet.intersection(MapSet.new(c1..c2)) |> MapSet.size()
    abs(r1 - r2) + abs(c1 - c2) + expand_rows + expand_cols
  end

  def solve_pt1(file) do
    set = galaxy_coords_from_file(file)
    empty_rows = empty_rows(set)
    empty_cols = empty_columns(set)

    set
    |> Permutation.permute!(cardinality: 2)
    |> Enum.map(fn pair ->
      [coords1, coords2] = MapSet.to_list(pair)
      distance(coords1, coords2, empty_rows, empty_cols)
    end)
    |> Enum.sum()
  end
end
