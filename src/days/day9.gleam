import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util/file
import util/list as utillist

pub fn part1() {
  file.read("inputs/day9.txt")
  |> to_disk
  |> fragmented_compress
  |> disk_checksum(0)
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day9.txt")
  |> to_disk
  |> defragmented_compress
  |> disk_checksum(0)
  |> int.to_string
  |> io.println
}

type Block {
  File(size: Int, id: Int)
  Empty(size: Int)
}

type Disk =
  List(Block)

fn to_disk(input: String) -> Disk {
  input
  |> string.trim
  |> string.to_graphemes
  |> list.index_map(fn(char, index) {
    let assert Ok(size) = int.parse(char)
    case index % 2 {
      0 -> File(size: size, id: index / 2)
      _ -> Empty(size: size)
    }
  })
}

fn fragmented_compress(disk: Disk) -> Disk {
  let fragmented =
    list.map(disk, fn(block) {
      case block {
        Empty(size) -> list.repeat(Empty(size: 1), size)
        File(size, id) -> list.repeat(File(size: 1, id: id), size)
      }
    })
    |> list.flatten

  let takes =
    fragmented
    |> list.filter(fn(block) {
      case block {
        Empty(..) -> False
        _ -> True
      }
    })
    |> list.reverse
  let expected_length = list.length(takes)
  do_fragmented_compress(fragmented, takes, expected_length, [])
}

fn do_fragmented_compress(
  disk: Disk,
  takes: List(Block),
  expected_length: Int,
  result: Disk,
) -> Disk {
  let return = list.length(result) == expected_length
  use <- bool.guard(return, result)
  case disk {
    [] -> result
    [Empty(..), ..rest] ->
      case takes {
        [] -> result
        [take, ..takes_rest] ->
          do_fragmented_compress(
            rest,
            takes_rest,
            expected_length,
            list.append(result, [take]),
          )
      }
    [file, ..rest] ->
      do_fragmented_compress(
        rest,
        takes,
        expected_length,
        list.append(result, [file]),
      )
  }
}

fn disk_checksum(disk: Disk, acc: Int) -> Int {
  case disk {
    [] -> 0
    [File(0, _), ..rest] -> disk_checksum(rest, acc)
    [File(s, n), ..rest] ->
      disk_checksum([File(s - 1, n), ..rest], acc + 1) + n * acc
    [Empty(n), ..rest] -> disk_checksum(rest, acc + n)
  }
}

fn defragmented_compress(disk: Disk) -> Disk {
  do_defragmented_compress(disk, [])
}

fn do_defragmented_compress(disk: Disk, result: Disk) -> Disk {
  let reversed = list.reverse(disk)

  case list.pop(reversed, fn(_) { True }) {
    Error(_) -> result
    Ok(#(block, rest)) -> {
      let remaining = list.reverse(rest)
      handle_block(block, remaining, result)
    }
  }
}

fn handle_block(block: Block, disk: Disk, result: Disk) -> Disk {
  case block {
    Empty(..) -> do_defragmented_compress(disk, list.prepend(result, block))
    File(..) -> handle_file(block, disk, result)
  }
}

fn handle_file(file: Block, disk: Disk, result: Disk) -> Disk {
  case find_space_for_file(disk, file) {
    Error(_) -> do_defragmented_compress(disk, list.prepend(result, file))
    Ok(new_disk) ->
      do_defragmented_compress(
        new_disk,
        list.prepend(result, Empty(size: file.size)),
      )
  }
}

fn find_space_for_file(disk: Disk, file: Block) -> Result(Disk, Nil) {
  disk
  |> utillist.find_with_index(fn(block) {
    case block {
      Empty(size) if size >= file.size -> True
      _ -> False
    }
  })
  |> result.map(fn(found) {
    let #(empty, index) = found
    let disk = utillist.replace_at(disk, file, index)
    case empty.size == file.size {
      True -> disk
      False ->
        utillist.insert_at(disk, Empty(size: empty.size - file.size), index + 1)
    }
  })
  |> result.map_error(fn(_) { Nil })
}
