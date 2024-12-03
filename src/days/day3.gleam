import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import util/file

pub fn part1() {
  file.read("inputs/day3.txt")
  |> scan("mul\\((\\d+),(\\d+)\\)")
  |> parse_mul
  |> sum_muls
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day3.txt")
  |> scan("mul\\((\\d+),(\\d+)\\)|don't|do")
  |> filter_between_donts_and_dos
  |> parse_mul
  |> sum_muls
  |> int.to_string
  |> io.println
}

fn scan(input: String, pattern: String) -> List(regexp.Match) {
  let assert Ok(re) = regexp.from_string(pattern)

  input
  |> regexp.scan(re, _)
}

fn parse_mul(scan_result: List(regexp.Match)) -> List(#(Int, Int)) {
  scan_result
  |> list.map(fn(match) {
    let assert [Some(first), Some(second)] = match.submatches
    let assert Ok(n1) = int.parse(first)
    let assert Ok(n2) = int.parse(second)
    #(n1, n2)
  })
}

fn sum_muls(muls: List(#(Int, Int))) -> Int {
  muls
  |> list.fold(0, fn(acc, numbers) {
    let #(first, second) = numbers
    let _sum = first * second + acc
  })
}

fn filter_between_donts_and_dos(list: List(regexp.Match)) -> List(regexp.Match) {
  let #(_skip, list) =
    list.fold(over: list, from: #(False, []), with: fn(acc, elem) {
      let #(skip, result) = acc
      case elem.content {
        "don't" -> #(True, result)
        "do" -> #(False, result)
        _ if skip -> #(skip, result)
        _ -> #(skip, list.append(result, [elem]))
      }
    })
  list
}
