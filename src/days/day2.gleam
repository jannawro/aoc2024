import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util/file
import util/list as utillist

pub fn part1() {
  file.read("inputs/day2.txt")
  |> to_reports
  |> list.filter(is_monotonic)
  |> list.filter(are_differences_safe)
  |> list.length
  |> int.to_string
  |> io.println
}

pub fn part2() {
  let all_reports =
    file.read("inputs/day2.txt")
    |> to_reports

  let definietely_safe_reports =
    all_reports
    |> list.filter(is_monotonic)
    |> list.filter(are_differences_safe)

  let potentially_unsafe =
    utillist.difference(all_reports, definietely_safe_reports)

  let potentially_safe_variants =
    potentially_unsafe
    |> list.map(fn(report) { #(report, report |> generate_variants) })

  let safe_as_variant =
    potentially_safe_variants
    |> list.filter(fn(report_with_variants) {
      let #(_report, variants) = report_with_variants
      let safe_variants =
        variants
        |> list.filter(is_monotonic)
        |> list.filter(are_differences_safe)
      safe_variants |> list.length() > 0
    })
    |> list.map(fn(report_with_variants) {
      let #(report, _variants) = report_with_variants
      report
    })

  let _safe_reports =
    list.append(definietely_safe_reports, safe_as_variant)
    |> list.length
    |> int.to_string
    |> io.println
}

fn to_reports(input: String) -> List(List(Int)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.split(on: " ")
    |> list.map(fn(char) {
      case int.parse(char) {
        Ok(a) -> a
        Error(_) -> 0
      }
    })
  })
}

fn is_monotonic(report: List(Int)) -> Bool {
  case report {
    [] | [_] -> True
    [first, second, ..rest] -> {
      let is_increasing = second > first
      check_direction(second, rest, is_increasing)
    }
  }
}

fn check_direction(previous: Int, list: List(Int), is_increasing: Bool) -> Bool {
  case list {
    [] -> True
    [current, ..rest] -> {
      case is_increasing {
        True -> {
          case current > previous {
            True -> check_direction(current, rest, is_increasing)
            False -> False
          }
        }
        False -> {
          case current < previous {
            True -> check_direction(current, rest, is_increasing)
            False -> False
          }
        }
      }
    }
  }
}

fn are_differences_safe(report: List(Int)) -> Bool {
  case report {
    [] | [_] -> True
    [first, ..rest] -> check_pair_diffs(first, rest)
  }
}

fn check_pair_diffs(previous: Int, list: List(Int)) -> Bool {
  case list {
    [] -> True
    [current, ..rest] -> {
      let diff = current - previous |> int.absolute_value
      case diff >= 1 && diff <= 3 {
        True -> check_pair_diffs(current, rest)
        False -> False
      }
    }
  }
}

fn generate_variants(report: List(Int)) -> List(List(Int)) {
  case report {
    [] -> []
    [_] -> [[]]
    [first, ..rest] -> {
      let without_first = rest
      let other_variants =
        generate_variants(rest)
        |> list.map(fn(variant) { [first, ..variant] })
      [without_first, ..other_variants]
    }
  }
}
