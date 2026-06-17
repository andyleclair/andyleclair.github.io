defmodule Personal.Opengraph do
  alias Personal.Post

  @post_template File.read!("typst/post.typ")
  @external_resource "typst/post.typ"

  @main_header_template File.read!("typst/main_header.typ")
  @external_resource "typst/main_header.typ"

  def generate_image(%Post{
        title: title,
        description: description,
        html_path: path,
        og_image_path: og_image_path
      }) do
    ascii_big_text = Figlet.string("NEW POST!", font: "figlet.js/ANSI Shadow.flf")
    url = Personal.url(path)

    {:ok, png} =
      Typst.render_to_png(@post_template,
        ascii_big_text: ascii_big_text,
        title: title,
        description: description,
        url: url
      )

    og_image_path |> Path.dirname() |> File.mkdir_p!()

    File.write!(og_image_path, png)
  end

  def generate_main_header do
    ascii_big_text = Figlet.string("andyleclair.dev", font: "figlet.js/ANSI Shadow.flf")
    url = Personal.url()

    {:ok, png} =
      Typst.render_to_png(@main_header_template,
        ascii_big_text: ascii_big_text,
        url: url
      )

    File.write!(Path.join(~w(assets images og main_header)) <> ".png", png)
  end
end
