defmodule AdventOfCode2023.Race do
  alias AdventOfCode2023.Race
  defstruct time: 0, best_distance: 0

  def parse(time, dist) do
    [Regex.scan(~r/\d+/, time), Regex.scan(~r/\d+/, dist)]
    |> Enum.map(&List.flatten(&1))
    |> lpair_to_lrace()
  end

  def parse2(time, dist) do
    time =
      String.split(time)
      |> Enum.reduce(fn e, acc -> acc <> e end)

    dist =
      String.split(dist)
      |> Enum.reduce(fn e, acc -> acc <> e end)

    [Regex.scan(~r/\d+/, time), Regex.scan(~r/\d+/, dist)]
    |> Enum.map(&List.flatten(&1))
    |> lpair_to_lrace()
  end

  def optimice(race) do
    # Para todos los tiempos, el maximo de la distancia se consigue en tiempo/2, si da decimal, ambos valores cercanos sirven
    {div(race.time, 2), rem(race.time, 2)}
  end

  def calc_dist(race, pressed_time) do
    (race.time - pressed_time) * pressed_time
  end

  defp lpair_to_lrace([times, distances]) do
    lpair_to_lrace(times, distances)
  end

  defp lpair_to_lrace([time | ttail], [distance | dtail]) do
    [pair_to_race(time, distance) | lpair_to_lrace(ttail, dtail)]
  end

  defp lpair_to_lrace([], []) do
    []
  end

  defp pair_to_race(time, distance) do
    %Race{time: String.to_integer(time), best_distance: String.to_integer(distance)}
  end

  defp margin(race, e = {_amount, _has_one}, hold) do
    if calc_dist(race, hold - 1) > race.best_distance do
      1 + margin(race, e, hold - 1)
    else
      1
    end
  end

  def margin(race) do
    optimal = Race.optimice(race)

    margin(
      race,
      optimal,
      elem(optimal, 0)
    ) * 2 -
      if elem(optimal, 1) == 0 do
        1
      else
        0
      end
  end
end

defmodule AdventOfCode2023.Day6 do
  alias AdventOfCode2023.Race

  def day6_p1(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> then(fn [times, distances] ->
      Race.parse(times, distances)
    end)
    |> Enum.map(&Race.margin(&1))
    |> Enum.product()
  end

  def day6_p2(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> then(fn [times, distances] ->
      Race.parse2(times, distances)
    end)
    |> Enum.map(&Race.margin(&1))
    |> Enum.product()
  end
end
