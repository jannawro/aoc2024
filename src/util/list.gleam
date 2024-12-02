import gleam/list

pub fn difference(list1: List(a), list2: List(a)) -> List(a) {
  let #(not_in_list2, _) =
    list.partition(list1, fn(x) { !list.contains(list2, x) })
  not_in_list2
}
