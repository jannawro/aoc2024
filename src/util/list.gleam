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
