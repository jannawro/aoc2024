import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/result
import gleam/string
import util/file
import util/list as utillist

pub fn part1() {
  let #(rules, updates) =
    file.read("inputs/day5.txt")
    |> split_rules_and_updates

  let parsed_rules = rules |> parse_rules

  updates
  |> parse_updates
  |> filter_to_rules(parsed_rules, True)
  |> list.map(fn(update) {
    let assert Ok(mid) = update |> utillist.find_middle
    mid
  })
  |> utillist.sum
  |> int.to_string
  |> io.println
}

pub fn part2() {
  let #(rules, updates) =
    file.read("inputs/day5.txt")
    |> split_rules_and_updates

  let parsed_rules = rules |> parse_rules

  updates
  |> parse_updates
  |> filter_to_rules(parsed_rules, False)
  |> list.map(fn(update) {
    update
    |> sort_to_rule(parsed_rules)
  })
  |> list.map(fn(update) {
    let assert Ok(mid) = update |> utillist.find_middle
    mid
  })
  |> utillist.sum
  |> int.to_string
  |> io.println
}

fn split_rules_and_updates(input: String) -> #(String, String) {
  let assert [rules, updates] =
    input
    |> string.trim
    |> string.split(on: "\n\n")
  #(rules, updates)
}

fn parse_rules(input: String) -> Dict(Int, List(Int)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert [left, right] =
      line
      |> string.split(on: "|")
    let assert Ok(first) = int.parse(left)
    let assert Ok(second) = int.parse(right)
    #(first, second)
  })
  |> list.fold(dict.new(), fn(rules, pair) {
    use present_value <- dict.upsert(rules, pair.0)
    case present_value {
      Some(elements) -> list.append(elements, list.wrap(pair.1))
      None -> list.wrap(pair.1)
    }
  })
}

fn parse_updates(input: String) -> List(List(Int)) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    line
    |> string.split(on: ",")
    |> list.map(fn(element) {
      let assert Ok(number) = int.parse(element)
      number
    })
  })
}

fn is_update_correct(update: List(Int), rules: Dict(Int, List(Int))) -> Bool {
  update
  |> list.index_map(fn(element, index) {
    let #(_head, tail) = update |> list.split(index + 1)
    case tail {
      [] -> True
      _ -> {
        let rule = rules |> dict.get(element) |> result.unwrap([])
        tail
        |> list.all(fn(x) { rule |> list.contains(x) })
      }
    }
  })
  |> list.all(fn(x) { x == True })
}

fn filter_to_rules(
  updates: List(List(Int)),
  rules: Dict(Int, List(Int)),
  expect_correct: Bool,
) -> List(List(Int)) {
  updates
  |> list.fold([], fn(result, update) {
    let is_correct = update |> is_update_correct(rules)
    case is_correct == expect_correct {
      True -> list.append(result, list.wrap(update))
      False -> result
    }
  })
}

fn sort_to_rule(update: List(Int), rules: Dict(Int, List(Int))) -> List(Int) {
  update |> list.sort(fn(a, b) { custom_compare(rules, a, b) })
}

fn custom_compare(rules: Dict(Int, List(Int)), a: Int, b: Int) -> order.Order {
  case dict.get(rules, a) {
    Ok(dependencies) -> {
      case list.contains(dependencies, b) {
        True -> order.Gt
        False -> {
          case dict.get(rules, b) {
            Ok(b_deps) ->
              case list.contains(b_deps, a) {
                True -> order.Lt
                False -> order.Eq
              }
            Error(_) -> order.Eq
          }
        }
      }
    }
    Error(_) -> order.Eq
  }
}
