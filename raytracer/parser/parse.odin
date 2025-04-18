package parser

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import la "core:math/linalg"

vec3 :: la.Vector3f64

parseObjFile :: proc(filepath: string, vertBuf: ^[dynamic]vec3, faceBuf: ^[dynamic][3]int) {
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
        fmt.println("Could not access obj file")
		return
	}
	defer delete(data, context.allocator)
    v0, v1, v2: f64
    f0, f1, f2: int

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
        if line == "" {continue}
        parts := strings.split(line, " ")
        if parts[0] == "v" {
            v0, _ = strconv.parse_f64(parts[1])
            v1, _ = strconv.parse_f64(parts[2])
            v2, _ = strconv.parse_f64(parts[3])
            append(vertBuf, vec3{v0, v1, v2})
        } else if parts[0] == "f" {
            f0, _ = strconv.parse_int(parts[1])
            f1, _ = strconv.parse_int(parts[2])
            f2, _ = strconv.parse_int(parts[3])
            f0 -= 1
            f1 -= 1
            f2 -= 1
            append(faceBuf, [3]int{f0, f1, f2})
        }
	}
}
