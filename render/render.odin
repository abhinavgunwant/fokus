package render

import "core:fmt"
import "core:time"

import gl "vendor:OpenGL"

import "../globals"
import "../shaders"
import "../ui"

vbo : u32
vao : u32

init :: proc () {
    init_fonts()
    init_buffers()

    gl.ClearColor(0, 0, 0, 1.0);
}

render :: proc () {
    if ui.state.updated || ui.state.message == ui.TimerMessage.Run {
        reset_text()

        switch ui.state.screen {
            case ui.Screen.Start:
                update_time()
                update_text_buffer()
            case ui.Screen.Settings:
        }

        ui.state.updated = false
    }

    switch ui.state.screen {
        case ui.Screen.Start:
            render_text()
        case ui.Screen.Settings:
            gl.BindVertexArray(vao)
            gl.UseProgram(shaders.default)
            gl.Uniform4f(i32(shaders.u_default_color), 1.0, 0, 0, 1.0)
            gl.DrawArrays(gl.TRIANGLES, 0, 3)
    }
}

get_time_string :: proc () -> string {
    now := time.tick_now()

    if ui.state.message == ui.TimerMessage.Run {
        ui.state.timer.remaining_duration -= time.tick_diff(ui.state.timer.last_updated, now)
        ui.state.timer.last_updated = now

        if ui.state.timer.remaining_duration < 0 {
            ui.state.message = ui.TimerMessage.Finished
            ui.state.timer.remaining_duration = 0
            ui.state.started = false
        }
    }

    buf : [20] u8

    h, m, s, n := time.precise_clock_from_duration(ui.state.timer.remaining_duration)

    if h > 0 {
        return fmt.tprintf("%2v:%2v:%2v", h, m, s)
    }

    return fmt.tprintf("%2v:%2v", m, s)
}

update_time :: proc () {
    time_string : string = get_time_string()
    helper_string : string

    switch ui.state.message {
        case ui.TimerMessage.Run:
            helper_string = "Space: stop"
        case ui.TimerMessage.Stop:
            helper_string = "Space: start"
        case ui.TimerMessage.Finished:
            helper_string = "Finished!"
    }

    time_str_w, time_str_h := get_text_dimensions(128, time_string)

    x_offset := (f32(globals.width) - time_str_w) / 2
    y_offset := (f32(globals.height) - time_str_h) / 2

    append_text_buffer(x_offset, y_offset, 128, time_string)

    helper_str_w, helper_str_h := get_text_dimensions(32, helper_string)

    x_offset = (f32(globals.width) - helper_str_w) / 2

    append_text_buffer(x_offset, 16, 32, helper_string)
}

