package main

import "shaders"
import "render"

main :: proc () {
    window := show_window()

    shaders.init()
    render.init()

    render.loop(window)
}

