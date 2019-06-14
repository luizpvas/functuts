Improving SEO for a brand new website
My personal journey to learn about SEO and attempt to improve this website's ranking on Google. Come along for the ride. 

# Improving SEO for a brand new website

I released this website three days ago, and as I'm writing this sentence Google is not aware of FuncTuts yet.

![Functuts.com doest not appear on google](/images/examples/seo-not-on-google.png)

I know **nothing** about SEO, so this is gonna be interesting. My goals here are:

* Make this website appear as the first result when people search for "functuts"
* Make one tutorial appear on the first page when people search for the exact title.

I have no idea if this is too little or too much to get done. **Let's get started**.

## Better URLs

Slugs currently start with a number and end with `.md` (for Markdown).

![Not so friendly URL example](/images/examples/seo-not-so-friendly-url.png)

I'm not sure if this hurts SE ranking somehow, but why not remove them since we're here. This is what it looks like now (ignore `localhost`):

![Friendly URL example](/images/examples/seo-friendly-url.png)


## Better `<title>` tags

There is only one `<title>` tag for the whole website, and it reads **FuncTuts.com**. It seems it's better to add a sentence, something like **FuncTuts - Tutorials about Elixir and Elm**.

I also changed the `<title>` for the tutorials so it has the same value as the tutorial's title.

## Creating an account on Google Search Console

I had no idea this tool existed. I created an account [here](https://search.google.com/search-console/about) and validated the domain using a TXT record in the DNS.

In the Search Console menu, I saw **Sitemaps**, which is the next thing I did.

> Right now, Search Console seems to be aware of the root domain only (no tutorials are indexed yet), and the "Coverage" page is telling me to check again in a few days. 

## Generating a sitemap

It seems a sitemap is the best way to tell Google about the pages I want to be indexed. I found a couple of tools online to generate one, but I would have to update it every time I published a new tutorial &mdash; so I built a [one](https://functuts.com/sitemap). It reads the current list of tutorials dynamically so it is always up to date.

The [Sitemap's XML body](https://github.com/luizpvas/functuts/blob/master/lib/tuts_web/templates/sitemap/index.xml.eex) looks something like this:

```html
<url>
  <loc>https://functuts.com</loc>
  <lastmod>2019-06-13</lastmod>
</url>
<%= for tutorial <- @tutorials do %>
<url>
  <loc><%= "https://functuts.com" <> Routes.tutorial_path(@conn, :show, tutorial[:slug]) %></loc>
  <lastmod><%= tutorial[:last_modified] %></lastmod>
</url>
<% end %>
```

## Next steps

This is a _work-in-progress_ article. I'll keep updating it with more stuff as I attempt to improve Google ranking.