package main

import (
	"bufio"
	"fmt"
	"maps"
	"os"
	"slices"
	"sync"
)

func main() {
	lines := read("inputs/day6.txt")

	var start Position
	grid := make([][]int, len(lines))
	traversed := make(map[Position][]Direction)

	for row, line := range lines {
		grid[row] = make([]int, len(line))
		for column, char := range line {
			switch char {
			case '#':
				grid[row][column] = 1
			case '^':
				start = Position{column, row}
				grid[row][column] = 0
			case '.':
				grid[row][column] = 0
			}
		}
	}

	part1 := part1(grid, start, traversed)
	fmt.Println("Part1:", part1)

	part2 := part2(grid, start, traversed)
	fmt.Println("Part2:", part2)
}

func part1(grid [][]int, start Position, traversed map[Position][]Direction) int {
	var current, next Position
	direction := Direction{0, -1}
	current = start
	for current.x > 0 && current.x < len(grid[0])-1 && current.y > 0 && current.y < len(grid)-1 {
		traversed[current] = append(traversed[current], Direction{direction.x, direction.y})
		next = Position{
			x: current.x + direction.x,
			y: current.y + direction.y,
		}

		switch grid[next.y][next.x] {
		case 0:
			current = next
			continue
		case 1:
			direction.rotate_90_degrees()
			next.x = current.x + direction.x
			next.y = current.y + direction.y
			current = next
		}
	}
	return len(traversed) + 1
}

func part2(grid [][]int, start Position, traversed map[Position][]Direction) int {
	var count int
	wg := sync.WaitGroup{}

	for traversedPosition := range maps.Keys(traversed) {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if looped(traversedPosition, start, grid) {
				count++
			}
		}()
	}
	wg.Wait()
	return count + 1
}

func read(fileName string) []string {
	var lines []string
	file, err := os.Open(fileName)
	if err != nil {
		fmt.Println(err)
	}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
	}
	return lines

}

type Position struct {
	x, y int
}

type Direction struct {
	x, y int
}

func (d *Direction) rotate_90_degrees() {
	d.x, d.y = -d.y, d.x
}

func looped(p, start Position, grid [][]int) bool {
	gridVariant := make([][]int, len(grid))
	for i := range grid {
		gridVariant[i] = make([]int, len(grid[i]))
		copy(gridVariant[i], grid[i])
	}
	gridVariant[p.y][p.x] = 1
	var current, next Position
	traversed := make(map[Position][]Direction)
	current = start
	direction := Direction{0, -1}

	for current.x > 0 && current.x < len(gridVariant[0])-1 && current.y > 0 && current.y < len(gridVariant)-1 {
		traversed[current] = append(traversed[current], Direction{direction.x, direction.y})
		next = Position{
			x: current.x + direction.x,
			y: current.y + direction.y,
		}

		switch gridVariant[next.y][next.x] {
		case 0:
			if slices.Contains(
				traversed[Position{next.x, next.y}],
				Direction{direction.x, direction.y},
			) {
				return true
			}
			current = next
		case 1:
			direction.rotate_90_degrees()
		}
	}
	return false
}
