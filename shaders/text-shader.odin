package shaders

import "core:os"
import "core:fmt"

import gl "vendor:OpenGL"

compile_text_shader :: proc () -> u32 {
    vertex_shader := `
        #version 330 core

        layout (location = 0) in vec4 pos;
        out vec2 text_coords;
        uniform vec2 resolution;

        void main() {
            gl_Position = vec4(pos.xy / resolution * 2.0f - 1.0f, 0.0f, 1.0f);
            text_coords = pos.zw;
        }
    `

    fragment_shader := `
        #version 330 core

        in vec2 text_coords;
        out vec4 frag_color;
        uniform sampler2D text;
        uniform vec4 color;

        void main() {
            frag_color = color * vec4(1, 1, 1, texture(text, text_coords).r);
        }
    `

    shader, ok := gl.load_shaders_source(vertex_shader, fragment_shader)

    if !ok {
        fmt.eprintln("Error compiling shader... exiting!")
        os.exit(1)
    }

    return shader
}

