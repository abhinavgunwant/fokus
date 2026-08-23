package shaders

import "core:os"
import "core:fmt"

import gl "vendor:OpenGL"

compile_default_shader :: proc () -> u32 {
    vertex_shader := `#version 330
        layout (location = 0) in vec2 pos;

        uniform vec4 color;
        out vec4 inputColor;

        void main () {
            gl_Position = vec4(pos, 0.0f, 1.0f);
            inputColor = color;
        }
    `

    fragment_shader := `#version 330
        in vec4 inputColor;
        out vec4 fragColor;

        void main () {
            fragColor = inputColor;
        }
    `

    shader, ok := gl.load_shaders_source(vertex_shader, fragment_shader)

    if !ok {
        fmt.eprintln("Error compiling shader... exiting!")
        os.exit(1)
    }

    return shader
}

