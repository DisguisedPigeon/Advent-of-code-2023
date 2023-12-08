defmodule AdventOfCode2023.Day3 do
  @moduledoc """
  Advent of code 2023 - day 1 solution in elixir.
  """

  defp char_to_string(e) do
    if e != nil and e >= ?0 and e <= ?9 do
      <<e>>
    else
      ""
    end
  end

  defp is_before(index, str) do
    str
    |> Enum.at(index - 1)
    |> char_to_string()
    |> Integer.parse()
    |> case do
      :error ->
        false

      {_n, ""} ->
        true
    end
  end

  defp is_after(index, str) do
    str
    |> Enum.at(index + 1)
    |> char_to_string()
    |> Integer.parse()
    |> case do
      :error ->
        false

      {_n, ""} ->
        true
    end
  end

  defp is_on(index, str) do
    str
    |> Enum.at(index)
    |> char_to_string()
    |> Integer.parse()
    |> case do
      :error ->
        false

      {_n, ""} ->
        true
    end
  end

  defp filter_number(_clist = []) do
    []
  end

  defp filter_number(_clist = [h | t]) do
    if h >= ?0 and h <= ?9 do
      [h | filter_number(t)]
    else
      []
    end
  end

  defp get_before(index, str) do
    str
    |> Enum.slice(0..(index - 1))
    |> Enum.reverse()
    |> filter_number()
    |> Enum.reverse()
    |> Enum.reduce(<<>>, fn e, acc ->
      acc <> <<e>>
    end)
  end

  defp get_after(index, str) do
    str
    |> Enum.slice((index + 1)..(Enum.count(str) - 1))
    |> filter_number()
    |> Enum.reduce(<<>>, fn e, acc ->
      acc <> <<e>>
    end)
  end

  defp get_on_after(index, str) do
    str
    |> Enum.slice(index..(Enum.count(str) - 1))
    |> filter_number()
    |> Enum.reduce(<<>>, fn e, acc ->
      acc <> <<e>>
    end)
  end

  defp get_on_before(index, str) do
    str
    |> Enum.slice(0..index)
    |> Enum.reverse()
    |> filter_number()
    |> Enum.reverse()
    |> Enum.reduce(<<>>, fn e, acc ->
      acc <> <<e>>
    end)
  end

  defp get_all(index, str) do
    (str
     |> Enum.slice(0..(index - 1))
     |> Enum.reverse()
     |> filter_number()
     |> Enum.reverse()
     |> Enum.reduce(<<>>, fn e, acc ->
       acc <> <<e>>
     end)) <>
      (str
       |> Enum.slice(index..(Enum.count(str) - 1))
       |> filter_number()
       |> Enum.reduce(<<>>, fn e, acc ->
         acc <> <<e>>
       end))
  end

  defp get_on_only(index, str) do
    <<str |> Enum.at(index)>>
  end

  defp get_hor(index, str) do
    if is_on(index, str) do
      [
        if is_after(index, str) and not is_before(index, str) do
          get_on_after(index, str) |> String.to_integer()
        else
          0
        end,
        if is_before(index, str) and not is_after(index, str) do
          get_on_before(index, str) |> String.to_integer()
        else
          0
        end,
        if is_before(index, str) and is_after(index, str) do
          get_all(index, str) |> String.to_integer()
        else
          0
        end,
        if not is_before(index, str) and not is_after(index, str) do
          get_on_only(index, str) |> String.to_integer()
        else
          0
        end
      ]
    else
      [
        if is_before(index, str) do
          get_before(index, str) |> String.to_integer()
        else
          0
        end,
        if is_after(index, str) do
          get_after(index, str) |> String.to_integer()
        else
          0
        end
      ]
    end
  end

  defp adj_nums(_indexes = [], _lprev, _lcurr, _lnext) do
    []
  end

  defp adj_nums(_indexes = [h | t], lprev, lcurr, lnext) do
    [
      get_hor(h, lprev),
      get_hor(h, lcurr),
      get_hor(h, lnext) | adj_nums(t, lprev, lcurr, lnext)
    ]
  end

  defp is_symbol?(c) do
    not (c == ?. or (c >= ?0 and c <= ?9))
  end

  defp symbol_idx(l) do
    symbol_idx(l, 0)
  end

  defp symbol_idx(_ = [h | t], idx) do
    if is_symbol?(h) do
      [idx | symbol_idx(t, idx + 1)]
    else
      symbol_idx(t, idx + 1)
    end
  end

  defp symbol_idx(_ = [], _idx) do
    []
  end

  defp get_adj_nums(_l = [h1, h2 | []], _is_first) do
    [symbol_idx(h2) |> adj_nums(h1, h2, []) | []]
  end

  defp get_adj_nums(_l = [h1, h2, h3 | t], is_first) do
    case is_first do
      true ->
        [symbol_idx(h1) |> adj_nums([], h1, h2) | get_adj_nums([h1, h2, h3 | t], false)]

      false ->
        [symbol_idx(h2) |> adj_nums(h1, h2, h3) | get_adj_nums([h2, h3 | t], false)]
    end
  end

  # Every value (including first)
  # input: list with at least 3 elements, having strings or, in the first element case, {:first, string}, returns the numbers within all the strings surrounding the symbols different to .
  defp get_adj_nums(list) do
    get_adj_nums(list, true)
  end

  @doc """
  Day 3 
  ## Examples
      iex> AdventOfCode2023.day2("route/to/example.txt")
      8
  """
  def day3_p1(input) do
    file = File.read!(input)
    IO.puts(file)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist(&1))
    |> get_adj_nums()
    |> List.flatten()
    |> Enum.sum()
  end
end
