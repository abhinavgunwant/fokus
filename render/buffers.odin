package render

import gl "vendor:OpenGL"

init_buffers :: proc () {
    vertices : [6]f32 = {
        0, 0.5,
        0.5, -0.5,
        -0.5, -0.5,
    }

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices[0], gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.TRUE, 2 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
}

