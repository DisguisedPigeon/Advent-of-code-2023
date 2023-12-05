defmodule AdventOfCode2023.Day2 do
  @moduledoc """
  Advent of code 2023 - day 1 solution in elixir.
  """

  defp count_possibles(dict) do
    Enum.reduce(
      dict,
      0,
      fn {k, v}, acc ->
        if v
           |> List.flatten()
           |> Enum.map(fn {n, type} ->
             if type == "red" do
               n <= 12 and n >= 0
             else
               if type == "blue" do
                 n <= 14 and n >= 0
               else
                 n <= 13 and n >= 0
               end
             end
           end)
           |> Enum.reduce(fn boolean, acc -> boolean and acc end) do
          k + acc
        else
          acc
        end
      end
    )
  end

  defp count_min(dict) do
    Enum.reduce(
      dict,
      0,
      fn {_, v}, acc ->
        v
        |> List.flatten()
        |> Enum.map(fn {n, type} ->
          if type == "red" do
            {:red, n}
          else
            if type == "blue" do
              {:blue, n}
            else
              {:green, n}
            end
          end
        end)
        |> Enum.reduce(%{red: 0, blue: 0, green: 0}, fn {k, v}, acc ->
          if k == :red do
            %{red: max(v, acc[:red]), blue: acc[:blue], green: acc[:green]}
          else
            if k == :blue do
              %{red: acc[:red], blue: max(v, acc[:blue]), green: acc[:green]}
            else
              %{red: acc[:red], blue: acc[:blue], green: max(v, acc[:green])}
            end
          end
        end)
        |> then(fn d -> acc + (d[:red] * d[:blue] * d[:green]) end)
      end
    )
  end

  @doc """
  Day 1 
  ## Examples

      iex> AdventOfCode2023.day2("route/to/example.txt")
      8
  """
  def day2_p1(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.map(
      &case Regex.run(~r/\d+:/, &1) do
        nil ->
          IO.puts(&1)
          raise "¿?"

        [value | []] ->
          {
            value
            |> String.slice(0..(String.length(value) - 2))
            |> String.to_integer(),
            &1
            |> String.split(":", trim: true)
            |> List.last()
            |> String.slice(1..(String.length(&1) - 1))
          }

        _ ->
          raise "¿?"
      end
    )
    |> Enum.map(fn {k, v} ->
      {
        k,
        v
        |> String.split("; ")
        |> Enum.map(&String.split(&1, ", "))
        |> Enum.map(
          &Enum.map(
            &1,
            fn w ->
              l = String.split(w, " ")
              {l |> List.first() |> String.to_integer(), List.last(l)}
            end
          )
        )
      }
    end)
    |> count_possibles()
  end

  def day2_p2(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
    |> Enum.map(
      &case Regex.run(~r/\d+:/, &1) do
        nil ->
          IO.puts(&1)
          raise "¿?"

        [value | []] ->
          {
            value
            |> String.slice(0..(String.length(value) - 2))
            |> String.to_integer(),
            &1
            |> String.split(":", trim: true)
            |> List.last()
            |> String.slice(1..(String.length(&1) - 1))
          }

        _ ->
          raise "¿?"
      end
    )
    |> Enum.map(fn {k, v} ->
      {
        k,
        v
        |> String.split("; ")
        |> Enum.map(&String.split(&1, ", "))
        |> Enum.map(
          &Enum.map(
            &1,
            fn w ->
              l = String.split(w, " ")
              {l |> List.first() |> String.to_integer(), List.last(l)}
              # l |> List.first() |> String.to_integer()
            end
          )
        )
      }
    end)
    |> count_min()
  end
end
