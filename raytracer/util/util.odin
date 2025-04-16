package util

import la "core:math/linalg"
import "core:fmt"
import "core:os"

vec3 :: la.Vector3f64

Sphere :: struct {
    radius: f64,
    centre: vec3,
    colour: vec3,
}

Triangle :: struct {
    v0: vec3,
    v1: vec3,
    v2: vec3,
    colour: vec3,
}

Primitive :: union {
    Triangle,
    Sphere,
}

Ctx :: struct {
    width: int,
    height: int,
    primitives: [dynamic]Primitive,
};

write_PPM :: proc(framebuffer: ^[dynamic]vec3, ctx: ^Ctx) {
    bytes: [dynamic]u8
    // ppm file setup
    append_elem_string(&bytes, "P3\n")
    append_elem_string(&bytes, fmt.aprint(ctx.width))
    append_elem_string(&bytes, " ")
    append_elem_string(&bytes, fmt.aprint(ctx.height))
    append_elem_string(&bytes, "\n")
    append_elem_string(&bytes, "255\n")

    for i in 0..< ctx.height * ctx.width {
        for j in 0..< 3 {
            // append_elem_string(&bytes, fmt.aprint(byte(255 * max(0, min(1, framebuffer[i][j])))))
            append_elem_string(&bytes, fmt.aprint(byte(framebuffer[i][j])))
            if (j != 3) {
                append_elem_string(&bytes, " ")
            }
        }
        append_elem_string(&bytes, "\n")
    }

    os.write_entire_file("some-bytes.ppm", bytes[:])

}
