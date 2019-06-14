defmodule Tuts.TutorialTest do
  use ExUnit.Case, async: true

  test "list_tutorials/0 - doesn't have .md extension in the slug" do
    [tutorial | _] = Tuts.Tutorial.list_tutorials()
    refute tutorial[:slug] =~ ".md"
  end

  test "list_tutorials/0 - removes the tutorial index from the slug" do
    [tutorial | _] = Tuts.Tutorial.list_tutorials() |> Enum.reverse()
    assert tutorial[:slug] == "how-to-set-up-elm-in-a-phoenix-project"
  end

  test "render_tutorial_as_html/1 - renders HTML without .md extension and index number" do
    {:ok, tutorial} = Tuts.Tutorial.find_tutorial_by_slug("improving-seo-for-a-brand-new-website")
    assert {:ok, html} = Tuts.Tutorial.render_tutorial_as_html(tutorial)
  end
end