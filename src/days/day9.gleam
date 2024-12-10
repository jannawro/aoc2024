import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn part1() {
  "2333133121414131402"
  // file.read("inputs/day9.txt")
  |> to_disk_map
  |> to_files
  |> list.flatten
  // flattens files to blocks
  |> compress
  |> checksum
  |> io.debug
  Nil
}

pub fn part2() {
  Nil
}

fn to_disk_map(input: String) -> List(String) {
  input
  |> string.trim
  |> string.to_graphemes
}

fn to_files(disk_map: List(String)) -> List(List(String)) {
  let #(evens, odds) =
    disk_map
    |> list.index_fold(#([], []), fn(result, element, index) {
      case index % 2 {
        0 -> #(list.append(result.0, [element]), result.1)
        _ -> #(result.0, list.append(result.1, [element]))
      }
    })

  let new_evens =
    evens
    |> list.index_map(fn(char, index) {
      let assert Ok(num) = int.parse(char)
      let index_char = int.to_string(index)
      list.repeat(index_char, num)
    })
  let new_odds =
    odds
    |> list.map(fn(char) {
      let assert Ok(num) = int.parse(char)
      list.repeat(".", num)
    })

  list.interleave([new_evens, new_odds])
  |> list.filter(fn(x) { !list.is_empty(x) })
}

fn compress(blocks: List(String)) -> List(String) {
  let takes = blocks |> list.filter(fn(x) { x != "." }) |> list.reverse
  let expected_length = takes |> list.length
  build_compressed(blocks, takes, expected_length, [])
}

fn build_compressed(
  blocks: List(String),
  takes: List(String),
  expected_length: Int,
  result: List(String),
) -> List(String) {
  case list.length(result) == expected_length {
    True -> result
    False -> {
      let assert [blocks_first, ..blocks_rest] = blocks
      case blocks_first {
        "." -> {
          let assert [takes_first, ..takes_rest] = takes
          let new_result = list.append(result, [takes_first])
          build_compressed(blocks_rest, takes_rest, expected_length, new_result)
        }
        _ -> {
          let new_result = list.append(result, [blocks_first])
          build_compressed(blocks_rest, takes, expected_length, new_result)
        }
      }
    }
  }
}

fn checksum(compressed_blocks: List(String)) -> Int {
  compressed_blocks
  |> list.index_fold(0, fn(acc, char, index) {
    case int.parse(char) {
      Error(_) -> acc
      Ok(num) -> num * index + acc
    }
  })
}
