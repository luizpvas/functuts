defmodule TutsWeb.Router do
  use TutsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TutsWeb do
    pipe_through :browser

    get "/sitemap", SitemapController, :index

    get "/",                TutorialController, :index
    get "/tutorials",       TutorialController, :index
    get "/tutorials/:slug", TutorialController, :show
  end
end
