import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util/list as utillist

pub fn to(
  input: String,
  converter: fn(String) -> Result(a, Nil),
) -> List(List(a)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.to_graphemes
    |> list.map(converter)
    |> result.values
  })
}

pub fn at(grid: List(List(a)), x: Int, y: Int) -> Result(a, Nil) {
  case utillist.at(grid, y) {
    Ok(row) -> utillist.at(row, x)
    Error(_) -> Error(Nil)
  }
}

pub fn replace(
  grid: List(List(a)),
  x: Int,
  y: Int,
  replacement: a,
) -> List(List(a)) {
  grid
  |> list.index_map(fn(row, row_index) {
    case row_index == x {
      True ->
        list.index_map(row, fn(cell, col_index) {
          case col_index == y {
            True -> replacement
            False -> cell
          }
        })
      False -> row
    }
  })
}

pub fn pretty_print(grid: List(List(String))) -> Nil {
  grid
  |> list.map(fn(row) {
    row
    |> list.map(fn(cell) {
      string.pad_end(cell, to: max_width(grid), with: " ")
    })
    |> string.join(" ")
    |> io.println
  })
  Nil
}

fn max_width(grid: List(List(String))) -> Int {
  grid
  |> list.flatten
  |> list.map(string.length)
  |> list.fold(0, fn(acc, len) { int.max(acc, len) })
}

pub fn contains_point(grid: List(List(a)), point: #(Int, Int)) -> Bool {
  let #(x, y) = point
  let max_x =
    list.first(grid) |> result.unwrap([]) |> list.length |> int.subtract(1)
  let max_y = list.length(grid) |> int.subtract(1)

  x >= 0 && x <= max_x && y >= 0 && y <= max_y
}
