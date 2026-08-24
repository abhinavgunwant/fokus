package render

import "vendor:glfw"
import gl "vendor:OpenGL"

import "../globals"

loop :: proc (window: glfw.WindowHandle) {
    for !glfw.WindowShouldClose(window) {
        gl.Clear(gl.COLOR_BUFFER_BIT)

        if globals.minimized {
            glfw.WaitEventsTimeout(4)
        }

        if !globals.focused {
            glfw.WaitEventsTimeout(0.1)
        }

        render()

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }
}

