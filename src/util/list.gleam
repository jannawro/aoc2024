import gleam/list

pub fn difference(list1: List(a), list2: List(a)) -> List(a) {
  let #(not_in_list2, _) =
    list.partition(list1, fn(x) { !list.contains(list2, x) })
  not_in_list2
}

pub fn at(list: List(a), index: Int) -> Result(a, Nil) {
  case list, index {
    [], _ -> Error(Nil)
    [head, ..], 0 -> Ok(head)
    [_, ..tail], i if i > 0 -> at(tail, i - 1)
    _, _ -> Error(Nil)
  }
}

pub fn find_middle(list: List(a)) -> Result(a, Nil) {
  case list {
    [] -> Error(Nil)
    [single] -> Ok(single)
    _ -> {
      let length = list |> list.length
      let middle_index = length / 2
      list |> at(middle_index)
    }
  }
}

pub fn merge(list1: List(a), list2: List(a)) -> List(a) {
  case list1 {
    [] -> list2
    [first, ..rest1] ->
      case list2 {
        [] -> list1
        [_, ..rest2] -> [first, ..merge(rest1, rest2)]
      }
  }
}

pub fn find_with_index(
  list: List(a),
  condition: fn(a) -> Bool,
) -> Result(#(a, Int), Nil) {
  list
  |> list.index_fold(Error(Nil), fn(acc, element, index) {
    case acc {
      Ok(_) -> acc
      Error(_) ->
        case condition(element) {
          True -> Ok(#(element, index))
          False -> Error(Nil)
        }
    }
  })
}

pub fn insert_at(list: List(a), element: a, index: Int) -> List(a) {
  case index {
    0 -> [element, ..list]
    _ -> {
      let #(before, after) = list.split(list, index)
      list.append(before, [element, ..after])
    }
  }
}

pub fn replace_at(list: List(a), element: a, index: Int) -> List(a) {
  case list, index {
    [], _ -> []
    [_, ..rest], 0 -> [element, ..rest]
    [head, ..tail], i -> [head, ..replace_at(tail, element, i - 1)]
  }
}

pub fn windows(list: List(a), size: Int) -> List(#(List(#(Int, a)), List(Int))) {
  case size <= 0 || list == [] {
    True -> []
    False -> do_windows(list, size, 0, [])
  }
}

fn do_windows(
  list: List(a),
  size: Int,
  current_index: Int,
  acc: List(#(List(#(Int, a)), List(Int))),
) -> List(#(List(#(Int, a)), List(Int))) {
  case list {
    [] -> acc
    [_, ..rest] as current -> {
      case take_window(current, size, current_index) {
        Ok(window) -> {
          let indexes = range(current_index, current_index + size - 1)
          do_windows(rest, size, current_index + 1, [#(window, indexes), ..acc])
        }
        Error(Nil) -> acc
      }
    }
  }
}

fn take_window(
  list: List(a),
  size: Int,
  start_index: Int,
) -> Result(List(#(Int, a)), Nil) {
  case list {
    [] if size > 0 -> Error(Nil)
    [] -> Ok([])
    [x, ..xs] if size > 0 -> {
      case take_window(xs, size - 1, start_index + 1) {
        Ok(rest) -> Ok([#(start_index, x), ..rest])
        Error(Nil) -> Error(Nil)
      }
    }
    _ -> Ok([])
  }
}

fn range(start: Int, end: Int) -> List(Int) {
  case start > end {
    True -> []
    False -> [start, ..range(start + 1, end)]
  }
}
