Building a simple and useful Elm component
In this tutorial we're gonna build a colorpicker component in Elm from scratch. This is a great introduction to the langauge because I share my thoughts behind each decision in the process.

# Building a simple and useful Elm component

I think it's fair to say Elm is difficult to learn, specially compared to most mainstream languages. It took me quite some time to feel in control and be productive with. Some of the things we need to learn are: how to deal with immutable data structures, how to model our app with a strong type system and make our app _do_ things with no side effects.

Instead of trying to explain those things as separate topics, we're gonna jump straight into a project and I'll do my best to explain the thought process behind each step.

## What we're building

Here is the greatest spec for a color picker you'll ever see:

![Color picker spec](/images/examples/colorpicker-spec.png)

Awesome, right?

Jokes aside, this is a form field with a label on top and colors at the bottom.
The selected color should be highlighted somehow. **Let's get started**.

## Starting with data

It's a common practice to start thinking about the shape of the data when facing a new problem in Elm, and the first thing about this component that comes to mind is the selected color &mdash; that's a **piece of data** that can change over time.

But before we go there we must decide _what_ a color is. We could go with three numbers between 0-255 representing RGB (e.g. 143, 50, 21) or a String representing the hexadecimal format (e.g. #8f3215). Let's go with a string for no particular reason and defined our Model with a selected color.

```elm
type alias Model =
    { selectedColor : String
    }
```

> `type alias` is used to define a [record](https://elm-lang.org/docs/records). It groups related data. You can think of it as a class with no behaviour and no private attributes.
>
> `Model` is the name of type. We could have chosen a different name, but it's a convention in the Elm community to use Model.

We should also consider the **nothing is selected** state. Elm doesn't have the concept of `null`, so if we say the selected color is a String, it must **always** be a string even when the component has no selected color. So we have to make a choice:

- Go with a String and represent "nothing is selected" with an empty string.
- Change the type to something that describes the empty state better.

Using an empty string is fine, and it would work just fine without any issues. I mean, this is a
very simple component with a very limited scope &mdash; so let's go with just a String.

> In theory, `Maybe String` is a better type to describe the selected color is optional. It would force us to always handle the missing case and it communicates better our intention &mdash; but let's save it for the future.

## Static data

What about the list of colors the user can choose from? Perhaps it should be in the model as well, something like:

```elm
type alias Model =
    { selectedColor : String
    , colors: List String
    }
```

Well... maybe, but I don't like putting it in the model because it's pretty much a static list, a constant. Here's a rule of thumb for deciding if we should store it in the model:

- Does it change over time? If so, the only way to update data in Elm is if it lives in the model.
- Does the component load with different arguments? An initialization argument must also live in the model.

Another way to think about this is if we were modeling a relational database. Would we create a "colors" table to store the list of possible colors as records? I would rather put it in code, maybe directly in the view code. With this in mind, let's declare a static list of colors outside of our Model.

```elm
colors : List String
colors =
    ["#4286f4", "#41f441", "#dfe212", "#e25712", "#e21212"]

type alias Model =
    { selectedColor : String
    }
```

## Thinking about behaviour

Now that we have an idea about the shape of the data, let's try to come up with a list of things (actions) users can do on the component:

- Select a color
- Clear selection

... is that it? It looks like it is. Only two actions, neat!

> We're still not thinking about UI, just actions. For example, I'm still not sure how "Clear selection" is good look - maybe a button next to the input's label, maybe clicking again on the selected color.

With this in mind, we can enumerate the actions as its own type:

```elm
type Msg
    = ColorSelected String
    | SelectionCleared
```

This is a [Sum Type](https://en.wikipedia.org/wiki/Tagged_union), or [Custom Type](https://guide.elm-lang.org/types/custom_types.html) in Elm's terms. You can think of it as an enum with parameters. If it helps, I read this code out loud as _A Message can be either ColorSelected with a String or SelectionCleared_.

> `Msg` is the name of the type. We could have chosen any name, but it's a convention to use Msg.

## Updating the model

Now we have our data (Model) and an enumeration of _all possible things_ the user can do (Msg). Let's glue them with an `update` function.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ColorSelected hash ->
            ( { model | selectedColor = hash }, Cmd.none )

        SelectionCleared ->
            ( { model | selectedColor = "" }, Cmd.none )
```

Wow, that's a lot to take in. Let's break it apart:

- `update` is a function that takes a `Msg` and a `Model` and it returns a `(Model, Cmd Msg)`
- Things between parenthesis are called a Tuple. (String, String) is a Tuple of two strings.
- `Cmd Msg` is read as "A command that produces a Msg". Commands are used for HTTP requests, delayed tasks (think `setTimeout`) and interop with Javascript.
- We return `Cmd.none` in both branches because we're not doing any HTTP request, delayed task or interop.
- `case _variable_ of` is similar to a switch statement in other languages.
- `{ record | field = newVal }` is the syntax for updating a record.
- The Elm runtime is responsible for calling this function, as you'll see in a minute.

Oh, did I forgot to mention `case _variable_ of` is exhaustive? It means that if we forgot to handle a value for `Msg` or if we typed a wrong value, the compiler would complain:

![Example an error message for a missing](/images/examples/elm-forgot-branch-error-msg.png)

## Writing the main function

It's almost time to build the UI &mdash; but before that, let's take a looooong jump and define our main program with the code below. It may be a lot to take in, so take a deep breath. The reason we need all this code is that even the smallest Elm program, defined with `Browser.element`, needs the following functions:

- `init` - Receives arguments from our Javascript and builds the initial Model
- `subscriptions` - Used to listen for external events, such as websockets and mouse drag events. We won't use them in this tutorial.
- `update` - Updates the model based on the produced Msg (that we defined as a list of actions).
- `view` - Renders the component.

```elm
module Colorpicker exposing (main)

-- The Browser module has the definition to run an Elm application.
-- Html exposes functions to help us build DOM nodes such as `div`, `span`, `button`, etc.
-- Html.Attributes exposes functions for element attributes such as `class` and `id`.
-- Html.Events exposes functions for binding events such as `onClick` and `onInput`.

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


{-| We call `Browser.element` passing a record argument with our defined functions.
The Elm runtime is responsible for calling those functions in the appropriate moment.
-}
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


{-| Subscriptions are used to listen for external events, such as websockets
and mouse drag events. We're not using in this component, so we can just return `Sub.none`.
-}
subscriptions model =
    Sub.none


{-| Constant of possible colors users can choose from.
-}
colors : List String
colors =
    [ "#4286f4", "#41f441", "#dfe212", "#e25712", "#e21212" ]


{-| Our model definition, described earlier.
-}
type alias Model =
    { selectedColor : String
    }


{-| The init function is called on load. We're not receiving any arguments (called flags)
right now, but we'll need them in a second. The initial state is no selected color, so we'll
use an empty string.
-}
init : () -> ( Model, Cmd Msg )
init flags =
    ( { selectedColor = "" }, Cmd.none )


{-| List of actions users can perform in this component
-}
type Msg
    = ColorSelected String
    | SelectionCleared


{-| The `update` function changes the model based on the received `Msg`. To be strict about
terms, nothing is being mutated, we're just returning a changed version of the model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ColorSelected hash ->
            ( { model | selectedColor = hash }, Cmd.none )

        SelectionCleared ->
            ( { model | selectedColor = "" }, Cmd.none )


{-| The `view` function receives the model and produces HTML. The Elm runtime is responsible
for all dom diffing and juicy optimizations.
-}
view : Model -> Html Msg
view model =
    div [] [ text "Color picker element loaded!" ]
```

In order to load this program in a webpage, we need a little bit of Javascript glue:

```javascript
import { Elm } from "../elm/Colorpicker.elm";

window.addEventListener("load", ev => {
  let colorpicker = document.querySelector("#colorpicker");
  if (colorpicker) {
    Elm.Colorpicker.init({
      node: colorpicker
    });
  }
});
```

And this is the code in our HTML page:

```html
<h1 class="text-xl mb-4">Example app for the Color picker component</h1>

<div class="p-4 border">
  <div id="colorpicker"></div>
</div>
```

This is what it looks like in the browser:

![Color picker example on the page](/images/examples/colorpicker-example-01.png)

## Building the UI

It's finally time! Let's start with a simple field, label and container for the colors.

```elm
view : Model -> Html Msg
view model =
    div [ id "colorpicker" ]
        [ label [ class "font-bold" ] [ text "Choose a color" ]
        , div [] [ text "Show colors here" ]
        ]
```

Looking at HTML code in Elm syntax might be weird at first. Here's an annotated picture of this code with indications for functions and arguments:

![](/images/examples/colorpicker-view-annotated.png)

This is how it looks in the browser:

![](/images/examples/colorpicker-example-02.png)

Let's render the colors from our static list of `colors` using `List.map`. `List.map` is a function that takes two arguments: a function and a list. The list is the `colors` we defined earlier, the function is `viewColor` that we defined to take a `String` and return `Html Msg`. I would read this as _mapping over a list of strings converting them to HTML_.

```elm
view : Model -> Html Msg
view model =
    div [ id "colorpicker" ]
        [ label [ class "font-bold" ] [ text "Choose a color" ]
        , div [ class "flex items-center" ] (List.map viewColor colors)
        ]


viewColor : String -> Html Msg
viewColor hex =
    div [ class "w-6 h-6 m-1 rounded", style "background" hex ] []
```

This is how the component is looking like:

![](/images/examples/colorpicker-example-03.png)

Now let's add the first bit of interactivity with an `onClick` handler in the `viewColor` function.

```elm
viewColor : String -> Html Msg
viewColor hex =
    div
        [ onClick (ColorSelected hex)
        , class "w-6 h-6 m-1 rounded"
        , style "background" hex
        ]
        []
```

Great! It means we can click on a color and... nothing happens. Well, things do happen underneath, but we need to show the selected color with a different style (remember the awesome spec?). Let's change the `viewColor` to take another argument and modify the style slightly.

```elm
viewColor : Bool -> String -> Html Msg
viewColor isSelected hex =
    let
        className =
            if isSelected then
                "w-8 h-8 m-1 rounded shadow"

            else
                "w-6 h-6 m-1 rounded"
    in
    div
        [ onClick (ColorSelected hex)
        , class className
        , style "background" hex
        ]
        []
```

We're changing the class applied to the div based on `isSelected`. But now our `view` function is broken because
we're not passing the argument we just added. If you're using an editor with some Elm plugin installed, you're probably seeing something like this.

![](/images/examples/colorpicker-editor-error.png)

Let's fix it by wrapping in an anonymous function that runs the check for the selected color. In the example below `(model.selectedColor == hex)` evaluates to either True or False, which is passed as the argument `isSelected` in our `viewColor` function.

```elm
view : Model -> Html Msg
view model =
    div [ id "colorpicker" ]
        [ label [ class "font-bold" ] [ text "Choose a color" ]
        , div [ class "flex items-center" ] (List.map (\hex -> viewColor (model.selectedColor == hex) hex) colors)
        ]
```

It gets bigger when we click on a color! It's starting to look good!

![](/images/examples/colorpicker-example-04.png)

Let's look at clearing selection now. It should only be visible when we have a selected color. Let's declare a `viewClearSelection` that conditionally displays the action and it from the `view` function.

```elm
view : Model -> Html Msg
view model =
    div [ id "colorpicker" ]
        [ span []
            [ label [ class "font-bold" ] [ text "Choose a color" ]
            , viewClearSelection model
            ]
        , div [ class "flex items-center" ] (List.map (\hex -> viewColor (model.selectedColor == hex) hex) colors)
        ]


viewClearSelection : Model -> Html Msg
viewClearSelection { selectedColor } =
    if selectedColor == "" then
        text ""

    else
        span [ onClick SelectionCleared, class "text-sm ml-1 italic cursor-pointer" ] [ text "— Clear selection" ]
```

After this implementation, this is what our components looks like:

![](/images/examples/colorpicker-usage.gif)

Apart from the height change when a color gets selected, we're **almost** done here. That was a long journey, but we're still one step away from calling it done.

## Talking to the outer world

This component lives inside the magical Elm world right now, but we need it to communicate with the page. In particular, we're interested in two things:

- Load with a preselected color
- Save the selected color when the user submits the form this component is embedded in.

Those cases are solved in different ways. Let's start with the preselected color, which is essentially an initialization argument, or [Flags](https://guide.elm-lang.org/interop/flags.html) in Elm's terms.

```elm
type alias Flags =
    { color : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { selectedColor = flags.color }, Cmd.none )
```

We introduced the `Flags` type that only has a `color` field. In the `init` function, instead of initializing the model with an empty string, we're now using the value we got from the flag.

The flags are passed from our javascript's `init` function. In the code below, I'm fetching the preselected color from a data attribute from the HTML node. I use this pattern **all the time** for initialization flags.

```javascript
Elm.Colorpicker.init({
  node: colorpicker,
  flags: {
    color: colorpicker.getAttribute("data-color")
  }
});
```

```html
<div id="colorpicker" data-color="#e25712"></div>
```

Now the second problem: saving the selected color. This is actually pretty simple for this component because we're designing it to live inside a form. The only thing we need is a hidden input, and when the browser serializes the form on submit it'll include the value from the input automatically.

Let's add the hidden input in the `view` function.

```elm
view : Model -> Html Msg
view model =
    div [ id "colorpicker" ]
        [ span []
            [ label [ class "font-bold" ] [ text "Choose a color" ]
            , viewClearSelection model
            ]
        , div [ class "flex items-center" ] (List.map (\hex -> viewColor (model.selectedColor == hex) hex) colors)
        , input [ type_ "hidden", name "color", value model.selectedColor ] []
        ]
```

> `type_` was named this way because `type` is a keyword in Elm.

If we inspect our DOM tree we should see the hidden input in there:

![](/images/examples/colorpicker-hidden-input.png)

And that's it! Our component is now fully functional. We can initialize it with a color and it syncs the selected color with a hidden input that will be submitted along with the form.

Woosh, that was long, but we made it! Oh, and I almost forgot, [here's a gist](https://gist.github.com/luizpvas/197c4570b400e9cfe1fdd8dc79c1e1fa) with the source code.

## Challenge

- Our boss just called from a meeting. They loved our colorpicker, and they want to use in another part of the software - but there is one problem. The hidden input's name should be different there in order to match the database column name. How would you implement this change?
