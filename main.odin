package main

import "core:thread"

import "shaders"
import "render"
import "timer"

main :: proc () {
    window := show_window()

    shaders.init()
    render.init()
    worker := timer.init()
    defer thread.terminate(worker, 0)

    render.loop(window)
}

