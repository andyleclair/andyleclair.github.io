%{
  title: "GLtest",
  author: "Andy LeClair",
  tags: ~w(elixir opengl wxwidgets graphics),
  description: "First steps with OpenGL in Elixir",
  related_listening: "https://www.youtube.com/watch?v=7ny2t1I6aTo"
}
---

Inspired by [this thread on Elixir Forum](https://elixirforum.com/t/opengl-rendered-breakout-clone-in-elixir/65250/15) I wanted to mess around with graphics programming in Elixir. I haven't really touched graphics
programming since I was in college (go huskies!) but I remember it being a lot of fun. Elixir is 
pretty fast and I know a few performance tricks I've learned on the job, so let's see how we can do.

[Other](https://wtfleming.github.io/blog/getting-started-opengl-elixir/) [people](https://hidnasio.github.io/elixir/wxerlang/2022/06/29/advance-wx-erlang-hello-world.html) have mentioned methods to get at some of the OpenGL macros that are in Erlang, so we can start with that. We'll need those to interact with OpenGL and wxWidgets.

```fish
mix new --sup gltest && cd gltest
mkdir src/
```

These files are lifted directly from [here](https://github.com/harrisi/elixir_breakout/tree/main/src)
```erlang
%% src/gl_const.erl
-module(gl_const).
-compile(nowarn_export_all).
-compile(export_all).

-include_lib("wx/include/gl.hrl").

gl_depth_test() -> ?GL_DEPTH_TEST.

gl_lequal() -> ?GL_LEQUAL.
gl_color_buffer_bit() -> ?GL_COLOR_BUFFER_BIT.

gl_depth_buffer_bit() -> ?GL_DEPTH_BUFFER_BIT.

gl_triangles() -> ?GL_TRIANGLES.
gl_array_buffer() -> ?GL_ARRAY_BUFFER.
gl_element_array_buffer() -> ?GL_ELEMENT_ARRAY_BUFFER.
gl_static_draw() -> ?GL_STATIC_DRAW.

gl_vertex_shader() -> ?GL_VERTEX_SHADER.
gl_fragment_shader() -> ?GL_FRAGMENT_SHADER.

gl_compile_status() -> ?GL_COMPILE_STATUS.
gl_link_status() -> ?GL_LINK_STATUS.

gl_float() -> ?GL_FLOAT.
gl_false() -> ?GL_FALSE.
gl_true() -> ?GL_TRUE.
gl_unsigned_int() -> ?GL_UNSIGNED_INT.
gl_unsigned_byte() -> ?GL_UNSIGNED_BYTE.

gl_front_and_back() -> ?GL_FRONT_AND_BACK.
gl_line() -> ?GL_LINE.
gl_fill() -> ?GL_FILL.
gl_debug_output() -> ?GL_DEBUG_OUTPUT.
gl_texture_2d() -> ?GL_TEXTURE_2D.
gl_texture_wrap_s() -> ?GL_TEXTURE_WRAP_S.
gl_texture_wrap_t() -> ?GL_TEXTURE_WRAP_T.
gl_texture_min_filter() -> ?GL_TEXTURE_MIN_FILTER.
gl_texture_mag_filter() -> ?GL_TEXTURE_MAG_FILTER.
gl_rgb() -> ?GL_RGB.
gl_rgba() -> ?GL_RGBA.
gl_multisample() -> ?GL_MULTISAMPLE.
gl_luminance() -> ?GL_LUMINANCE.

gl_texture0() -> ?GL_TEXTURE0.

gl_cull_face() -> ?GL_CULL_FACE.
gl_back() -> ?GL_BACK.
gl_front() -> ?GL_FRONT.
gl_ccw() -> ?GL_CCW.
gl_cw() -> ?GL_CW.

gl_info_log_length() -> ?GL_INFO_LOG_LENGTH.

gl_blend() -> ?GL_BLEND.
gl_src_alpha() -> ?GL_SRC_ALPHA.
gl_one() -> ?GL_ONE.
gl_one_minus_src_alpha() -> ?GL_ONE_MINUS_SRC_ALPHA.

gl_repeat() -> ?GL_REPEAT.
gl_linear() -> ?GL_LINEAR.
gl_nearest() -> ?GL_NEAREST.

gl_framebuffer() -> ?GL_FRAMEBUFFER.
gl_renderbuffer() -> ?GL_RENDERBUFFER.
gl_color_attachment0() -> ?GL_COLOR_ATTACHMENT0.
gl_framebuffer_complete() -> ?GL_FRAMEBUFFER_COMPLETE.
gl_read_framebuffer() -> ?GL_READ_FRAMEBUFFER.
gl_draw_framebuffer() -> ?GL_DRAW_FRAMEBUFFER.

gl_texture_env() -> ?GL_TEXTURE_ENV.
gl_texture_env_mode() -> ?GL_TEXTURE_ENV_MODE.
gl_replace() -> ?GL_REPLACE.
```

```erlang

%% src/wx_const.erl
-module(wx_const).
-compile(nowarn_export_all).
-compile(export_all).

-include_lib("wx/include/wx.hrl").

wx_id_any() -> ?wxID_ANY.
wx_gl_rgba() -> ?WX_GL_RGBA.

wx_gl_doublebuffer() -> ?WX_GL_DOUBLEBUFFER.
wx_gl_depth_size() -> ?WX_GL_DEPTH_SIZE.
wx_gl_forward_compat() -> ?WX_GL_FORWARD_COMPAT.

wxk_left() -> ?WXK_LEFT.
wxk_right() -> ?WXK_RIGHT.
wxk_up() -> ?WXK_UP.
wxk_down() -> ?WXK_DOWN.
wxk_space() -> ?WXK_SPACE.
wxk_raw_control() -> ?WXK_RAW_CONTROL.

wx_gl_major_version() -> ?WX_GL_MAJOR_VERSION.

wx_gl_minor_version() -> ?WX_GL_MINOR_VERSION.

wx_gl_core_profile() -> ?WX_GL_CORE_PROFILE.
wx_gl_sample_buffers() -> ?WX_GL_SAMPLE_BUFFERS.

wx_gl_samples() -> ?WX_GL_SAMPLES.

wx_null_cursor() -> ?wxNullCursor.
wx_cursor_blank() -> ?wxCURSOR_BLANK.
wx_cursor_cross() -> ?wxCURSOR_CROSS.

wx_fontfamily_default() -> ?wxFONTFAMILY_DEFAULT.
wx_fontfamily_teletype() -> ?wxFONTFAMILY_TELETYPE.
wx_normal() -> ?wxNORMAL.
wx_fontstyle_normal() -> ?wxFONTSTYLE_NORMAL.
wx_fontweight_bold() -> ?wxFONTWEIGHT_BOLD.
wx_fontweight_normal() -> ?wxFONTWEIGHT_NORMAL.
```

Also add wx to `extra_applications` in `mix.exs`:
```elixir
  def application do
    [
      extra_applications: [:logger, :wx]
    ]
  end
```

For reference, this is the link to the Erlang WX documentation: [https://www.erlang.org/doc/apps/wx/chapter.html](https://www.erlang.org/doc/apps/wx/chapter.html)

Following along here with [Ian's Triangle post](https://ianhedoesit.com/blog/triangle.html), we will also add the records from wx.hrl to our project:
```elixir
defmodule WxRecords do
  require Record

  for {type, record} <- Record.extract_all(from_lib: "wx/include/wx.hrl") do
    Record.defrecord(type, record)
  end
end
```

Finally, we can add a module to render our window!

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

    send(self(), :update)

    {frame,
     %{
       frame: frame,
       canvas: canvas
     }}
  end

  @impl :wx_object
  def handle_event(wx(event: wxClose()), state) do
    {:stop, :normal, state}
  end

  @impl :wx_object
  def handle_info(:stop, %{canvas: canvas} = state) do
    :wxGLCanvas.destroy(canvas)

    {:stop, :normal, state}
  end

  @impl :wx_object
  def handle_info(:update, state) do
    render(state)

    {:noreply, state}
  end

  defp render(%{canvas: canvas} = state) do
    draw(state)
    :wxGLCanvas.swapBuffers(canvas)
    send(self(), :update)

    :ok
  end

  defp draw(%{canvas: _canvas} = _state) do
    :gl.clearColor(0.2, 0.1, 0.3, 1.0)
    :gl.clear(:gl_const.gl_color_buffer_bit())

    :ok
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

And then we can add it to our `application.ex` and fire up `iex -S mix`:
```elixir
defmodule Gltest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GlTest.Window
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gltest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```
It's important to note that we're returning `{:ok, self()}` from `start_link/1`, because if 
you just return the value of `:wx_object.start_link/3` the process will crash, because what that 
returns does _not_ match what `Supervisor.start_link/2` expects. That said, this _should_ get 
a nice, Elixir-y purple window to appear on your screen. I'm running this code under WSL 2,
but it should work on any platform that supports Erlang and WX, which should be most of them. I know
that [Scenic](https://github.com/ScenicFramework/scenic) has a specific driver for Nerves devices, so I wouldn't expect that would work
out of the box, but I'd guess it works on MacOS.

![A working purple window](/assets/images/09-10-2024-screenshot.png)
