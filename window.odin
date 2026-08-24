package main

import "base:runtime"
import "core:os"
import "core:time"

import "vendor:glfw"
import gl "vendor:OpenGL"

import "globals"
import "ui"
import "render"

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

    if globals.ENABLE_TRANSPARENCY {
        glfw.WindowHint(glfw.TRANSPARENT_FRAMEBUFFER, glfw.TRUE)
        glfw.SetWindowOpacity(window, 1.0)
    }

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
                if ui.state.message == ui.TimerMessage.Run {
                    ui.state.message = ui.TimerMessage.Stop
                } else {
                    ui.state.message = ui.TimerMessage.Run
                }

                now := time.tick_now()

                if ui.state.started {
                    ui.state.timer.last_updated = now
                } else {
                    ui.state.timer.initial_time = now
                    ui.state.timer.last_updated = now
                    ui.state.timer.configured_duration = time.tick_add(now, globals.initial_timer)
                    ui.state.timer.remaining_duration = time.tick_diff(now, ui.state.timer.configured_duration)

                    ui.state.started = true
                }

                ui.update()
        }
    }
}

resize_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    context = runtime.default_context()

    render.clear_colour()

    gl.Viewport(0, 0, width, height)

    globals.width = width
    globals.height = height

    ui.update()
    render.render()

    glfw.SwapBuffers(window)
}

iconify_callback :: proc "c" (window: glfw.WindowHandle, iconified: i32) {
    globals.minimized = iconified > 0
}

focus_callback :: proc "c" (window: glfw.WindowHandle, focused: i32) {
    globals.focused = focused > 0

    if globals.ENABLE_TRANSPARENCY {
        if globals.focused {
            glfw.SetWindowOpacity(window, 1.0)
        } else {
            glfw.SetWindowOpacity(window, 0.75)
        }
    }
}

