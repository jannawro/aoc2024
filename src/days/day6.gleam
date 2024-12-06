import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import util/file
import util/grid
import util/list as utillist

pub fn part1() {
  let grid =
    file.read("inputs/day6.txt")
    |> grid.to

  let guard_start = grid |> find_guard
  let #(traversed, _looped) =
    grid
    |> traverse_path(guard_start, #(0, -1))

  traversed
  |> dict.keys
  |> list.length
  |> int.to_string
  |> io.println
}

// doesn't work
pub fn part2() {
  let grid =
    file.read("inputs/day6.txt")
    |> grid.to

  let guard_start = grid |> find_guard |> io.debug
  let #(traversed, _looped) =
    grid
    |> traverse_path(guard_start, #(0, -1))

  traversed
  |> dict.keys
  |> find_loops(grid, _, guard_start)
  |> int.to_string
  |> io.println
}

fn find_guard(grid: List(List(String))) -> #(Int, Int) {
  let row_index =
    grid
    |> list.index_fold(0, fn(acc, row, index) {
      case list.contains(row, "^") {
        True -> index
        False -> acc
      }
    })

  let column_index =
    grid
    |> utillist.at(row_index)
    |> result.unwrap([])
    |> list.index_fold(0, fn(acc, element, index) {
      case element == "^" {
        True -> index
        False -> acc
      }
    })

  #(column_index, row_index)
}

fn traverse_path(
  grid: List(List(String)),
  starting_position: #(Int, Int),
  direction: #(Int, Int),
) -> #(Dict(#(Int, Int), #(Int, Int)), Bool) {
  do_traverse_path(grid, starting_position, direction, dict.new())
}

fn do_traverse_path(
  grid: List(List(String)),
  starting_position: #(Int, Int),
  direction: #(Int, Int),
  result: Dict(#(Int, Int), #(Int, Int)),
) -> #(Dict(#(Int, Int), #(Int, Int)), Bool) {
  let next_position = #(
    starting_position.0 + direction.0,
    starting_position.1 + direction.1,
  )

  case
    result |> dict.has_key(starting_position),
    result |> dict.get(starting_position) |> result.unwrap(#(-100, -100))
    == direction
  {
    True, True -> #(result, True)
    _, _ -> {
      let next_element = grid |> grid.at(next_position.0, next_position.1)
      case next_element {
        "#" -> {
          let new_direction = direction |> turn_90_degrees
          let traversed = result |> dict.insert(starting_position, direction)
          do_traverse_path(grid, starting_position, new_direction, traversed)
        }
        "." | "^" -> {
          let traversed = result |> dict.insert(starting_position, direction)
          do_traverse_path(grid, next_position, direction, traversed)
        }
        _ -> {
          let traversed = result |> dict.insert(starting_position, direction)
          #(traversed, False)
        }
      }
    }
  }
}

fn turn_90_degrees(vector: #(Int, Int)) -> #(Int, Int) {
  let #(x, y) = vector
  #(-y, x)
}

fn find_loops(
  grid: List(List(String)),
  traversed: List(#(Int, Int)),
  starting_position: #(Int, Int),
) -> Int {
  let to_do = list.length(traversed) - 1

  traversed
  |> list.filter(fn(x) { x != starting_position })
  |> list.map(fn(position) {
    let #(x, y) = position
    let _new_grid = grid |> grid.replace(x, y, "#")
  })
  |> list.index_map(fn(variant_grid, index) {
    let #(_traversed, looped) =
      variant_grid |> traverse_path(starting_position, #(0, -1))
    io.println(
      "done with grid "
      <> int.to_string(index + 1)
      <> "/"
      <> int.to_string(to_do),
    )
    looped
  })
  |> list.filter(fn(x) { x == True })
  |> list.length
}
