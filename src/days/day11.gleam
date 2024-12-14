import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util/cache.{type Cache}
import util/file

pub fn part1() {
  file.read("inputs/day11.txt")
  |> to_stones
  |> blink_stones(25)
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day11.txt")
  |> to_stones
  |> blink_stones(75)
  |> int.to_string
  |> io.println
}

type Stone {
  Stone(number: Int, digits_even: Bool)
}

fn to_stones(input: String) -> List(Stone) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(fn(char) {
    let assert Ok(number) = int.parse(char)
    let digits_even = string.length(char) |> int.is_even
    Stone(number, digits_even)
  })
}

fn blink_stones(stones: List(Stone), max_blinks: Int) -> Int {
  use cache <- cache.create()
  list.map(stones, blink_stone(_, 0, max_blinks, 0, cache))
  |> int.sum
  |> int.add(list.length(stones))
}

fn blink_stone(
  stone: Stone,
  blinks: Int,
  max_blinks: Int,
  acc: Int,
  cache: Cache(#(Stone, Int), Int),
) -> Int {
  let return = blinks == max_blinks
  use <- bool.guard(return, acc)
  use <- cache.memoize(cache, #(stone, blinks))

  case stone.number == 0, stone.digits_even {
    True, _ -> {
      let new_stone = first_rule(stone)
      blink_stone(new_stone, blinks + 1, max_blinks, acc, cache)
    }
    False, True -> {
      let #(left_stone, right_stone) = second_rule(stone)
      int.add(
        blink_stone(left_stone, blinks + 1, max_blinks, acc, cache),
        blink_stone(right_stone, blinks + 1, max_blinks, acc, cache),
      )
      + 1
    }
    False, False -> {
      let new_stone = third_rule(stone)
      blink_stone(new_stone, blinks + 1, max_blinks, acc, cache)
    }
  }
}

fn first_rule(_stone: Stone) -> Stone {
  Stone(1, False)
}

fn second_rule(stone: Stone) -> #(Stone, Stone) {
  let assert Ok(digits) = stone.number |> int.digits(10)
  let #(left, right) =
    list.split(
      digits,
      list.length(digits)
        |> int.divide(2)
        |> result.unwrap(1),
    )
  let assert Ok(left_int) = int.undigits(left, 10)
  let assert Ok(right_int) = int.undigits(right, 10)

  #(
    Stone(left_int, digits_even(left_int)),
    Stone(right_int, digits_even(right_int)),
  )
}

fn third_rule(stone: Stone) -> Stone {
  let new_number = stone.number * 2024
  Stone(new_number, digits_even(new_number))
}

fn digits_even(number: Int) -> Bool {
  number
  |> int.digits(10)
  |> result.unwrap([])
  |> list.length
  |> int.is_even
}
