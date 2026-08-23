package render

import "core:fmt"

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
    if ui.state.updated {
        // Make required changes to buffers here...

        fmt.println("State updated... updating buffers...")

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

update_time :: proc () {
    // TODO: update the time here...

    time_string := "30:00"

    time_str_w, time_str_h := get_text_dimensions(128, time_string)

    fmt.println("text width:", time_str_w)
    x_offset := (f32(globals.width) - time_str_w) / 2
    y_offset := (f32(globals.height) - time_str_h) / 2

    append_text_buffer(x_offset, y_offset, 128, time_string)
}

