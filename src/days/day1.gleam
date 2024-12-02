import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util/file

pub fn part1() {
  file.read("inputs/day1.txt")
  |> split_columns
  |> sort_columns
  |> calculate_distances
  |> sum_list
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day1.txt")
  |> split_columns
  |> count_occurences
  |> calculate_similarity
  |> int.to_string
  |> io.println
}

fn split_columns(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(row) {
    let assert [first, second] =
      row
      |> string.split(on: "   ")
      |> list.map(fn(s) {
        s
        |> int.parse
        |> result.unwrap(0)
      })
    #(first, second)
  })
  |> list.unzip
}

fn sort_columns(columns: #(List(Int), List(Int))) -> #(List(Int), List(Int)) {
  let #(col1, col2) = columns
  #(list.sort(col1, int.compare), list.sort(col2, int.compare))
}

fn calculate_distances(columns: #(List(Int), List(Int))) -> List(Int) {
  let #(col1, col2) = columns
  list.map2(col1, col2, fn(a, b) {
    a - b
    |> int.absolute_value
  })
}

fn sum_list(numbers: List(Int)) -> Int {
  list.fold(numbers, 0, fn(acc, num) { acc + num })
}

fn count_occurences(columns: #(List(Int), List(Int))) -> List(#(Int, Int)) {
  let #(col1, col2) = columns
  list.map(col1, fn(num) {
    #(num, list.filter(col2, fn(x) { x == num }) |> list.length)
  })
}

fn calculate_similarity(numbers_with_occurences: List(#(Int, Int))) -> Int {
  list.map(numbers_with_occurences, fn(numbers) {
    let #(number, occurences) = numbers
    number * occurences
  })
  |> sum_list
}
