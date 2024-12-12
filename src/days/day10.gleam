import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import util/file
import util/grid

pub fn part1() {
  file.read("inputs/day10.txt")
  |> grid.to(int.parse)
  |> score_trails_part1
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day10.txt")
  |> grid.to(int.parse)
  |> score_trails_part2
  |> int.to_string
  |> io.println
}

fn score_trails_part1(grid: List(List(Int))) -> Int {
  list.index_fold(grid, 0, fn(acc, row, y) {
    list.index_fold(row, acc, fn(acc, element, x) {
      case element {
        0 -> {
          find_trails_part1(grid, #(x, y), 0, set.new())
          |> set.size
          |> int.add(acc)
        }
        _ -> acc
      }
    })
  })
}

fn find_trails_part1(
  grid: List(List(Int)),
  point: #(Int, Int),
  value: Int,
  result: Set(#(Int, Int)),
) -> Set(#(Int, Int)) {
  let return = value == 9
  use <- bool.guard(return, set.insert(result, point))
  let directions = [#(-1, 0), #(0, 1), #(1, 0), #(0, -1)]
  list.fold(directions, result, fn(acc, direction) {
    let next_point = #(point.0 + direction.0, point.1 + direction.1)
    let next_value =
      grid.at(grid, next_point.0, next_point.1) |> result.unwrap(0)
    case value + 1 == next_value {
      True -> find_trails_part1(grid, next_point, next_value, acc)
      False -> acc
    }
  })
}

fn score_trails_part2(grid: List(List(Int))) -> Int {
  list.index_fold(grid, 0, fn(acc, row, y) {
    list.index_fold(row, acc, fn(acc, element, x) {
      case element {
        0 -> {
          find_trails_part2(grid, #(x, y), 0, 0)
          |> int.add(acc)
        }
        _ -> acc
      }
    })
  })
}

fn find_trails_part2(
  grid: List(List(Int)),
  point: #(Int, Int),
  value: Int,
  result: Int,
) -> Int {
  let return = value == 9
  use <- bool.guard(return, result + 1)
  let directions = [#(-1, 0), #(0, 1), #(1, 0), #(0, -1)]
  list.fold(directions, result, fn(acc, direction) {
    let next_point = #(point.0 + direction.0, point.1 + direction.1)
    let next_value =
      grid.at(grid, next_point.0, next_point.1) |> result.unwrap(0)
    case value + 1 == next_value {
      True -> find_trails_part2(grid, next_point, next_value, acc)
      False -> acc
    }
  })
}
