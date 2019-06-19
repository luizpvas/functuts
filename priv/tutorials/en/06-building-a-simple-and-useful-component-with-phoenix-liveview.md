Building a simple and useful component with Phoenix LiveView
In this tutorial, we're going to implement a subscription page for a fictional SAAS company.

# Building a simple and useful component with Phoenix LiveView

Phoenix LiveView is a library for writing front-end components backed by the server. With LiveView, we can make interactive UIs without writing a single line of Javascript.

I've seen people question the benefits of "isomorphic" apps, usually using Node on the backend. LiveView is different because we're not only using the same language, we're sharing the same environment between client and server, or rather, it's all server-side now and the client is just a shell. In particular, I'm excited about:

- A single place for translations with Gettext.
- Routing helpers. Have you ever hardcoded a URL in a JS file?

In this tutorial, we're going to implement a subscription page for a fictional SAAS company.

## What we're building

Here's the spec for the component:

![Choose between monthly or yearly billing, the plan and the amount of people](/images/examples/liveview/spec.png)

This design was heavily inspired by [transistor.fm](https://dashboard.transistor.fm/signup). The user can choose between monthly or yearly billing, the plan they want and how many seats they want. The total amount should update as the user change those settings. **Let's get started**.

## Installing LiveView

I'm not going dive into the details here. LiveView is only available on Github currently, and the installation steps might change in the future &mdash; so make sure you follow the [latest instructions](https://github.com/phoenixframework/phoenix_live_view#installation).

I also added TailwindCSS using a CDN so we have access to Tailwind's utilities without having to configure the build system.

## Mounting the component

Part of the installation process is importing the `live_render` function in our views. With `live_render`, we can embed a component inside a regular page rendered from a controller.

Let's change the page that comes with the Phoenix generator (`templates/page/index.html.eex`) to render a live component:

```html
<%= live_render @conn, AppWeb.Live.Subscription %>
```

We should see an error if we reload the app now because we haven't defined the module for `AppWeb.Live.Subscription`. Let's define this module in `lib/app_web/live/subscription.ex`:

```elixir
defmodule AppWeb.Live.Subscription do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>Hello from LiveView</div>
    """
  end

  def mount(_session, socket) do
    {:ok, socket}
  end
end
```

It's looking like this now:

![First render with LiveView working](/images/examples/liveview/hello-from-liveview.png)

## First feature: choosing a plan

Phoenix LiveView works in a similar way to React and Elm. The application state is represented as data and the view just transforms this state into HTML. The DOM is never used to store anything.

So let's try to come up with the Model for this component. I usually start thinking about things that can change over time, such as:

- Which plan the user selected
- Which period the user selected (monthly/yearly)
- How many seats the user is interested

I don't think the list of plans should live in the model because it's pretty much a static list. Maybe in a real application, it would be read from a database, but in this case, I'm just gonna declare it as a const.

In the code below, I'm assigning the initial state to the socket and rendering the plans from the static list, but we're not showing the selected value yet.

```elixir
defmodule AppWeb.Live.Subscription do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="flex">
      <div class="w-1/2 mr-4">
        <button>Monthly</button>
        <button>Yearly</button>

        <%= for plan <- plans() do %>
          <div class="mt-2 border rounded p-2">
            <%= plan[:name] %>
          </div>
        <% end %>
      </div>

      <div class="w-1/2">
        <div>
          <label>How many seats are you interested?</label>
          <input type="number">
        </div>

        <div>
          Total: $$
        </div>

        <div>
          <button>Submit</button>
        </div>
      </div>
    </div>
    """
  end

  def plans do
    [
      %{id: 1, name: "Starter", monthly_value: 1990, yearly_value: 19000},
      %{id: 2, name: "Basic", monthly_value: 2990, yearly_value: 29000},
      %{id: 3, name: "Enterprise", monthly_value: 3990, yearly_value: 39000}
    ]
  end

  def mount(_session, socket) do
    {:ok,
      socket
      |> assign(:selected_plan_id, 1)
      |> assign(:billing_period, :monthly)
      |> assign(:seats, 1)
    }
  end
end
```

This is what our component is looking like:

![](/images/examples/liveview/first-render.png)

Apart from rendering the plans from our list, the rest of the component is still static. We're not showing the correct values stored in the state and no events are fired. Let's do this next.

## Rendering the state

Before wiring up the events, let's show in the view values stored in the state. Let's go step by step.

To show the number of seats we only need a `value` in the input:

```html
<input type="number" value="<%= @seats %>" />
```

To show the selected plan, we need a conditional inside our `for` loop:

```html
<%= for plan <- plans() do %>
  <%= if @selected_plan_id == plan[:id] do %>
  <div class="mt-2 border-2 border-green-500 rounded p-2">
    <%= plan[:name] %>
  </div>
  <% else %>
    <div class="mt-2 border-2 rounded p-2">
      <%= plan[:name] %>
    </div>
  <% end %>
<% end %>
```

To show the selected billing period, we can wrap the buttons with a conditional. This is not the DRYest solution, but it's fine for now:

```html
<%= if @billing_period == :monthly do %>
  <button>Monthly</button>
<% else %>
  <button class="bg-gray-500 border-gray-600">Monthly</button>
<% end %>

<%= if @billing_period == :yearly do %>
  <button>Yearly</button>
<% else %>
  <button class="bg-gray-500 border-gray-600">Yearly</button>
<% end %>
```

The last thing we need before wiring up events is calculating the total price, and this is another place LiveView shines: it's all Elixir code. If you're not a big Javascript fan, this cannot be overstated. It's just amazing to have Elixir available for writing the business logic for both UI and the server.

Let's change the view to render the calculated total price:

```html
<div>
  Total: <%= total_price_in_cents(assigns) |> format_money() %>
</div>
```

and declare both functions in the `Subscription` module:

```elixir
def total_price_in_cents(assigns) do
  plans()
  |> Enum.find(fn plan -> plan[:id] == assigns[:selected_plan_id] end)
  |> case do
    nil -> "Invalid selected plan"
    plan ->
      case assigns[:billing_period] do
        :monthly -> plan[:monthly_value] * assigns[:seats]
        :yearly  -> plan[:yearly_value] * assigns[:seats]
        _        -> "Invalid billing period"
      end
  end
end

def format_money(cents) do
  "$#{:erlang.float_to_binary(cents / 100, decimals: 2)}"
end
```

This is how our component is looking like:

![Print of the component after rendering state values](/images/examples/liveview/second-render.png)

## Making things interactive

For this component, we're going to register events for the following actions:

* Selecting a different plan (click)
* Switch between monthly and yearly (click)
* Changing the number of seats in (input)

Let's start with selecting plans. For this, we need to add `phx-click` and `phx-value` to the container div of each plan:

```html
<!-- inside the for loop -->
<div class="mt-2 border-2 rounded p-2" phx-click="select_plan" phx-value="<%= plan[:id] %>">
  <%= plan[:name] %>
</div>
```

and the event handler:

```elixir
def handle_event("select_plan", id, socket) do
  {id, _} = Integer.parse(id)
  {:noreply, assign(socket, :selected_plan_id, id)}
end
```

With this code, we should be able to select plans and see the total price changing.

Now... I've got to pause this for a second. Before we get to monthly/yearly billing, I just realized I forgot to show the plan's price in the UI. Let's do this now:

```html
<div class="mt-2 border-2 rounded p-2" phx-click="select_plan" phx-value="<%= plan[:id] %>">
  <%= plan[:name] %>
  <%= plan_price(plan, assigns) |> format_money() %>
</div>
```

This function returns the plan's value based on the billing period:

```elixir
def plan_price(plan, assigns) do
  case assigns[:billing_period] do
    :monthly -> plan[:monthly_value]
    :yearly  -> plan[:yearly_value]
    _        -> "Invalid billing period"
  end
end
```

Now let's write the click handler for the billing period buttons:

```html
<button class="bg-gray-500 border-gray-600" phx-click="set_billing_period" phx-value="monthly">
  Monthly
</button>

<button class="bg-gray-500 border-gray-600" phx-click="set_billing_period" phx-value="yearly">
  Yearly
</button>
```

and the event handlers for both `monthly` and `yearly`:

```elixir
def handle_event("set_billing_period", "monthly", socket) do
  {:noreply, assign(socket, :billing_period, :monthly)}
end

def handle_event("set_billing_period", "yearly", socket) do
  {:noreply, assign(socket, :billing_period, :yearly)}
end
```

Let's bind an event to the seat's input. We don't need `phx-value` because `phx-keyup` already passes the input's value as a parameter to the event handler.

```html
<input type="number" phx-keyup="set_seats" value="<%= @seats %>">
```

and the event handler:

```elixir
def handle_event("set_seats", value, socket) do
  case Integer.parse(value) do
    {seats, _} -> {:noreply, assign(socket, :seats, seats)}
    _          -> {:noreply, socket}
  end
end
```

## Wraping things up

In order to finish this component, I wanted to wrap everything in a `<form>`, handle the `submit` event and return a redirect. I couldn't get this working, maybe it's an issue the current version on Github. I think the server was sending the correct response, but nothing happened client-side.

```elixir
def handle_event("submit", value, socket) do
  # The redirect is being sent to the browser, but the JS library doesn't seem to be working
  {:stop, socket |> redirect(to: "https://google.com")}
end
```

![Example of the resopnse for a redirect from Phoenix LiveView](/images/examples/liveview/redirect-didnt-work.png)


As an alternative, to show some feedback when the user submits the form, I'm toggling a `subscribed` variable and conditionally showing a success message:

```html
<form class="flex" phx-submit="submit">
  <!-- template here -->
  <!-- ... -->

  <%= if @subscribed do %>
    <div>You're subscribed!</div>
  <% end %>
</form>
```

```elixir
def mount(_session, socket) do
  {:ok, 
    socket
    |> assign(:selected_plan_id, 1)
    |> assign(:billing_period, :monthly)
    |> assign(:seats, 1)
    |> assign(:subscribed, false) # Added this state
  }
end

def handle_event("submit", value, socket) do
  {:noreply, assign(socket, :subscribed, true)}
end
```

## Final version

The final code is available in [this gist](https://gist.github.com/luizpvas/85edc618360f40c4d623b20502fd99db). I also tweaked the UI a little bit. This is the final result:

![Final result of this component](/images/examples/liveview/final-subscription.gif)