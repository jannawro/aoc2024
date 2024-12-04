import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util/file
import util/list as utillist

pub fn part1() {
  file.read("inputs/day4.txt")
  |> to_grid
  |> search_grid_for_xmas
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day4.txt")
  |> to_grid
  |> search_grid_for_x_mas
  |> int.to_string
  |> io.println
}

fn to_grid(input: String) -> List(List(String)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.to_graphemes
  })
}

fn search_grid_for_xmas(grid: List(List(String))) -> Int {
  let directions = [
    #(-1, -1),
    #(0, -1),
    #(1, -1),
    #(-1, 0),
    #(1, 0),
    #(-1, 1),
    #(0, 1),
    #(1, 1),
  ]
  let xmas_graphemes = ["X", "M", "A", "S"]

  use acc, row, y_position <- list.index_fold(grid, 0)
  use acc, letter, x_position <- list.index_fold(row, acc)

  case letter {
    "X" ->
      {
        use direction <- list.map(directions)
        let #(dir_x, dir_y) = direction
        let first = letter
        let second = grid_at(grid, x_position + dir_x, y_position + dir_y)
        let third =
          grid_at(grid, x_position + dir_x * 2, y_position + dir_y * 2)
        let fourth =
          grid_at(grid, x_position + dir_x * 3, y_position + dir_y * 3)
        [first, second, third, fourth]
      }
      |> list.filter(fn(variant) { variant == xmas_graphemes })
      |> list.length
      |> int.add(acc)
    _ -> acc
  }
}

fn search_grid_for_x_mas(grid: List(List(String))) {
  let top_left = #(-1, -1)
  let top_right = #(1, -1)
  let bot_left = #(-1, 1)
  let bot_right = #(1, 1)
  let mas_graphemes = ["M", "A", "S"]

  use acc, row, y_position <- list.index_fold(grid, 0)
  use acc, letter, x_position <- list.index_fold(row, acc)

  case letter {
    "A" -> {
      let top_left_letter =
        grid_at(grid, x_position + top_left.0, y_position + top_left.1)
      let top_right_letter =
        grid_at(grid, x_position + top_right.0, y_position + top_right.1)
      let bot_left_letter =
        grid_at(grid, x_position + bot_left.0, y_position + bot_left.1)
      let bot_right_letter =
        grid_at(grid, x_position + bot_right.0, y_position + bot_right.1)

      let first_diagonal = [top_left_letter, letter, bot_right_letter]
      let second_diagonal = [bot_left_letter, letter, top_right_letter]

      let first_diagonal_valid =
        first_diagonal == mas_graphemes
        || list.reverse(first_diagonal) == mas_graphemes
      let second_diagonal_valid =
        second_diagonal == mas_graphemes
        || list.reverse(second_diagonal) == mas_graphemes

      case first_diagonal_valid, second_diagonal_valid {
        True, True -> 1 + acc
        _, _ -> acc
      }
    }
    _ -> acc
  }
}

fn grid_at(grid: List(List(String)), x: Int, y: Int) -> String {
  grid
  |> utillist.at(y)
  |> result.unwrap([])
  |> utillist.at(x)
  |> result.unwrap("")
}
