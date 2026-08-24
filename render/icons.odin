package render

import "core:slice"
import "core:fmt"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

import "../shaders"
import "../globals"

ICON_PLAY :: 0
ICON_PAUSE :: 1
ICON_BUFFER_INITIAL_SIZE :: 512
ICON_ATLAS_WIDTH :: 203
ICON_ATLAS_HEIGHT :: 130

Icon :: struct {
    x0 : f32,
    y0 : f32,
    x1 : f32,
    y1 : f32,
    aspect_ratio: f32,
}

icons : [2] Icon
icon_texture : u32

icon_vao : u32
icon_vbo : u32

icon_buffer : [dynamic] f32
icon_buffer_size : u32 = ICON_BUFFER_INITIAL_SIZE
icon_vertices : u32

init_icons :: proc () {
    icons[ICON_PLAY] = {
        0.0049, 0.0076,
        0.4975, 0.9923,
        0.78125,
    }

    icons[ICON_PAUSE] = {
        0.5025, 0.0076,
        0.9950, 0.9923,
        0.78125,
    }

    fmt.println(icons)

    atlas_len : u32

    icon_atlas := make([]u8, atlas_len)
    icon_atlas = init_icon_atlas(&atlas_len)
    fmt.println("atlas_len:", atlas_len)

    create_icon_texture(&icon_atlas)
}

init_icon_atlas :: proc (atlas_len: ^u32) -> []u8 {
    atlas_file := #load("../assets/icons.png")
    x, y, channel : i32
    atlas_data := stbi.load_from_memory(raw_data(atlas_file), i32(len(atlas_file)), &x, &y, &channel, 1)
    atlas_len^ = u32(x * y * channel)

    return atlas_data[:atlas_len^]
}

create_icon_texture :: proc (icon_atlas: ^[]u8) {
    gl.GenTextures(1, &icon_texture);
    gl.BindTexture(gl.TEXTURE_2D, icon_texture);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    // gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_BASE_LEVEL, 0);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RED, ICON_ATLAS_WIDTH, ICON_ATLAS_HEIGHT, 0, gl.RED, gl.UNSIGNED_BYTE, &icon_atlas[0]);
    gl.GenerateMipmap(gl.TEXTURE_2D);

    gl.GenVertexArrays(1, &icon_vao)
    gl.BindVertexArray(icon_vao)

    gl.GenBuffers(1, &icon_vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, icon_vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(f32) * ICON_BUFFER_INITIAL_SIZE, nil, gl.DYNAMIC_DRAW)

    gl.VertexAttribPointer(0, 4, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
}

append_icon_buffer :: proc (x, y, width: f32, icon_index: u32) {
    icon := icons[icon_index]
    height := width / icon.aspect_ratio

    right := x + width
    top := y + height

    append(&icon_buffer,
        x,      top,    icon.x0, icon.y0,
        x,      y,      icon.x0, icon.y1,
        right,  top,    icon.x1, icon.y0,
        right,  top,    icon.x1, icon.y0,
        right,  y,      icon.x1, icon.y1,
        x,      y,      icon.x0, icon.y1,
    )

    icon_vertices += 6
}

render_icon :: proc () {
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindVertexArray(icon_vao)
    gl.BindTexture(gl.TEXTURE_2D, icon_texture);
    gl.UseProgram(shaders.text)
    gl.Uniform2f(i32(shaders.u_text_resolution), f32(globals.width), f32(globals.height))
    gl.Uniform4f(i32(shaders.u_text_color), 1, 1, 1, 1)
    gl.DrawArrays(gl.TRIANGLES, 0, i32(icon_vertices))
}

reset_icon :: proc () {
    slice.fill(icon_buffer[:], 0)
    icon_vertices = 0
    clear(&icon_buffer)
}

update_icon_buffer :: proc () {
    gl.BindVertexArray(icon_vao)
    gl.BindBuffer(gl.ARRAY_BUFFER, icon_vbo)

    if u32(len(icon_buffer)) > icon_buffer_size {
        icon_buffer_size *= 2
        gl.BufferData(gl.ARRAY_BUFFER, int(icon_buffer_size) * size_of(f32), &icon_buffer[0], gl.DYNAMIC_DRAW)
    } else {
        gl.BufferSubData(gl.ARRAY_BUFFER, 0, int(icon_buffer_size), &icon_buffer[0])
    }
}

