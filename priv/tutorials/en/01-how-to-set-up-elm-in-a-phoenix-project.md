How to set up Elm in a Phoenix project
In this guide we're gonna configure webpack to compile Elm and TailwindCSS in a brand-new Phoenix project. Phoenix switched to Webpack in version 1.4 making this task much easier.

# How to set up Elm in a Phoenix project

In this guide we're gonna configure webpack to compile Elm and TailwindCSS in a brand-new Phoenix project. Phoenix switched to Webpack in version 1.4 making this task much easier.

Let's create an empty project:

```bash
mix phx.new example
cd example
```

The only dependency we need to compile Elm is `elm-webpack-loader`. It'll pull all other necessary dependencies.

```bash
cd assets && npm install --save-dev elm-webpack-loader
```

We need to teach webpack how to handle `.elm` files by adding a new rule to the modules
object in `webpack.config.js`. Paste the code below in the `rules` array — it should have two elements by default: one
for Javascript files and one for CSS files. We're adding the third one for Elm.

```javascript
{
    test: /\.elm$/,
    exclude: [/elm-stuff/, /node_modules/],
    use: {
        loader: "elm-webpack-loader"
    }
}
```

Initialize the Elm compiler by running the command below. _Note_: It asks for confirmation.

```bash
./node_modules/.bin/elm init

...
Knowing all that, would you like me to create an elm.json file now? [Y/n]: Y
...
Okay, I created it. Now read that link!
```

We should now see `elm.json` in the assets directory. Let's edit the source directory in this file, so we can have a top-level "elm" directory with our Elm code.

```json
// Replace the following line in elm.json...
"source-directories": ["src"],

// ...with this line
"source-directories": ["elm"],
```

That's it! We **should** have everything working now. In order to test our setup, let's compile an example program by pasting the following code in `elm/Counter.elm`. I copied the code from [this gist](https://gist.github.com/CliffordAnderson/972907dc8c98b954290723bc68de5fd6) and adjusted it slightly to work with Elm 0.19. What the program does is not important, we just want to make sure the compilation is working.

```elm
module Counter exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)


main =
    Browser.sandbox { init = init, view = view, update = update }


type Msg
    = Increment
    | Decrement


init : Int
init =
    0


view : Int -> Html.Html Msg
view model =
    div []
        [ button [ onClick Increment ] [ text "+" ]
        , text (String.fromInt model)
        , button [ onClick Decrement ] [ text "-" ]
        ]


update : Msg -> Int -> Int
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1
```

We need to import this file from `js/app.js`, which is the entry point for webpack. The code below embeds the Elm application in an element with an id of "counter" — but the important bit is the `import` itself. If it works it means we're able to compile Elm code.

```js
import "phoenix_html";
import css from "../css/app.css";

// Import our Elm application.
import { Elm } from "../elm/Counter.elm";

// Embed it in a div with an id of counter if it exists on the page.
window.addEventListener("load", ev => {
    let counter = document.querySelector("#counter");
    if (counter) {
        Elm.Counter.init({
            node: counter
        });
    }
});
```

Now run `npm run deploy` from the assets directory . If we've done everything right,
our compilation should be working just fine!

![Example output from our Elm compilation](/images/examples/elm-first-compilation.png)

## Bonus: Adding Tailwind to the build

Writing CSS with utility classes has been a productivity boost for me. If you're
not sure what that is, [here's a great article](https://tailwindcss.com/docs/utility-first)
about why utility-first approach is a good idea.

We need a few extra dependencies to get Tailwind working. Let's install them.

```bash
npm install --save-dev postcss-loader postcss-import tailwindcss
```

After installing, change the CSS rule in `webpack.config.js` to use PostCSS.

```js
// Replace the following rule block...
{
    test: /\.css$/,
    use: [MiniCssExtractPlugin.loader, "css-loader"]
}

// ...with this rule that loads PostCSS
{
    test: /\.css$/,
    use: [
        MiniCssExtractPlugin.loader,
        { loader: 'css-loader', options: { importLoaders: 1 } },
        'postcss-loader'
    ]
}
```

Next we need to create `postcss.config.js` in the assets directory, and paste the following code to register `tailwindcss` and `postcss-import` as a plugins.

```js
module.exports = {
    plugins: [require("postcss-import"), require("tailwindcss")]
};
```

Replace the contents of `css/app.css` with the
Tailwind's base file, as indicated in [the docs](https://tailwindcss.com/docs/installation#2-add-tailwind-to-your-css).

```css
@import "tailwindcss/base";

@import "tailwindcss/components";

@import "tailwindcss/utilities";
```

Now run `npm run deploy` from the assets directory, and if we've done everything correctly we should
see a successful build.

![](/images/examples/tailwind-first-build.png)
