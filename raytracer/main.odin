package main

import fmt "core:fmt"
import util "util"
import la "core:math/linalg"

vec3 :: la.Vector3f64

main :: proc() {
    width :: 1920
    height :: 1080
    frameBuffer := [dynamic]vec3 {}
    resize(&frameBuffer, width * height)
    ctx: util.Ctx = {width, height}

    origin: vec3 = {0,0,0}
    direction: vec3

    for y in 0..< height {
        for x in 0..< width {
            direction.x = -0.5 + (f64(x) + f64(0.5)) / f64(width)
            direction.y = -0.5 + (f64(y) + f64(0.5)) / f64(width)
            direction.z = 1
            fmt.println(direction)
        }
    }

    util.write_PPM(&frameBuffer, &ctx)
}
