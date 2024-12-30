defmodule Mix.Tasks.CopyStatic do
  use Mix.Task
  @font_dir "./assets/fonts"
  @image_dir "./assets/images"
  @output_dir "./output"

  def run(_args) do
    Mix.shell().info([:green, "Copying static files"])

    File.cp_r!(@font_dir, Path.join([@output_dir, "assets", "fonts"]))
    File.cp_r!(@image_dir, Path.join([@output_dir, "assets", "images"]))
  end
end
