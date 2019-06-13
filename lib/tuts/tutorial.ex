defmodule Tuts.Tutorial do
  @doc """
  Lists available tutorials, sorted from latest to oldest.

  ## Examples

      iex> Tuts.Tutorial.list_tutorials()
      [%{...}]

  """
  def list_tutorials do
    Tuts.Cache.get_or_store("tutorials-list", fn ->
      list_tutorials_from_disk()
    end)
  end

  defp list_tutorials_from_disk do
    with {:ok, paths} <- File.ls(root_dir()) do
      paths
      |> Enum.sort()
      |> Enum.reverse()
      |> Enum.map(fn path ->
        %{
          path: path,
          slug: path_to_slug(path),
          title: tutorial_title(path),
          description: tutorial_description(path)
        }
      end)
    end
  end

  @doc """
  Reads the tutorial's markdown source and compiles it to HTML.
  The compiled HTML is returned from this function.

  ## Examples
  
      iex> Tuts.Tutorial.render_tutorial_as_html("slug-1")
      {:ok, "<div>Content here</div>"}

      iex> Tuts.Tutorial.render_tutorial_as_html("bad-slug")
      {:error, :not_found}

  """
  def render_tutorial_as_html(%{slug: slug, path: path}) do
    Tuts.Cache.get_or_store("tutorial-#{path}", fn ->
      render_tutorial_as_html_from_disk(path)
    end)
  end

  def render_tutorial_as_html_from_disk(path) do
    case File.read(root_dir() <> "/" <> path) do
      {:ok, markdown} ->
        markdown = remove_title_and_description_from_markdown(markdown)
        {:ok, Earmark.as_html!(markdown, %Earmark.Options{code_class_prefix: "language-"})}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  def find_tutorial_by_slug(slug) do
    list_tutorials()
    |> Enum.find(fn tutorial -> tutorial[:slug] == slug end)
    |> case do
      nil      -> {:error, :not_found}
      tutorial -> {:ok, tutorial}
    end
  end

  defp remove_title_and_description_from_markdown(markdown) do
    markdown 
    |> String.split("\n")
    |> Enum.drop(2)
    |> Enum.join("\n")
  end

  # Converts a file path to a URL slug by removing the `.md` extension and the index.
  defp path_to_slug(path) do
    path
    |> String.replace(".md", "")
    |> String.split("-")
    |> case do
      [_index | rest] -> Enum.join(rest, "-")
    end
  end

  # Converts a slug to a file path by searching the tutorials array for the given slug.
  defp slug_to_path(slug) do
    case find_tutorial_by_slug(slug) do
      nil -> nil
      tutorial -> tutorial[:path]
    end
  end

  # Reads the file from disk and extracts the content of the first line.
  defp tutorial_title(path) do
    File.read!(root_dir() <> "/" <> path)
    |> String.split("\n")
    |> hd()
    |> String.trim()
  end

  defp tutorial_description(path) do
    File.read!(root_dir() <> "/" <> path)
    |> String.split("\n")
    |> Enum.at(1)
    |> String.trim()
  end

  # Directory with all markdown files.
  defp root_dir do
    List.to_string(:code.priv_dir(:tuts)) <> "/tutorials/en"
  end
end