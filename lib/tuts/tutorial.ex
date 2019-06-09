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
    with {:ok, files} <- File.ls(root_dir()) do
      files
      |> Enum.sort()
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.map(fn {file, index} ->
        %{slug: file, title: "#{index + 1}. #{tutorial_title(file)}"}
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
  def render_tutorial_as_html(slug) do
    Tuts.Cache.get_or_store("tutorial-#{slug}", fn ->
      render_tutorial_as_html_from_disk(slug)
    end)
  end

  def render_tutorial_as_html_from_disk(slug) do
    case File.read(root_dir() <> "/" <> slug) do
      {:ok, markdown} ->
        {:ok, Earmark.as_html!(markdown, %Earmark.Options{code_class_prefix: "language-"})}

      {:error, _} ->
        {:error, :not_found}
    end
  end

  defp tutorial_title(file) do
    File.read!(root_dir() <> "/" <> file)
    |> String.split("\n")
    |> hd()
    |> String.replace("#", "")
    |> String.trim()
  end

  defp root_dir do
    List.to_string(:code.priv_dir(:tuts)) <> "/tutorials/en"
  end
end