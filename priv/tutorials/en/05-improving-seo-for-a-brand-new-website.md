Improving SEO for a brand new website
My personal journey to learn about SEO and attempt to improve this website's ranking on Google. Come along for the ride.

# Improving SEO for a brand new website

I released this website three days ago, and as I'm writing this sentence Google is not aware of FuncTuts yet.

![Functuts.com doest not appear on google](/images/examples/seo-not-on-google.png)

I know **nothing** about SEO, so this is gonna be interesting. My goal here is to describe all changes I make as I learn about SEO, and at the end, hopefully:

- Make this website appear as the first result when people search for "functuts"
- Make one tutorial appear on the first page when people search for the exact title.

I have no idea if this is too little or too much to get done. **Let's get started**.

## Better URLs

Slugs currently start with a number and end with `.md` (for Markdown).

![Not so friendly URL example](/images/examples/seo-not-so-friendly-url.png)

I'm not sure if this hurts SE ranking somehow, but why not remove them since we're here. This is what it looks like now (ignore `localhost`):

![Friendly URL example](/images/examples/seo-friendly-url.png)

## Better `<title>` tags

There is only one `<title>` tag for the whole website, and it reads **FuncTuts.com**. It seems it's better to add a sentence, something like **FuncTuts - Tutorials about Elixir and Elm**.

I also changed the tutorial's page to have the same value as the tutorial's title.

## Creating an account on Google Search Console

I had no idea this tool existed. I created an account [here](https://search.google.com/search-console/about) and validated the domain using a TXT record in the DNS.

In the Search Console menu, I saw **Sitemaps**, which is the next thing I did.

> Right now, Search Console seems to be aware of the root domain only (no tutorials are indexed yet), and the "Coverage" page is telling me to check again in a few days.

## Generating a sitemap

It seems sitemaps are the best way to tell Google about the pages we want to index. I found a couple of tools online to generate one, but I would have to manually update it every time I published a new tutoria. So I built [one](https://functuts.com/sitemap) that reads the current list of tutorials dynamically so it is always up to date.

The [Sitemap's XML body](https://github.com/luizpvas/functuts/blob/master/lib/tuts_web/templates/sitemap/index.xml.eex) looks something like this:

```html
<url>
  <loc>https://functuts.com</loc>
  <lastmod>2019-06-13</lastmod>
</url>
<%= for tutorial <- @tutorials do %>
<url>
  <loc
    ><%= "https://functuts.com" <> Routes.tutorial_path(@conn, :show,
    tutorial[:slug]) %></loc
  >
  <lastmod><%= tutorial[:last_modified] %></lastmod>
</url>
<% end %>
```

## Page speed insights

Another thing Google seems to take into consideration for ranking is speed. Speed is not only about response time from the server, but also first meaningful paint on the screen, javascript loading time, proper caching headers, mobile optimizations, and a bunch of others.

Google offers [PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/) to check your website, with a very detailed explanation about what could be improved. For FuncTuts, I'm more than satisfied 😄.

![98 score on PageSpeed Insights](/images/examples/seo/page-speed-result.png)

## 4 days later

Today is the 4th day since I started writing this article. Google is showing the images from blog posts when searching for "FuncTuts", but the website itself only appears in the 7th position.

![98 score on PageSpeed Insights](/images/examples/seo/4-days-later.png)

Google Search Console is showing that I have 2 clicks from 4 impressions, that is, 4 people saw FuncTuts in their search result and 2 of them clicked. That's nice, I like it.

There is one thing I'm not sure yet. The Coverage report is telling me that I have 2 valid and indexed pages but 4 detected but excluded pages. All excluded pages appear in the sitemap, so maybe this is an issue with robots.txt? [This StackOverflow question](https://stackoverflow.com/questions/4276957/how-to-configure-robots-txt-to-allow-everything) suggests an empty `Disallow` instead of `Allow: /`. I just made this change and pushed to the server. Let's see in a few days if it changes anything.

## 8 days later

Nothing changed. Google still has only indexed the root page and one tutorial, and I'm not sure why.

![](/images/examples/seo/8-days-later.png)

## 17 days later

Finally, Google has indexed all 7 pages (root + 6 tutorials). When searching for "functuts" directly, it shows this website as the second result beneath a Github gist from the second tutorial.

I haven't updated or written new tutorials in the last couple of weeks. Maybe this is a good thing, and Google dislikes when the content changes too often? I'm not sure.


## Next steps

This is a _work-in-progress_ article. I'll keep updating it with more stuff as I attempt to improve Google ranking.
