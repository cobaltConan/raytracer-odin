#!/bin/fish

if odin run raytracer/ -debug
    swayimg some-bytes.ppm
else
    echo oopsie woopsie
end
