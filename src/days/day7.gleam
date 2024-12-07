import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util/file
import util/list as utillist

pub fn part1() {
  file.read("inputs/day7.txt")
  |> to_equations
  |> list.filter_map(fn(equation) {
    let #(target, products) = equation
    let variants =
      products
      |> list.length
      |> int.subtract(1)
      |> generate_operations_variants([Add, Multiply])

    case test_operation_variants(equation, variants) {
      True -> Ok(target)
      False -> Error(Nil)
    }
  })
  |> int.sum
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day7.txt")
  |> to_equations
  |> list.filter_map(fn(equation) {
    let #(target, products) = equation
    let variants =
      products
      |> list.length
      |> int.subtract(1)
      |> generate_operations_variants([Add, Multiply, Combine])

    case test_operation_variants(equation, variants) {
      True -> Ok(target)
      False -> Error(Nil)
    }
  })
  |> int.sum
  |> int.to_string
  |> io.println
}

fn to_equations(input: String) -> List(#(Int, List(Int))) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert [test_value, product_values] = line |> string.split(on: ": ")
    let assert Ok(test_number) = int.parse(test_value)

    let product_numbers =
      product_values
      |> string.split(on: " ")
      |> list.map(fn(value) {
        let assert Ok(value_num) = int.parse(value)
        value_num
      })

    #(test_number, product_numbers)
  })
}

type Operation {
  Add
  Multiply
  Combine
}

fn test_operation_variants(
  equation: #(Int, List(Int)),
  operations_variants: List(List(Operation)),
) -> Bool {
  let #(target, products) = equation
  let assert [first, ..rest] = products

  operations_variants
  |> list.any(fn(operations) {
    rest
    |> list.index_fold(first, fn(acc, product, index) {
      let assert Ok(operation) = utillist.at(operations, index)
      case operation {
        Add -> acc + product
        Multiply -> acc * product
        Combine -> combine(acc, product)
      }
    })
    == target
  })
}

fn generate_operations_variants(
  n: Int,
  operations: List(Operation),
) -> List(List(Operation)) {
  case n {
    0 -> [[]]
    _ ->
      generate_operations_variants(n - 1, operations)
      |> list.flat_map(fn(combo) {
        list.map(operations, fn(op) { [op, ..combo] })
      })
  }
}

fn combine(a: Int, b: Int) -> Int {
  let combined = int.to_string(a) <> int.to_string(b)
  let assert Ok(result) = int.parse(combined)
  result
}
