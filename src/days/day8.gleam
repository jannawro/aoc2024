import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import util/file
import util/grid

pub fn part1() {
  let grid =
    file.read("inputs/day8.txt")
    |> grid.to

  grid
  |> find_frequencies
  |> find_frequency_pairs
  |> find_antinodes
  |> list.filter(fn(point) {
    case grid.at(grid, point.0, point.1) {
      "" -> False
      _ -> True
    }
  })
  |> set.from_list
  |> set.size
  |> int.to_string
  |> io.println
}

pub fn part2() {
  let grid =
    file.read("inputs/day8.txt")
    |> grid.to

  grid
  |> find_frequencies
  |> find_frequency_pairs
  |> list.map(fn(pair) { find_antinodes_part2(pair.0, pair.1, grid) })
  |> list.flatten
  |> set.from_list
  |> set.size
  |> int.to_string
  |> io.println
}

fn find_frequencies(grid: List(List(String))) -> Dict(String, List(#(Int, Int))) {
  grid
  |> list.index_map(fn(row, row_index) {
    row
    |> list.index_map(fn(char, col_index) { #(char, #(col_index, row_index)) })
  })
  |> list.flatten
  |> list.filter(fn(pair) { pair.0 != "." })
  |> list.group(fn(pair) { pair.0 })
  |> dict.map_values(fn(_, pairs) {
    pairs
    |> list.map(fn(pair) { pair.1 })
  })
}

fn find_frequency_pairs(
  frequencies: Dict(String, List(#(Int, Int))),
) -> List(#(#(Int, Int), #(Int, Int))) {
  frequencies
  |> dict.map_values(fn(_key, value) { value |> list.combination_pairs })
  |> dict.values
  |> list.flatten
}

fn find_antinodes(frequency_pairs: List(#(#(Int, Int), #(Int, Int)))) {
  frequency_pairs
  |> list.map(fn(pair) {
    let #(left, right) = pair
    let first_antinode = find_antinode(left, right)
    let second_antinode = find_antinode(right, left)
    [first_antinode, second_antinode]
  })
  |> list.flatten
}

fn find_antinode(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  #(2 * b.0 - a.0, 2 * b.1 - a.1)
}

fn find_antinodes_part2(
  a: #(Int, Int),
  b: #(Int, Int),
  grid: List(List(String)),
) -> List(#(Int, Int)) {
  let vector = #(b.0 - a.0, b.1 - a.1)
  let opposite = turn_180_degrees(vector)

  let max_y = list.length(grid) - 1
  let max_x =
    list.first(grid) |> result.unwrap([]) |> list.length |> int.subtract(1)

  [
    traverse_with_vector(a, vector, max_x, max_y, []),
    traverse_with_vector(b, vector, max_x, max_y, []),
    traverse_with_vector(a, opposite, max_x, max_y, []),
    traverse_with_vector(b, opposite, max_x, max_y, []),
  ]
  |> list.flatten
}

fn turn_180_degrees(vector: #(Int, Int)) -> #(Int, Int) {
  let #(x, y) = vector
  #(-x, -y)
}

fn traverse_with_vector(
  start: #(Int, Int),
  vector: #(Int, Int),
  max_x: Int,
  max_y: Int,
  result: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  let next_x = start.0 + vector.0
  let next_y = start.1 + vector.1

  case next_x, next_y {
    next_x, next_y
      if next_x < 0 || next_x > max_x || next_y < 0 || next_y > max_y
    -> result
    _, _ -> {
      let next = #(next_x, next_y)
      let new_result = result |> list.append([next])
      traverse_with_vector(next, vector, max_x, max_y, new_result)
    }
  }
}
