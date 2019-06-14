defmodule TutsWeb.SitemapController do
  use TutsWeb, :controller

  @doc """
  GET /sitemap

  Returns the sitemap in the XML format with links to all posts.
  """
  def index(conn, _params) do
    tutorials = Tuts.Tutorial.list_tutorials()

    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", tutorials: tutorials)
  end
end