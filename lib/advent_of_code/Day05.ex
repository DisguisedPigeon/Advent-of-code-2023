defmodule Seed do
  defstruct seed: nil,
            soil: nil,
            fertilizer: nil,
            water: nil,
            light: nil,
            temperature: nil,
            humidity: nil,
            location: nil

  def parse(l) do
    Regex.scan(~r/\d+/, l)
  end
end

defmodule AdventOfCode2023.Day5 do
  @moduledoc """
  Advent of code 2023 - day 1 solution in elixir.
  """

  @doc """
  Day 3 
  ## Examples
      iex> AdventOfCode2023.day2("route/to/example.txt")
      8
  """
  def day4_p1(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def day4_p2(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> List.first()
    |> Seed.parse()
  end
end
