defmodule AdventOfCode2023.Day1 do
  @moduledoc """
  Advent of code 2023 - day 1 solution in elixir.
  """

  def matchNumber(_ = "one" <> _) do
    "1"
  end

  def matchNumber(_ = "two" <> _) do
    "2"
  end

  def matchNumber(_ = "three" <> _) do
    "3"
  end

  def matchNumber(_ = "four" <> _) do
    "4"
  end

  def matchNumber(_ = "five" <> _) do
    "5"
  end

  def matchNumber(_ = "six" <> _) do
    "6"
  end

  def matchNumber(_ = "seven" <> _) do
    "7"
  end

  def matchNumber(_ = "eight" <> _) do
    "8"
  end

  def matchNumber(_ = "nine" <> _) do
    "9"
  end

  def matchNumber(_) do
    nil
  end

  defp extract_end(string, e) do
    if 0 > e do
      throw("no digit found on " <> string)
    else
      if string == "" do
        "0"
      else
        string
        |> String.slice(0..e)
        |> then(fn x ->
          if Regex.match?(~r/.*\d$/, x) do
            String.last(x)
          else
            if (val = matchNumber(String.slice(string, e..String.length(string)))) != nil do
              val
            else
              extract_end(string, e - 1)
            end
          end
        end)
      end
    end
  end

  defp extract_start(string, s) do
    if s > String.length(string) do
      throw("no digit found on " <> string)
    else
      if string == "" do
        "0"
      else
        string
        |> String.slice(s..String.length(string))
        |> then(fn x ->
          if Regex.match?(~r/^\d/, x) do
            String.first(x)
          else
            if (val = matchNumber(x)) != nil do
              val
            else
              extract_start(string, s + 1)
            end
          end
        end)
      end
    end
  end

  defp extract_val(string) do
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
