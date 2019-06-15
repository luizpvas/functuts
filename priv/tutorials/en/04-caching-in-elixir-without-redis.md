Caching in Elixir without Redis
In this tutorial we're gonna implement a simple caching layer in our Phoenix app with the con_cache library and no external dependencies.

# Caching in Elixir without Redis

In this tutorial, we're gonna cache some stuff using the awesome library [con_cache](https://github.com/sasa1977/con_cache) by [Saša Jurić](https://twitter.com/sasajuric).

## The use case

Caching is an optimization, so we **need** a before-and-after picture to make sure we're actually improving things. I'm gonna use this website as the subject of this experiment. Currently, every time someone visits a tutorial, the server performs two slow operations:

- Read the list of tutorials from disk to grab the titles to display in the menu.
- Read the current tutorial based on the URL's path from disk and compile Markdown to HTML.

![Which parts of the website is loaded from disk](/images/examples/caching-overview.png)

Our goal is to cache the result of those slow disk operations.

## Getting the before picture

This website is not yet live as I'm writing this &mdash; I just registered functuts.com by the way &mdash; so all our tests are gonna run locally. That's fine because, in this case, improving the best case scenario also improves the overall performance of the server.

I'm gonna use [wrk](https://github.com/wg/wrk) to send a bunch of HTTP requests and get the average req/sec our server can handle.

```bash
Running 15s test @ http://localhost:4000/tutorials/04-caching-in-elixir-without-redis.md
  4 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   157.28ms   39.21ms 401.15ms   85.42%
    Req/Sec    78.62     32.70   141.00     61.78%
  4566 requests in 15.01s, 41.85MB read
Requests/sec:    304.14
Transfer/sec:    2.79MB
```

It looks like we're about 304 req/sec.

## Thinking about how to cache

Caching is knowingly hard, so we should do our best to limit how things can go wrong, and one of the best ways to do this is ensuring a short life span for the cache. If things go wrong we're gonna be out of sync for at most, let's say, 5 minutes.

In some cases we can completely ignore manual expiration and let it be out of sync for 5 minutes. It's not the end of the world if I publish a new tutorial and it takes 5 minutes to appear on the menu. For this strategy to work, we're gonna need auto-expiration, and luckily for us, `con_cache` already implements it with a feature called TTL (time to live). Let's look at some code.

```elixir
ConCache.get_or_store(:my_cache, "my-key", fn ->
  result = slow_function()
  %ConCache.Item{value: result, ttl: :timer.minutes(5)}}
end)
```

As the name suggests, `get_or_store` returns the existing value in the cache, and if it doesn't exist it executes our callback and caches the result. With only this function we can wrap our slow implementations and get a cached result with very little effort.

## Implementing the cache

Add a new dependency to `mix.exs`

```elixir
{:con_cache, "~> 0.13.1"}
```

