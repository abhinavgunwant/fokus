package shaders

import "core:os"
import "core:fmt"

import gl "vendor:OpenGL"

default : u32
text : u32

u_default_color : u32
u_text_color : u32
u_text_resolution : u32

init :: proc () {
    default = compile_default_shader()
    text = compile_text_shader()

    u_default_color = u32(gl.GetUniformLocation(default, "color"))
    u_text_color = u32(gl.GetUniformLocation(text, "color"))
    u_text_resolution = u32(gl.GetUniformLocation(text, "resolution"))
}

