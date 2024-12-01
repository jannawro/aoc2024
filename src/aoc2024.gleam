import argv
import days/day1

pub fn main() {
  let assert [day] = argv.load().arguments
  case day {
    "day1" -> {
      day1.part1()
      day1.part2()
    }
    _ -> panic
  }
}
