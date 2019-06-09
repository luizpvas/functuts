defmodule TutsWeb.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    tutorials = Tuts.Tutorial.list_tutorials()

    conn
    |> put_view(TutsWeb.ErrorView)
    |> put_status(:not_found)
    |> render("404.html", tutorials: tutorials)
  end
end