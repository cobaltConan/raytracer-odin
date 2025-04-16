package main

import fmt "core:fmt"
import util "util"
import la "core:math/linalg"
import "core:math"

BACKGROUND_COLOUR :: vec3{0,0,50}
vec3 :: la.Vector3f64

traceRay :: proc(origin: ^vec3, direction: ^vec3, t_min: f64, t_max: f64, ctx: ^util.Ctx) -> (colour: vec3) {
    closest_t: f64 = 1e10
    closest_sphere: util.Sphere
    closest_sphere_bool := false
    t1, t2: f64
    for &sphere in ctx.spheres {
        t1, t2 = intersectRaySphere(origin, direction, &sphere)
        if t1 > t_min && t1 < t_max && t1 < closest_t {
            closest_t = t1
            closest_sphere = sphere
            closest_sphere_bool = true
        }        
        if t2 > t_min && t1 < t_max && t2 < closest_t {
            closest_t = t2
            closest_sphere = sphere
            closest_sphere_bool = true
        }
    }
    if !closest_sphere_bool {
        return BACKGROUND_COLOUR
    }
    return closest_sphere.colour
}

intersectRaySphere :: proc(origin: ^vec3, direction: ^vec3, sphere: ^util.Sphere) -> (f64, f64) {
    r := sphere.radius
    co := origin^ - sphere.centre

    a := la.dot(direction^, direction^)
    b := 2 * la.dot(co, direction^)
    c := la.dot(co, co) - r*r

    discriminant := b*b - 4*a*c
    if discriminant < 0 {
        return 1e10, 1e10
    }

    t1 := (-b + math.sqrt(discriminant)) / (2*a)
    t2 := (-b - math.sqrt(discriminant)) / (2*a)
    return t1, t2
}

main :: proc() {
    width :: 1920
    height :: 1080
    frameBuffer := [dynamic]vec3 {}

    sphere1 := util.Sphere{
        centre = {0, -1, 3},
        radius = 1,
        colour = {255, 0 ,0}
    }

    sphere2 := util.Sphere{
        centre = {0, 1, 3},
        radius = 1,
        colour = {0, 0, 255}
    }

    sphere3 := util.Sphere{
        centre = {-2, 0, 4},
        radius = 1,
        colour = {0, 255 ,0}
    }

    resize(&frameBuffer, width * height)
    spheres: [dynamic]util.Sphere
    append(&spheres, sphere1, sphere2, sphere3)
    ctx: util.Ctx = {width, height, spheres}

    origin: vec3 = {0,0,0}
    direction: vec3
    colour: vec3

    for y in 0..< height {
        for x in 0..< width {
            direction.x = -0.5 + (f64(x) + f64(0.5)) / f64(width)
            direction.y = -0.5 + (f64(y) + f64(0.5)) / f64(width)
            direction.z = 1
            colour = traceRay(&origin, &direction, 1, 1e10, &ctx)
            frameBuffer[width*y + x] = colour
        }
    }

    

    util.write_PPM(&frameBuffer, &ctx)
}
