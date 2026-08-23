package main

import "core:os"
import "core:fmt"
import "base:runtime"

import "vendor:glfw"
import gl "vendor:OpenGL"

import "globals"
import "ui"

show_window :: proc () -> glfw.WindowHandle {
    glfw.Init()
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, globals.OPENGL_VERSION_MAJOR)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, globals.OPENGL_VERSION_MINOR)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window: glfw.WindowHandle = glfw.CreateWindow(
        globals.width,
        globals.height,
        globals.APP_NAME,
        nil,
        nil,
    )

    glfw.MakeContextCurrent(window)
    glfw.SetKeyCallback(window, key_callback);
    glfw.SetWindowSizeCallback(window, resize_callback)
    glfw.SetWindowIconifyCallback(window, iconify_callback)
    glfw.SetWindowFocusCallback(window, focus_callback)

    gl.load_up_to(
        globals.OPENGL_VERSION_MAJOR,
        globals.OPENGL_VERSION_MINOR,
        glfw.gl_set_proc_address
    )

    return window
}

key_callback :: proc "c" (
    window: glfw.WindowHandle, key, scancode, action, mods: i32
) {
    context = runtime.default_context()

    if key == glfw.KEY_UNKNOWN { return }

    if action == glfw.PRESS || action == glfw.REPEAT {
        switch key {
            case glfw.KEY_ESCAPE:
                os.exit(0)
            case glfw.KEY_SPACE:
                if ui.state.screen == ui.Screen.Settings {
                    ui.state.screen = ui.Screen.Start
                } else {
                    ui.state.screen = ui.Screen.Settings
                }

                ui.update()

                // Implement other keys here...
        }
    } else {
        // Implement what happens when key is released here...
    }
}

resize_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}

iconify_callback :: proc "c" (window: glfw.WindowHandle, iconified: i32) {
    globals.minimized = iconified > 0
}

focus_callback :: proc "c" (window: glfw.WindowHandle, focused: i32) {
    globals.focused = focused > 0
}

