defmodule TutsWeb.SitemapControllerTest do
  use TutsWeb.ConnCase

  describe "GET /sitemap" do
    test "includes the root url", %{conn: conn} do
      conn = get(conn, Routes.sitemap_path(conn, :index))
      assert response(conn, 200) =~ Routes.tutorial_path(conn, :index)
    end

    test "includes tutorials urls", %{conn: conn} do
      conn = get(conn, Routes.sitemap_path(conn, :index))
      assert response(conn, 200) =~ Routes.tutorial_path(conn, :show, "caching-in-elixir-without-redis")
    end
  end
end