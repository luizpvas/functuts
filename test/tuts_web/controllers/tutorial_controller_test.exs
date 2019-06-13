defmodule TutsWeb.TutorialControllerTest do
  use TutsWeb.ConnCase

  describe "GET /tutorials" do
    test "lists available tutorials", %{conn: conn} do
      tutorials = Tuts.Tutorial.list_tutorials()
      conn = get(conn, Routes.tutorial_path(conn, :index))
      for tutorial <- tutorials do
        assert html_response(conn, 200) =~ tutorial[:title]
      end
    end
  end

  describe "GET /tutorials/:slug" do
    test "renders the tutorial", %{conn: conn} do
      slug = "how-to-set-up-elm-in-a-phoenix-project"
      {:ok, tutorial} = Tuts.Tutorial.find_tutorial_by_slug(slug)
      {:ok, html} = Tuts.Tutorial.render_tutorial_as_html(tutorial)
      conn = get(conn, Routes.tutorial_path(conn, :show, slug))
      assert html_response(conn, 200) =~ html
    end

    test "renders 404 if the tutorial doesn't exist", %{conn: conn} do
      slug = "bad-slug"
      conn = get(conn, Routes.tutorial_path(conn, :show, slug))
      assert html_response(conn, 404)
    end
  end
end