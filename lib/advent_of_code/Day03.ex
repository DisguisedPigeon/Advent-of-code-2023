defmodule AdventOfCode2023.Day3 do
  @moduledoc """
  Advent of code 2023 - day 1 solution in elixir.
  """

  @doc """
  Day 3 
  ## Examples
      iex> AdventOfCode2023.day2("route/to/example.txt")
      8
  """
  def day3_p1(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist(&1))
    |> get_adj_nums()
    |> List.flatten()
    |> Enum.sum()
  end

  def day3_p2(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn e ->
      {
        e,
        Regex.scan(~r/\*+/, e, return: :index)
        |> List.flatten()
        |> Enum.map(&elem(&1, 0))
      }
    end)
    |> find_numbers()
    |> Enum.map(fn l ->
      Enum.filter(
        l,
        fn a ->
          List.flatten(a) |> Enum.filter(fn a -> a != 1 end) |> Enum.count() == 2
        end
      )
    end)

    # |> Enum.map(&(List.flatten(&1) |> Enum.product()))
    # |> Enum.filter(fn e -> e != 1 end)
    # |> Enum.sum()
  end

  defp find_numbers(l) do
    find_numbers(l, true)
  end

  defp find_numbers(_l = [curLine, nextLine | t], first) when first == true do
    [get_nums({"", []}, curLine, nextLine) | find_numbers([curLine, nextLine | t], false)]
  end

  defp find_numbers(_l = [prevLine, curLine, nextLine | t], first) when first == false do
    [get_nums(prevLine, curLine, nextLine) | find_numbers([curLine, nextLine | t], false)]
  end

  defp find_numbers(_l = [prevLine, curLine | []], _) do
    [get_nums(prevLine, curLine) | []]
  end

  defp get_nums(
         prevLine = {prevString, _previndexlist},
         _currLine = {currString, currLocations},
         nextLine = {nextString, _nextindexlist}
       ) do
    case currLocations do
      [i | t] ->
        [
          [num(prevString, i), num(currString, i), num(nextString, i)]
          | get_nums(prevLine, {currString, t}, nextLine)
        ]

      [] ->
        []
    end
  end

  defp get_nums(prevLine = {prevString, _previndexlist}, _currLine = {currString, currLocations}) do
    case currLocations do
      [i | t] ->
        [{num(prevString, i), num(currString, i)} | get_nums(prevLine, {currString, t})]

      [] ->
        []
    end
  end

  defp num(string, index) do
    if [] == (l = get_list(string, index)) do
      1
    else
      l
    end
  end

  defp get_list(string, location) do
    Regex.scan(~r/\d+/, string, return: :index)
    |> Enum.map(fn [{ind, len}] ->
      if ind <= location do
        if ind + len >= location do
          string |> String.slice(ind..(ind + len - 1)) |> String.to_integer()
        else
          1
        end
      else
        if ind == location + 1 do
          string |> String.slice(ind..(ind + len - 1)) |> String.to_integer()
        else
          1
        end
      end
    end)
  end

  # gets all numbers adjacent to chars
  # input: list with at least 3 char lists, returns a list of lists of numbers surrounding symbols
  defp get_adj_nums(list) do
    get_adj_nums(list, true)
  end

  defp get_adj_nums(_l = [h1, h2, h3 | t], is_first) do
    case is_first do
      true ->
        [symbol_idx(h1) |> adj_nums([], h1, h2) | get_adj_nums([h1, h2, h3 | t], false)]

      false ->
        [symbol_idx(h2) |> adj_nums(h1, h2, h3) | get_adj_nums([h2, h3 | t], false)]
    end
  end

  defp get_adj_nums(_l = [h1, h2 | []], _is_first) do
    [symbol_idx(h2) |> adj_nums(h1, h2, []) | []]
  end

  # takes a charlist and returns the indexes of symbols different to . within it
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

  defp is_symbol?(c) do
    not (c == ?. or (c >= ?0 and c <= ?9))
  end

  # gets the adjacent numbers within three lists to a list of indices (prev is above, curr is the list containing the list, next is below)
  defp adj_nums(_indexes = [h | t], lprev, lcurr, lnext) do
    [
      get_hor(h, lprev),
      get_hor(h, lcurr),
      get_hor(h, lnext) | adj_nums(t, lprev, lcurr, lnext)
    ]
  end

  defp adj_nums(_indexes = [], _lprev, _lcurr, _lnext) do
    []
  end

  # Gets the numbers around a character horizontally
  defp get_hor(index, str) do
    if is_num(index, str) do
      [
        if is_num(index + 1, str) and not is_num(index - 1, str) do
          get_after(index, str) |> String.to_integer()
        else
          0
        end,
        if is_num(index - 1, str) and not is_num(index + 1, str) do
          get_before(index, str) |> String.to_integer()
        else
          0
        end,
        if is_num(index - 1, str) and is_num(index + 1, str) do
          get_all(index, str) |> String.to_integer()
        else
          0
        end
      ]
    else
      [
        if is_num(index - 1, str) do
          get_before(index - 1, str) |> String.to_integer()
        else
          0
        end,
        if is_num(index + 1, str) do
          get_after(index + 1, str) |> String.to_integer()
        else
          0
        end
      ]
    end
  end

  # Returns true if the character at the index of a charlist is a number
  defp is_num(index, chlist) do
    chlist
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

  # Returns number within a charlist on the index as a string
  defp get_all(index, str) do
    get_before(index - 1, str) <> get_after(index, str)
  end

  # Returns the first number within a charlist from the index backwards as a string
  defp get_before(index, chlist) do
    chlist
    |> Enum.slice(0..index)
    |> Enum.reverse()
    |> filter_number()
    |> Enum.reverse()
    |> Enum.reduce(<<>>, fn e, acc ->
      acc <> <<e>>
    end)
  end

  # Returns the first number within a charlist from the index as a string
  defp get_after(index, chlist) do
    chlist
    |> Enum.slice(index..(Enum.count(chlist) - 1))
    |> filter_number()
    |> Enum.reduce(<<>>, fn e, acc ->
      acc <> <<e>>
    end)
  end

  # Takes a char list starting with numbers and returns a char list with the starting digits
  defp filter_number(_clist = [h | t]) do
    if h >= ?0 and h <= ?9 do
      [h | filter_number(t)]
    else
      []
    end
  end

  defp filter_number(_clist = []) do
    []
  end

  # Turns a char to a string containing only that charcter
  defp char_to_string(e) do
    if e != nil and e >= ?0 and e <= ?9 do
      <<e>>
    else
      ""
    end
  end
end
