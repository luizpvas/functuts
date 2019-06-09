# Rendering markdown in Elixir

This one is short: use [Earmark](https://github.com/pragdave/earmark) by [Dave Thomas](https://twitter.com/pragdave).

The Readme has instructions for installing and examples to help us get started. 

## Considerations and tips 

1. If you're using [prism](https://prismjs.com/) for syntax highlighting, you can pass a second argument with the class prefix for code blocks:

```elixir
Earmark.as_html!(markdown, %Earmark.Options{code_class_prefix: "language-"})
```

2. If you're storing markdown files in disk instead of a database, storing in the `priv` directory is a good idea because it gets copied in deployment releases.

```elixir
# You can get the current's app priv dir with this function
:code.priv_dir(:my_otp_app)
```

3. [Hexdocs](https://hexdocs.pm/), the default tool used to generate elixir documentation, uses Earmark.