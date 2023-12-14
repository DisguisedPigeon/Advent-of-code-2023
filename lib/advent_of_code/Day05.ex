defmodule Seed do
  defstruct seed: nil,
            soil: nil,
            fertilizer: nil,
            water: nil,
            light: nil,
            temperature: nil,
            humidity: nil,
            location: nil

  defp pairs([h1, h2 | t]) do
    [[h1, h2] | pairs(t)]
  end

  defp pairs([_ | []]) do
    throw("values must be pair")
  end

  defp pairs([]) do
    []
  end

  defp pairs_to_range_list([[h, h2] | t]) do
    [{h, h + h2} | pairs_to_range_list(t)]
  end

  defp pairs_to_range_list([]) do
    []
  end

  def parse(l) do
    Regex.scan(~r/\d+/, l)
    |> List.flatten()
    |> Enum.map(&String.to_integer(&1))
  end

  def parse_2(l) do
    Regex.scan(~r/\d+/, l)
    |> List.flatten()
    |> Enum.map(&String.to_integer(&1))
    |> pairs()
    |> pairs_to_range_list()
  end
end

defmodule Mapper do
  defstruct origins: [],
            destinations: [],
            sizes: []

  defp __to_mapper_list(_l = []) do
    []
  end

  defp __to_mapper_list(_l = [m | t]) do
    [
      m
      |> Enum.reduce(
        %Mapper{},
        fn [dest, orig, size], acc ->
          %Mapper{
            origins: [orig | acc.origins],
            destinations: [dest | acc.destinations],
            sizes: [size | acc.sizes]
          }
        end
      )
      | __to_mapper_list(t)
    ]
  end

  defp __extract_segments([h | t]) do
    if Regex.match?(~r/.*-to-.* map:/, h) do
      []
    else
      [
        (
          [[_ | t] | _] = Regex.scan(~r/^(\d+) (\d+) (\d+)$/, h)
          t |> Enum.map(&String.to_integer(&1))
        )
        | __extract_segments(t)
      ]
    end
  end

  defp __extract_segments([]) do
    []
  end

  defp __parse_maplist(_l = [h | t]) do
    if Regex.match?(~r/.*-to-.* map:/, h) do
      [
        __extract_segments(t)
        | __parse_maplist(t)
      ]
    else
      __parse_maplist(t)
    end
  end

  defp __parse_maplist(_l = []) do
    []
  end

  def parse_maplist(l) do
    __parse_maplist(l)
    |> __to_mapper_list()
  end

  defp __internal_apply(v, [], [], []) do
    v
  end

  defp __internal_apply(v, [origin | otail], [destination | dtail], [size | stail]) do
    if v >= origin and v < origin + size do
      v - origin + destination
    else
      __internal_apply(v, otail, dtail, stail)
    end
  end

  def apply(m, v) do
    __internal_apply(v, m.origins, m.destinations, m.sizes)
  end

  def map_list_to_function(maplist) do
    fn v ->
      maplist
      |> Enum.reduce(v, fn e, acc -> Mapper.apply(e, acc) end)
    end
  end

  def get_crit_maps({start, finish}, [m | t]) do
    if Enum.any?(m.origins, fn o -> start < o and finish > o end) do
      [m | get_crit_maps({start, finish}, t)]
    else
      []
    end
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
  def day5_p1(input) do
    [seeds | maps] =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    seeds =
      seeds
      |> Seed.parse()

    map =
      maps
      |> Mapper.parse_maplist()
      |> Mapper.map_list_to_function()

    Enum.map(seeds, fn seed -> map.(seed) end)
    |> Enum.min()
  end

  def day5_p2(input) do
    [seeds | maps] =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    seeds =
      seeds
      |> Seed.parse_2()

    maps =
      maps
      |> Mapper.parse_maplist()

    Enum.map(seeds, fn seed -> Mapper.get_crit_maps(seed, maps) end)
  end
end
