defmodule Mix.Tasks.CopyStatic do
  use Mix.Task
  @font_dir "./assets/fonts"
  @image_dir "./assets/images"
  @output_dir "./output"

  def run(_args) do
    Mix.shell().info([:green, "Copying static files"])

    # Ignoring if these exist
    File.mkdir(@output_dir)
    File.mkdir(Path.join([@output_dir, "assets", "fonts"]))
    File.mkdir(Path.join([@output_dir, "assets", "images"]))
    File.mkdir(@image_dir)
    File.mkdir(@font_dir)
    File.cp_r!(@font_dir, Path.join([@output_dir, "assets", "fonts"]))
    File.cp_r!(@image_dir, Path.join([@output_dir, "assets", "images"]))
  end
end
