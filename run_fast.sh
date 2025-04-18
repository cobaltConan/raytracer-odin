#!/bin/fish

if odin run raytracer/ -o:speed
    swayimg some-bytes.ppm
else
    echo oopsie woopsie
end
