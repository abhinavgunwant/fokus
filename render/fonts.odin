package render

import "core:fmt"
import "core:os"
import "core:mem"
import "core:slice"
import "core:compress/zlib"
import mv "core:mem/virtual"

import gl "vendor:OpenGL"
import tt "vendor:stb/truetype"
import stbi "vendor:stb/image"

import "../shaders"
import "../globals"

ATLAS_WIDTH :: 1600
ATLAS_HEIGHT :: 1600
DEFAULT_FONT_SIZE :: 256 

TEXT_BUFFER_INITIAL_SIZE :: 2048

font_texture : u32

aligned_quads : [128] tt.aligned_quad
packed_chars: [100] tt.packedchar

text_vao : u32
text_vbo : u32

first_print := true

text_buffer : [dynamic] f32
text_buffer_size : u32 = TEXT_BUFFER_INITIAL_SIZE
text_vertices : u32

init_fonts :: proc () {
    font_atlas := make([]u8, ATLAS_WIDTH * ATLAS_HEIGHT)
    text_buffer = make([dynamic]f32, 0, TEXT_BUFFER_INITIAL_SIZE)

    //// NOTE: Uncomment the line below to write the atlas!
    //// This is required for the first build!
    // write_font_atlas(&font_atlas)

    //// NOTE: Comment the line below to write the atlas!
    //// This is required for the first build!
    font_atlas = init_font_atlas()

    create_font_texture(&font_atlas)

    gl.Enable(gl.BLEND)
    gl.Enable(gl.SAMPLE_SHADING)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
}

init_font_atlas :: proc () -> []u8 {
    atlas_file := #load("../assets/fonts/Inter/Regular-atlas.png")
    x, y, channel : i32
    data := stbi.load_from_memory(raw_data(atlas_file), i32(len(atlas_file)), &x, &y, &channel, 1)
    atlas_len := x * y * channel

    packed_chars_bytes := #load("../assets/fonts/Inter/Regular-packed-chars.dat")
    aligned_quads_bytes := #load("../assets/fonts/Inter/Regular-aligned-quads.dat")

    mem.copy(&packed_chars[0], raw_data(packed_chars_bytes), len(packed_chars_bytes))
    mem.copy(&aligned_quads[0], raw_data(aligned_quads_bytes), len(aligned_quads_bytes))

    return data[:atlas_len]
}

write_font_atlas :: proc (atlas: ^[]u8) {
    data := #load("../assets/fonts/Inter/Regular.ttf")

    tt_ctx: tt.pack_context

    tt.PackBegin(&tt_ctx, &atlas[0], ATLAS_WIDTH, ATLAS_HEIGHT, 0, 1, nil)
    tt.PackFontRange(&tt_ctx, &data[0], 0, DEFAULT_FONT_SIZE, 32, 128, &packed_chars[0])
    tt.PackEnd(&tt_ctx)

    for i : i32 = 0; i < 128; i += 1 {
        _1, _2: f32

        tt.GetPackedQuad(
            &packed_chars[0],
            ATLAS_WIDTH,
            ATLAS_HEIGHT,
            i,
            &_1,
            &_2,
            &aligned_quads[i],
            b32(false)
        )
    }

    packed_error := os.write_entire_file_from_bytes(
        "assets/fonts/Inter/Regular-packed-chars.dat",
        slice.to_bytes(packed_chars[:]),
        {os.Permissions.Write_User}
    )

    if packed_error != os.General_Error.None {
        fmt.eprintln("Error writing the packed chars file.", packed_error)
        os.exit(1)
    }

    aligned_error := os.write_entire_file_from_bytes(
        "assets/fonts/Inter/Regular-aligned-quads.dat",
        slice.to_bytes(aligned_quads[:]),
        {os.Permissions.Write_User}
    )

    if aligned_error != os.General_Error.None {
        fmt.eprintln("Error writing the aligned quads file.", aligned_error)
        os.exit(1)
    }

    stbi.write_png("assets/fonts/Inter/Regular-atlas.png", ATLAS_WIDTH, ATLAS_HEIGHT, 1, &atlas[0], ATLAS_WIDTH)
}

