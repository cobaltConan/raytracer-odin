package main

import fmt "core:fmt"
import util "util"
import la "core:math/linalg"
import "core:math"
import "parser"
import "core:os"

BACKGROUND_COLOUR :: vec3{0,0,0}
vec3 :: la.Vector3f64

traceRay :: proc(origin: ^vec3, direction: ^vec3, t_min: f64, t_max: f64, ctx: ^util.Ctx) -> (colour: vec3) {
    closest_t: f64 = 1e10
    closest_prim: util.Primitive
    closest_sphere_bool := false
    t1, t2, t, u, v: f64
    hit: bool
    for &primitive in ctx.primitives {
        switch prim_type in primitive { 
        case util.Sphere: {
            sphere := prim_type
            t1, t2 = intersectRaySphere(origin, direction, &sphere)
            if t1 > t_min && t1 < t_max && t1 < closest_t {
                closest_t = t1
                closest_prim = sphere
                closest_sphere_bool = true
            }        
            if t2 > t_min && t1 < t_max && t2 < closest_t {
                closest_t = t2
                closest_prim = sphere
                closest_sphere_bool = true
            }
            }
        case util.Triangle: {
             triangle := prim_type
             t, u, v, hit = intersectRayTri(origin, direction, &triangle)
             if hit && t < closest_t && t > t_min{
                u *= 255
                v *= 255
                closest_sphere_bool = true
                closest_t = t
                triangle.colour = vec3{255,0,0}
                // triangle.colour = vec3{u,v,1-u-v}
                closest_prim = triangle
             }
        }
        }
    }
    if !closest_sphere_bool {
        return BACKGROUND_COLOUR
    }

    switch prim_type in closest_prim {
        case util.Sphere:
            return closest_prim.(util.Sphere).colour
        case util.Triangle:
            return closest_prim.(util.Triangle).colour
    }
    return // shouldn't reach this code
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

intersectRayTri :: proc(origin: ^vec3, direction: ^vec3, tri: ^util.Triangle) -> (t: f64, u:f64, v: f64, hit: bool) {
    e0: vec3 = tri.v0 - tri.v2
    e1: vec3 = tri.v1 - tri.v2
    pvec: vec3 = la.cross(direction^, e1)
    det: f64 = la.dot(e0, pvec)
    if (det < 0.001) {hit = false; return}
    invDet: f64 = 1 / det

    tvec: vec3 = origin^ - tri.v2
    u = la.dot(tvec, pvec) * invDet
    if u < 0 || u > 1 {hit = false; return}

    qvec: vec3 = la.cross(tvec, e0)
    v = la.dot(direction^, qvec) * invDet
    if v < 0 || u + v > 1 {hit = false; return}

    t = la.dot(e1, qvec) * invDet

    hit = true
    return
}

main :: proc() {
    width :: 1920
    height :: 1080
    frameBuffer := [dynamic]vec3 {}

    sphere1 := util.Sphere {
        centre = {-3, 0, 10},
        radius = 1,
        colour = {255, 0 ,0}
    }

    tri1 := util.Triangle {
        v0 = {-3, -3, 10},
        v1 = {-1, -1, 10},
        v2 = {3, -3, 10},
        colour = {255, 0, 0}
    }

    primitive1: util.Primitive = sphere1
    primitive2: util.Primitive = tri1

    resize(&frameBuffer, width * height)
    primitives: [dynamic]util.Primitive
    append(&primitives, primitive1, primitive2)

    origin: vec3 = {0,0,0}
    direction: vec3
    colour: vec3

    fov: f64 = 51.52
    scale: f64 = math.tan(math.to_radians(fov * 0.5))
    imageAspectRatio: f64 = f64(width) / f64(height)

    vertBuf: [dynamic]vec3
    faceBuf: [dynamic][3]int
    parser.parseObjFile("assets/teapot.obj", &vertBuf, &faceBuf)

    fmt.println(len(vertBuf))
    fmt.println(len(faceBuf))

    tempTri: util.Triangle
    tempTri.colour = vec3{255,255,0}
    tempPrim: util.Primitive
    for face in faceBuf {
        tempTri.v0 = vertBuf[face[0]] 
        tempTri.v1 = vertBuf[face[1]] 
        tempTri.v2 = vertBuf[face[2]] 
        tempTri.v0.z += 10
        tempTri.v1.z += 10
        tempTri.v2.z += 10
        tempPrim = tempTri
        append(&primitives, tempPrim)
    }    

    ctx: util.Ctx = {width, height, primitives}
    
    totalPixel: f64 = height * width
    currPixel: int
    percentDone: f64

    for y in 0..< height {
        for x in 0..< width {
            // direction.x = -0.5 + (f64(x) + f64(0.5)) / f64(width)
            // direction.y = -0.5 + (f64(y) + f64(0.5)) / f64(width)
            direction.x = (2 * (f64(x) + 0.5) / width - 1) * imageAspectRatio * scale
            direction.y = (1 - 2 * (f64(y) + 0.5) / height) * scale
            direction.z = 1
            colour = traceRay(&origin, &direction, 1, 1e10, &ctx)
            frameBuffer[width*y + x] = colour

            percentDone = 100 * f64(currPixel) / totalPixel
            fmt.printf("\rPercent done: %.2f%%", percentDone)
            os.flush(os.stdout)
            currPixel += 1
        }
    }

    

    util.write_PPM(&frameBuffer, &ctx)
}
