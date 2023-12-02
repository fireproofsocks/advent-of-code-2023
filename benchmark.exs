Benchee.run(
  %{
    "day2 pt1" => fn -> Aoc.Day2.solve_pt1(12, 13, 14) end,
    "day2 pt2" => fn -> Aoc.Day2.solve_pt2() end
  },
  time: 10,
  memory_time: 2
)
