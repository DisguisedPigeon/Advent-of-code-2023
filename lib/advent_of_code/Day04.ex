defmodule Card do
  defstruct num: nil, win: [], roll: []

  def parse(string) do
    [gameInfo, numstrs] = string |> String.split(":", trim: true)

    [win, roll | _] =
      numstrs
      |> String.split("|", trim: true)
      |> Enum.map(fn str -> Regex.scan(~r/\d+/, str) end)
      |> Enum.map(fn l ->
        l
        |> List.flatten()
        |> Enum.map(fn e -> String.to_integer(e) end)
      end)

    gameInfo =
      Regex.run(~r/Card +(\d+)/, gameInfo)
      |> List.last()
      |> String.to_integer()

    %Card{num: gameInfo, win: win, roll: roll}
  end

  def count_wins(card) do
    card.roll
    |> Enum.reduce(0, fn e, acc ->
      is_winner = Enum.any?(card.win, fn w -> w == e end)

      if is_winner do
        acc + 1
      else
        acc
      end
    end)
  end
end

defmodule AdventOfCode2023.Day4 do
  @moduledoc """
  Advent of code 2023 - day 1 solution in elixir.
  """
  defp calc_heads(acc_cardnum, hits) do
    case acc_cardnum do
      0 -> []
      _ -> [hits | calc_heads(acc_cardnum - 1, hits)]
    end
  end

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
    |> Enum.map(&Card.parse(&1))
    |> Enum.map(&Card.count_wins(&1))
    |> Enum.filter(fn e -> e != 0 end)
    |> Enum.map(fn e -> Integer.pow(2, e - 1) end)
    |> Enum.sum()
  end

  def day4_p2(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Card.parse(&1))
    |> Enum.map(&Card.count_wins(&1))
    |> Enum.reduce(
      {0, []},
      fn e, acc ->
        acc_cardnum = 1 + Enum.count(elem(acc, 1))
        acc = {elem(acc, 0), Enum.filter(elem(acc, 1), fn e -> e != 0 end)}

        {
          elem(acc, 0) + acc_cardnum,
          [calc_heads(acc_cardnum, e) | elem(acc, 1) |> Enum.map(fn e -> e - 1 end)]
          |> List.flatten()
          |> Enum.filter(fn e -> e != 0 end)
        }
      end
    )
    |> elem(0)
  end
end