create_font_texture :: proc (font_atlas: ^[]u8) {
    gl.GenTextures(1, &font_texture);
    gl.BindTexture(gl.TEXTURE_2D, font_texture);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_BASE_LEVEL, 0);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RED, ATLAS_WIDTH, ATLAS_HEIGHT, 0, gl.RED, gl.UNSIGNED_BYTE, &font_atlas[0]);
    gl.GenerateMipmap(gl.TEXTURE_2D);

    gl.GenVertexArrays(1, &text_vao)
    gl.BindVertexArray(text_vao)

    gl.GenBuffers(1, &text_vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, text_vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(f32) * TEXT_BUFFER_INITIAL_SIZE, nil, gl.DYNAMIC_DRAW)

    gl.VertexAttribPointer(0, 4, gl.FLOAT, gl.FALSE, 4 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
}

get_text_dimensions :: proc (size: f32, text: string) -> (f32, f32) {
    width, height : f32 = 0, 0

    resize := size / DEFAULT_FONT_SIZE

    for c in text {
        index := u16(c) - 32

        packed_char := packed_chars[index]
        aligned_quad := aligned_quads[index]

        if c == ' ' {
            width += packed_char.xadvance * resize
            continue
        }

        width += packed_char.xadvance * resize

        h := f32(packed_char.y1 - packed_char.y0) * resize

        if h > height {
            height = h
        }
    }

    return width, height
}

append_text_buffer :: proc (x, y, size: f32, text: string) {
    fmt.println("appending buffer", len(text_buffer))
    xpos := x
    resize := size / DEFAULT_FONT_SIZE

    for c in text {
        index := u16(c) - 32

        packed_char := packed_chars[index]
        aligned_quad := aligned_quads[index]

        if c == ' ' {
            xpos += packed_char.xadvance * resize
            continue
        }

        left := xpos + (packed_char.xoff * resize)
        right := left + f32(packed_char.x1 - packed_char.x0) * resize
        bottom := y - (packed_char.yoff + f32(packed_char.y1 - packed_char.y0)) * resize
        top := bottom + (f32(packed_char.y1 - packed_char.y0) * resize)

        append(&text_buffer,
            left,  top,     aligned_quad.s0, aligned_quad.t0,
            left,  bottom,  aligned_quad.s0, aligned_quad.t1,
            right, top,     aligned_quad.s1, aligned_quad.t0,
            right, top,     aligned_quad.s1, aligned_quad.t0,
            right, bottom,  aligned_quad.s1, aligned_quad.t1,
            left,  bottom,  aligned_quad.s0, aligned_quad.t1,
        )

        xpos += packed_char.xadvance * resize
        text_vertices += 6
    }
}

render_text :: proc () {
    gl.ActiveTexture(gl.TEXTURE0);
    gl.BindVertexArray(text_vao)
    gl.UseProgram(shaders.text)
    gl.Uniform2f(i32(shaders.u_text_resolution), f32(globals.width), f32(globals.height))
    gl.Uniform4f(i32(shaders.u_text_color), 1, 1, 1, 1)
    gl.DrawArrays(gl.TRIANGLES, 0, i32(text_vertices))
}

reset_text :: proc () {
    slice.fill(text_buffer[:], 0)
    text_vertices = 0
    clear(&text_buffer)
}

update_text_buffer :: proc () {
    gl.BindVertexArray(text_vao)
    gl.BindBuffer(gl.ARRAY_BUFFER, text_vbo)

    if u32(len(text_buffer)) > text_buffer_size {
        text_buffer_size *= 2
        gl.BufferData(gl.ARRAY_BUFFER, int(text_buffer_size) * size_of(f32), &text_buffer[0], gl.DYNAMIC_DRAW)
    } else {
        gl.BufferSubData(gl.ARRAY_BUFFER, 0, int(text_buffer_size), &text_buffer[0])
    }
}

