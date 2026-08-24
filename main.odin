package main

import "shaders"
import "render"

main :: proc () {
    parse_args()

    window := show_window()

    shaders.init()
    render.init()

    render.loop(window)
}

