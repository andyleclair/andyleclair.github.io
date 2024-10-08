%{
  title: "OpenGL Part 3",
  description: "Layering shapes, displaying FPS",
  author: "Andy LeClair",
  tags: ["elixir", "opengl", "wxwidgets", "graphics"],
  related_listening: "https://www.youtube.com/watch?v=bwsjQbf0czc",
}
---

Continuing on, I wanted to try the exercises at the bottom of [this chapter](https://learnopengl.com/Getting-started/Hello-Triangle), and this is what I came up with.

```elixir
defmodule GlTest.Window do
  import WxRecords

  @behaviour :wx_object

  def start_link(_) do
    :wx_object.start_link(__MODULE__, [], [])
    {:ok, self()}
  end

  @impl :wx_object
  def init(_) do
    opts = [size: {800, 600}]
    wx = :wx.new()
    frame = :wxFrame.new(wx, :wx_const.wx_id_any(), ~c"Hello", opts)

    :wxWindow.connect(frame, :close_window)
    :wxFrame.show(frame)

    gl_attrib = [
      attribList: [
        :wx_const.wx_gl_core_profile(),
        :wx_const.wx_gl_major_version(),
        3,
        :wx_const.wx_gl_minor_version(),
        3,
        :wx_const.wx_gl_doublebuffer(),
        0
      ]
    ]

    canvas = :wxGLCanvas.new(frame, opts ++ gl_attrib)
    ctx = :wxGLContext.new(canvas)
    :wxGLCanvas.setCurrent(canvas, ctx)

    {shader_program, vao1, vao2, rect_vao} = init_opengl()
    frame_counter = :counters.new(1, [:atomics])

    send(self(), :update)
    now = System.monotonic_time(:millisecond)

    {frame,
     %{
       last_time: now,
       frame: frame,
       frame_counter: frame_counter,
       canvas: canvas,
       shader_program: shader_program,
       fps: 0,
       vao1: vao1,
       vao2: vao2,
       rect_vao: rect_vao
     }}
  end

  @vertex_source """
                 #version 330 core
                 layout (location = 0) in vec3 aPos;
                 void main() {
                 gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
                 }\0
                 """
                 |> String.to_charlist()

  @fragment_source """
                   #version 330 core
                   out vec4 FragColor;
                   void main() {
                   FragColor = vec4(0.44f, 0.35f, 0.5f, 1.0f);
                   }\0
                   """
                   |> String.to_charlist()

  def init_opengl() do
    vertex_shader = :gl.createShader(:gl_const.gl_vertex_shader())
    :gl.shaderSource(vertex_shader, [@vertex_source])
    :gl.compileShader(vertex_shader)

    fragment_shader = :gl.createShader(:gl_const.gl_fragment_shader())
    :gl.shaderSource(fragment_shader, [@fragment_source])
    :gl.compileShader(fragment_shader)

    shader_program = :gl.createProgram()
    :gl.attachShader(shader_program, vertex_shader)
    :gl.attachShader(shader_program, fragment_shader)
    :gl.linkProgram(shader_program)

    :gl.deleteShader(vertex_shader)
    :gl.deleteShader(fragment_shader)

    vertices = triangle_vertices()
    vertices_2 = triangle_vertices_2()

    [vao1, vao2, rect_vao] = :gl.genVertexArrays(3)
    [vbo1, vbo2, rect_vbo, ebo] = :gl.genBuffers(4)

    for {vertex_array, vertex_buffer, vertices} <- [
          {vao1, vbo1, vertices},
          {vao2, vbo2, vertices_2}
        ] do
      :gl.bindVertexArray(vertex_array)

      :gl.bindBuffer(:gl_const.gl_array_buffer(), vertex_buffer)

      :gl.bufferData(
        :gl_const.gl_array_buffer(),
        byte_size(vertices),
        vertices,
        :gl_const.gl_static_draw()
      )

      :gl.vertexAttribPointer(
        0,
        3,
        :gl_const.gl_float(),
        :gl_const.gl_false(),
        3 * byte_size(<<0.0::float-size(32)>>),
        0
      )

      :gl.enableVertexAttribArray(0)

      :gl.bindBuffer(:gl_const.gl_array_buffer(), 0)

      :gl.bindVertexArray(0)
    end

    rect_vertices = rectangle_vertices()
    rect_indices = rectangle_indices()

    :gl.bindVertexArray(rect_vao)
    :gl.bindBuffer(:gl_const.gl_array_buffer(), rect_vbo)

    :gl.bufferData(
      :gl_const.gl_array_buffer(),
      byte_size(rect_vertices),
      rect_vertices,
      :gl_const.gl_static_draw()
    )

    :gl.bindBuffer(:gl_const.gl_element_array_buffer(), ebo)

    :gl.bufferData(
      :gl_const.gl_element_array_buffer(),
      byte_size(rect_indices),
      rect_indices,
      :gl_const.gl_static_draw()
    )

    :gl.vertexAttribPointer(
      0,
      3,
      :gl_const.gl_float(),
      :gl_const.gl_false(),
      3 * byte_size(<<0.0::float-size(32)>>),
      0
    )

    :gl.enableVertexAttribArray(0)
    {shader_program, vao1, vao2, rect_vao}
  end

  @triangle_vertices [
                       [0.0, 1.0, 0.0],
                       [1.0, 0.0, 0.0],
                       [1.0, 1.0, 0.0]
                     ]
                     |> List.flatten()
                     |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::float-native-size(32)>> end)
  def triangle_vertices do
    @triangle_vertices
  end

  @triangle_vertices_2 [
                         [-0.5, -0.5, 0.0],
                         [0.5, -0.5, 0.0],
                         [0.0, 0.5, 0.0]
                       ]
                       |> List.flatten()
                       |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::float-native-size(32)>> end)
  def triangle_vertices_2 do
    @triangle_vertices_2
  end

  @rectangle_vertices [
                        [0.5, 0.5, 0.0],
                        [0.5, -0.5, 0.0],
                        [-0.5, -0.5, 0.0],
                        [-0.5, 0.5, 0.0]
                      ]
                      |> List.flatten()
                      |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::float-native-size(32)>> end)

  def rectangle_vertices do
    @rectangle_vertices
  end

  @rectangle_indices [[0, 1, 3], [1, 2, 3]]
                     |> List.flatten()
                     |> Enum.reduce(<<>>, fn el, acc -> acc <> <<el::native-size(32)>> end)
  def rectangle_indices do
    @rectangle_indices
  end

  @impl :wx_object
  def handle_event(wx(event: wxClose()), state) do
    {:stop, :normal, state}
  end

  @impl :wx_object
  def handle_info(:stop, %{canvas: canvas, fps_counter_label: fps_counter_label} = state) do
    :wxGLCanvas.destroy(canvas)
    :wxStaticText.destroy(fps_counter_label)

    {:stop, :normal, state}
  end

  @impl :wx_object
  def handle_info(:update, state) do
    state = render(state)

    {:noreply, state}
  end

  defp render(%{canvas: canvas} = state) do
    state =
      state
      |> update_frame_counter()
      |> draw()

    :wxGLCanvas.swapBuffers(canvas)
    send(self(), :update)

    state
  end

  defp draw(%{frame: frame} = state) do
    :gl.clearColor(0.2, 0.1, 0.3, 1.0)
    :gl.clear(:gl_const.gl_color_buffer_bit())

    :gl.useProgram(state.shader_program)

    :gl.bindVertexArray(state.vao1)
    :gl.drawArrays(:gl_const.gl_triangles(), 0, 3)

    :gl.bindVertexArray(state.vao2)
    :gl.drawArrays(:gl_const.gl_triangles(), 0, 3)

    :gl.polygonMode(:gl_const.gl_front_and_back(), :gl_const.gl_line())
    :gl.bindVertexArray(state.rect_vao)
    :gl.drawElements(:gl_const.gl_triangles(), 6, :gl_const.gl_unsigned_int(), 0)
    :gl.polygonMode(:gl_const.gl_front_and_back(), :gl_const.gl_fill())

    :wxWindow.setLabel(frame, ~c"FPS: #{state.fps}")

    state
  end

  def update_frame_counter(%{last_time: last_time, frame_counter: frame_counter} = state) do
    now = System.monotonic_time(:millisecond)
    elapsed = now - last_time

    if elapsed > 100 do
      frames = :counters.get(frame_counter, 1)
      fps = (frames / elapsed * 1000) |> round()
      :counters.put(frame_counter, 1, 0)
      Map.merge(state, %{fps: fps, last_time: now})
    else
      :counters.add(frame_counter, 1, 1)
      state
    end
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent
    }
  end
end
```

I was reading some of the related links and I saw this article with a bit about adding a FPS counter, and I thought that would be a fun exercise to try.

I'm using Erlang's `:counters` module to keep track of the number of frames rendered, and then every 100-ish ms I calculate the FPS and update the window title with the FPS.
Then I zero out the frame counter.

I tried to layer a WxWidgets `StaticText` on top of the `GLCanvas` to display the FPS, but I couldn't get it to show up. That took
me to [this](https://forums.wxwidgets.org/viewtopic.php?t=42109) thread, which says that if you're using OpenGL in Wx, it's _special_and that I should just avoid trying to mix the two. 
Eventually I will learn how to do it with OpenGL, which I think involves rendering the text as a bitmap?

[Last post](/2024/09-10-opengl-part-2), I mentioned that I didn't like how the formatter handled the vertexes, and I think I found a better way to do it this time. I'm using a list of lists of floats, flattening it, and then reducing it into a binary. It's a bit more verbose, but I think it's easier to read and understand, and since I've pushed it into a module attribute, it only gets evaluated at compile time.
