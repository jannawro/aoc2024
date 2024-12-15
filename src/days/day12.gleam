import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/yielder.{Next}
import util/file
import util/grid

pub fn part1() {
  file.read("inputs/day12.txt")
  |> grid.to(fn(x) { Ok(x) })
  |> to_regions
  |> calculate_fences_by_perimeter
  |> int.sum
  |> int.to_string
  |> io.println
}

pub fn part2() {
  file.read("inputs/day12.txt")
  |> grid.to(fn(x) { Ok(x) })
  |> to_regions
  |> calculate_fences_by_corners
  |> int.sum
  |> int.to_string
  |> io.println
}

type Region {
  Region(area: Int, perimeter: Int, corners: Int)
}

fn to_regions(grid: List(List(String))) -> Dict(#(Int, Int, String), Region) {
  let #(_visited, regions) =
    grid
    |> list.index_fold(#(set.new(), dict.new()), fn(result, row, y) {
      row
      |> list.index_fold(result, fn(result, plant, x) {
        let #(visited, regions) = result
        case set.contains(visited, #(x, y)) {
          True -> result
          False -> {
            let found = lazy_flood_search(grid, #(x, y), plant)
            let region_area = found |> set.size
            let region_perimeter =
              found
              |> set.to_list
              |> list.fold(0, fn(acc, point) {
                find_perimeter(grid, plant, point) |> int.add(acc)
              })
            let region_corners =
              found
              |> set.to_list
              |> list.fold(0, fn(acc, point) {
                find_corners(point, found) |> int.add(acc)
              })
            let new_regions =
              dict.insert(
                regions,
                #(x, y, plant),
                Region(region_area, region_perimeter, region_corners),
              )
            let new_visited = set.union(visited, found)
            #(new_visited, new_regions)
          }
        }
      })
    })
  regions
}

fn lazy_flood_search(
  grid: List(List(String)),
  start: #(Int, Int),
  plant: String,
) -> Set(#(Int, Int)) {
  let initial = #(start, set.new(), [start])

  yielder.unfold(initial, fn(state) {
    let #(current, seen, queue) = state

    case queue {
      [] -> yielder.Done
      [point, ..rest] ->
        case set.contains(seen, point), grid.at(grid, point.0, point.1) {
          False, Ok(found) if found == plant -> {
            let new_seen = set.insert(seen, point)
            let directions = [#(-1, 0), #(0, 1), #(1, 0), #(0, -1)]
            let neighbors =
              directions
              |> list.map(fn(dir) { #(point.0 + dir.0, point.1 + dir.1) })
              |> list.filter(fn(p) { !set.contains(new_seen, p) })

            Next(point, #(point, new_seen, list.append(rest, neighbors)))
          }
          _, _ -> Next(current, #(current, seen, rest))
        }
    }
  })
  |> yielder.to_list
  |> set.from_list
}

fn find_perimeter(
  grid: List(List(String)),
  plant: String,
  point: #(Int, Int),
) -> Int {
  let directions = [#(-1, 0), #(0, 1), #(1, 0), #(0, -1)]
  list.filter(directions, fn(direction) {
    case grid.at(grid, point.0 + direction.0, point.1 + direction.1) {
      Ok(found) ->
        case found == plant {
          True -> False
          False -> True
        }
      Error(_) -> True
    }
  })
  |> list.length
}

fn calculate_fences_by_perimeter(
  regions: Dict(#(Int, Int, String), Region),
) -> List(Int) {
  regions
  |> dict.values
  |> list.map(fn(region) { region.area * region.perimeter })
}

fn find_corners(point: #(Int, Int), area: Set(#(Int, Int))) -> Int {
  let #(x, y) = point
  let outside_corners = [
    // different plant, different plant
    #(#(0, -1), #(-1, 0)),
    #(#(0, -1), #(1, 0)),
    #(#(1, 0), #(0, 1)),
    #(#(-1, 0), #(0, 1)),
  ]
  let inside_corners = [
    // same plant, same plant, different plant
    #(#(0, -1), #(-1, 0), #(-1, -1)),
    #(#(0, -1), #(1, 0), #(1, -1)),
    #(#(1, 0), #(0, 1), #(1, 1)),
    #(#(-1, 0), #(0, 1), #(-1, 1)),
  ]
  let is_outside_corner =
    list.filter(outside_corners, fn(corner) {
      let #(diff1, diff2) = corner
      case
        set.contains(area, #(x + diff1.0, y + diff1.1)),
        set.contains(area, #(x + diff2.0, y + diff2.1))
      {
        False, False -> True
        _, _ -> False
      }
    })
    |> list.length
  let is_inside_corner =
    list.filter(inside_corners, fn(corner) {
      let #(same1, same2, diff) = corner
      case
        set.contains(area, #(x + same1.0, y + same1.1)),
        set.contains(area, #(x + same2.0, y + same2.1)),
        set.contains(area, #(x + diff.0, y + diff.1))
      {
        True, True, False -> True
        _, _, _ -> False
      }
    })
    |> list.length
  is_inside_corner + is_outside_corner
}

fn calculate_fences_by_corners(
  regions: Dict(#(Int, Int, String), Region),
) -> List(Int) {
  regions
  |> dict.values
  |> list.map(fn(region) { region.area * region.corners })
}
