import argv
import days/day1
import days/day2
import days/day3

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
    _ -> panic
  }
}
