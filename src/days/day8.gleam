import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
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
  |> find_antinodes(grid)
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
  |> list.filter(fn(cell) { cell.0 != "." })
  |> list.group(fn(cell) { cell.0 })
  |> dict.map_values(fn(_, cells) {
    cells
    |> list.map(fn(cell) { cell.1 })
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

fn find_antinodes(
  frequency_pairs: List(#(#(Int, Int), #(Int, Int))),
  grid: List(List(String)),
) {
  frequency_pairs
  |> list.map(fn(pair) {
    let #(left, right) = pair
    let first_antinode = find_antinode(left, right)
    let second_antinode = find_antinode(right, left)
    [first_antinode, second_antinode]
  })
  |> list.flatten
  |> list.filter(grid.contains_point(grid, _))
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
  [
    traverse_with_vector(a, vector, grid, []),
    traverse_with_vector(b, vector, grid, []),
    traverse_with_vector(a, opposite, grid, []),
    traverse_with_vector(b, opposite, grid, []),
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
  grid: List(List(String)),
  result: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  let next = #(start.0 + vector.0, start.1 + vector.1)

  case grid.contains_point(grid, next) {
    True -> {
      let new_result = list.append(result, [next])
      traverse_with_vector(next, vector, grid, new_result)
    }
    False -> result
  }
}
