import gleam/list
import gleam/result
import gleam/string
import util/list as utillist

pub fn to(input: String) -> List(List(String)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.to_graphemes
  })
}

pub fn at(grid: List(List(String)), x: Int, y: Int) -> String {
  grid
  |> utillist.at(y)
  |> result.unwrap([])
  |> utillist.at(x)
  |> result.unwrap("")
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