and run `mix deps.get` to download the package. Now register `ConCache` in the app supervision tree, it's usually in `application.ex` for Phoenix projects (btw, I'm just following [con_cache's readme](https://github.com/sasa1977/con_cache) during this installation phase).

```elixir
# Add this in the `children` array inside the `start` function.
{ConCache, [
  name: :cache,
  ttl_check_interval: :timer.seconds(10),
  global_ttl: :timer.minutes(5)
]}
```

To recap, we need to cache the result of the functions `list_tutorials` and `render_tutorial_as_html`. They both read from disk, and `render_tutorial_as_html` compiles Markdown to HTML.

Let's wrap `list_tutorials` to cache the result using `ConCache`.

```elixir
# Cached function
def list_tutorials do
  ConCache.get_or_store(:cache, "tutorials-list", fn ->
    list_tutorials_from_disk()
  end)
end

# Actual implementation
defp list_tutorials_from_disk do
  with {:ok, files} <- File.ls(root_dir()) do
    files
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.map(fn {file, index} ->
      %{slug: file, title: "#{index + 1}. #{tutorial_title(file)}"}
    end)
  end
end
```

> I'm not returning `%ConCache.Item{...}` from `get_or_store` because the global TTL is already set to 5 minutes in the supervisor. In this case, we can return the value we want to cache directly.

Now let's wrap the rendering function with `ConCache`:

```elixir
# Cached function.
# Slug is the parameter as it appears in the URL path.
def render_tutorial_as_html(slug) do
  ConCache.get_or_store(:cache, "tutorial-#{slug}", fn ->
    render_tutorial_as_html_from_disk(slug)
  end)
end

# Actual implementation.
def render_tutorial_as_html_from_disk(slug) do
  case File.read(root_dir() <> "/" <> slug) do
    {:ok, markdown} ->
      {:ok, Earmark.as_html!(markdown, %Earmark.Options{code_class_prefix: "language-"})}

    {:error, _} ->
      {:error, :not_found}
  end
end
```

## Fixing our development experience

Our cache is working!... but sadly it messes up the development experience. Right now the cache is applied to all environments, including dev. We don't want this, otherwise, we'll lose the ability to make a change to the markdown file and see the result instantly when reloading the browser.

Let's wrap `ConCache` in a custom `Cache` module, so we can control when caching is on/off based on the environment.

```elixir
defmodule Tuts.Cache do
  @moduledoc """
  Wrapper around `ConCache` that only enables caching in the `prod` environment.
  """

  def get_or_store(key, callback) do
    get_or_store_by_env(Mix.env, key, callbacj)
  end

  defp get_or_store_by_env(:dev, key, callback) do
    callback.()
  end

  defp get_or_store_by_env(:test, key, callback) do
    callback.()
  end

  defp get_or_store_by_env(:prod, key, callback) do
    ConCache.get_or_store(:cache, key, fn ->
      callback.()
    end)
  end
end
```

Now let's use this module instead of `ConCache` in our functions.

```elixir
# Replaced `ConCache.get_or_store` with our custom `Tuts.Cache.get_or_store` implementation
def list_tutorials do
  Tuts.Cache.get_or_store("tutorials-list", fn ->
    list_tutorials_from_disk()
  end)
end

# Replaced `ConCache.get_or_store` with our custom `Tuts.Cache.get_or_store` implementation
def render_tutorial_as_html(slug) do
  Tuts.Cache.get_or_store("tutorial-#{slug}", fn ->
    render_tutorial_as_html_from_disk(slug)
  end)
end
```

## Taking the after picture

We now have caching enabled only in production, so it's only fair we re-run our previous benchmark with no caching in production mode &mdash; this is because Phoenix already performs some optimizations.

```bash
Running 15s test @ http://localhost:4000/tutorials/04-caching-in-elixir-without-redis.md
  4 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   141.86ms   25.20ms 235.21ms   72.87%
    Req/Sec    84.56     22.61   140.00     59.73%
  5050 requests in 15.02s, 46.50MB read
Requests/sec:    336.29
Transfer/sec:    3.10MB
```

It looks like about 500 more requests than before, in `dev` mode. Now let's run the benchmark with caching enabled.

```bash
Running 15s test @ http://localhost:4000/tutorials/04-caching-in-elixir-without-redis.md
  4 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.28ms   14.72ms 229.05ms   98.48%
    Req/Sec     3.45k   460.84     5.67k    81.08%
  204115 requests in 15.03s, 1.92GB read
Requests/sec:  13576.38
Transfer/sec:  130.98MB
```

That's a **huge** difference. The average response time went from 140ms to 5.2ms, and we were able to respond to 204k total requests instead of 5k, which is about 13k req/sec.

This caching strategy brings a performance boost with very little drawback. `ConCache` uses `ETS` internally, and `ETS` stores data in memory. Memory consumption is not an issue for me here because the amount of cached things is not gonna grow &mdash; it's at most one entry per tutorial and one entry for the list of tutorials.
