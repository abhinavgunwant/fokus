package render

import "core:fmt"
import "core:time"

import gl "vendor:OpenGL"

import "../globals"
import "../shaders"
import "../ui"

vbo : u32
vao : u32

prev_duration : time.Duration = 0

init :: proc () {
    init_fonts()
    init_icons()
    init_buffers()

    when ODIN_OS_STRING == "windows" {
        gl.ClearColor(0.11, 0.11, 0.11, 1.0);
    } else {
        gl.ClearColor(0, 0, 0, 1.0);
    }
}

render :: proc () {
    switch ui.state.screen {
        case ui.Screen.Start:
            remaining_seconds : time.Duration = cast(time.Duration) i64(time.duration_seconds(ui.state.timer.remaining_duration))

            if ui.state.updated || ui.state.message == ui.TimerMessage.Run && remaining_seconds != prev_duration {
                reset_text()
                reset_icon()

                update_time()
                update_text_buffer()
                update_icon()
                update_icon_buffer()

                ui.state.updated = false

                prev_duration = remaining_seconds
            }

            render_text()
            render_icon()
        case ui.Screen.Settings:
            gl.BindVertexArray(vao)
            gl.UseProgram(shaders.default)
            gl.Uniform4f(i32(shaders.u_default_color), 1.0, 0, 0, 1.0)
            gl.DrawArrays(gl.TRIANGLES, 0, 3)
    }

    ui.tick()
}

update_time :: proc () {
    time_string : string = ui.get_time_string()
    helper_string : string = "Press space"

    time_str_w, time_str_h := get_text_dimensions(128, time_string)

    x_offset := (f32(globals.width) - time_str_w) / 2
    y_offset := (f32(globals.height) - time_str_h) / 2

    append_text_buffer(x_offset, y_offset, 128, time_string)

    helper_str_w, helper_str_h := get_text_dimensions(24, helper_string)

    x_offset = (f32(globals.width) - helper_str_w) / 2

    append_text_buffer(x_offset, 16, 24, helper_string)
}

update_icon :: proc () {
    ICON_WIDTH :: 32

    x_offset := (f32(globals.width) - ICON_WIDTH) / 2

    switch ui.state.message {
        case ui.TimerMessage.Run:
            append_icon_buffer(x_offset, 40, ICON_WIDTH, ICON_PAUSE)
        case ui.TimerMessage.Finished:
            append_icon_buffer(x_offset, 40, ICON_WIDTH, ICON_PAUSE)
        case ui.TimerMessage.Stop:
            append_icon_buffer(x_offset, 40, ICON_WIDTH, ICON_PLAY)
    }
}

