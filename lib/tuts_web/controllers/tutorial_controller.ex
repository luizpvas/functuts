defmodule TutsWeb.TutorialController do
  use TutsWeb, :controller
  action_fallback TutsWeb.FallbackController

  @doc """
  GET /tutorials

  Renders the available tutorials with an introduction page.
  """
  def index(conn, _params) do
    tutorials = Tuts.Tutorial.list_tutorials()
    render(conn, "index.html", tutorials: tutorials)
  end

  @doc """
  GET /tutorials/:slug

  Renders the tutorial page for the given slug.
  """
  def show(conn, params) do
    %{"slug" => slug} = params

    with {:ok, html}  <- Tuts.Tutorial.render_tutorial_as_html(slug) do
      tutorials = Tuts.Tutorial.list_tutorials()
      render(conn, "show.html", tutorial_html: html, tutorials: tutorials)
    end
  end
end