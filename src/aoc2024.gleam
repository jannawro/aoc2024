import argv
import days/day1
import days/day10
import days/day11
import days/day12
import days/day2
import days/day3
import days/day4
import days/day5
import days/day6
import days/day7
import days/day8
import days/day9
import gleam/io

pub fn main() {
  let assert [day] = argv.load().arguments
  case day {
    "day1" -> {
      day1.part1()
      day1.part2()
    }
    "day2" -> {
      day2.part1()
      day2.part2()
    }
    "day3" -> {
      day3.part1()
      day3.part2()
    }
    "day4" -> {
      day4.part1()
      day4.part2()
    }
    "day5" -> {
      day5.part1()
      day5.part2()
    }
    "day6" -> {
      day6.part1()
      day6.part2()
    }
    "day7" -> {
      day7.part1()
      day7.part2()
    }
    "day8" -> {
      day8.part1()
      day8.part2()
    }
    "day9" -> {
      day9.part1()
      day9.part2()
    }
    "day10" -> {
      day10.part1()
      day10.part2()
    }
    "day11" -> {
      day11.part1()
      day11.part2()
    }
    "day12" -> {
      day12.part1()
      day12.part2()
    }
    _ -> io.println("This is not a valid day argument.")
  }
}
