defmodule TutsWeb.LayoutView do
  use TutsWeb, :view

  def menu_link(conn, title, url) do
    class =
      if conn.request_path == url do
        "text-base md:text-sm block my-1 mx-2 p-1 bg-teal-100 text-teal-900 rounded"
      else
        "text-base md:text-sm block my-1 mx-2 p-1 text-gray-800"
      end


    raw """
      <a href="#{url}" class="#{class}" data-target="menu-link">
        <div>#{title}</div>
      </a>
    """
  end
end
