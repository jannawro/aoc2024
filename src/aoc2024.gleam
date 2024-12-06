import argv
import days/day1
import days/day2
import days/day3
import days/day4
import days/day5
import days/day6

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
    _ -> panic
  }
}
