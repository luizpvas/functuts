# Tips for rendering markdown in Elixir

tl;dr: just use [Earmark](https://github.com/pragdave/earmark) by [Dave Thomas](https://twitter.com/pragdave).

## Tips

1. If you're using [prism](https://prismjs.com/) for syntax highlighting, you can pass a second argument with the class prefix for code blocks:

```elixir
Earmark.as_html!(markdown, %Earmark.Options{code_class_prefix: "language-"})
```

2. Use the `priv` directory to store your markdown files if you want to store on disk directly instead of a database. It is a good idea because it gets copied in deployment releases.

```elixir
# You can get the current's app priv dir with this function
:code.priv_dir(:my_otp_app)
```

3. Use [`Phoenix.HTML.raw`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.html#raw/1) to render HTML stored in a variable, otherwise, it'll get sanitized.

```html
<div class="content p-4">
  <%= raw @tutorial_html %>
</div>
```

4. [Hexdocs](https://hexdocs.pm/), the default tool used to generate documentation from Elixir code, uses Earmark.
