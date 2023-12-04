defmodule AdventOfCode2023 do
  @moduledoc """
  Advent of code 2023 solution in elixir.
  """

  def extract_end(string, e) do
    if 0 > e do
      throw("no digit found on " <> string)
    else
      if string == "" do
        "0"
      else
        string
        |> String.slice(0..e)
        |> String.last()
        |> then(fn x ->
          if Regex.match?(~r/[1-9]/, x) do
            x
          else
            extract_end(string, e - 1)
          end
        end)
      end
    end
  end

  def extract_start(string, s) do
    if s > String.length(string) do
      throw("no digit found on " <> string)
    else
      if string == "" do
        "0"
      else
        string
        |> String.slice(s..String.length(string))
        |> String.first()
        |> then(fn x ->
          if Regex.match?(~r/[1-9]/, x) do
            x
          else
            extract_start(string, s + 1)
          end
        end)
      end
    end
  end

  def extract_val(string) do
    extract_start(string, 0) <> extract_end(string, String.length(string))
  end

  @doc """
  Day 1 
  ## Examples

      iex> AdventOfCode2023.day1("./example")
      142

  """
  def day1(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn e -> extract_val(e) end)
    |> Enum.map(fn e -> String.to_integer(e) end)
    |> Enum.reduce(0, fn e, acc -> e + acc end)
  end
end
