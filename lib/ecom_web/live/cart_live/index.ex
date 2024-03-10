defmodule EcomWeb.CartLive.Index do
  use EcomWeb, :live_view

  alias Ecom.Carts
  alias Ecom.Carts.Cart

  @impl true
  def mount(_params, _session, socket) do
    # Get the value of added_to_cart from the assigns
    added_to_cart = Map.get(socket.assigns, :added_to_cart)

    # Conditionally assign added_to_cart based on its value
    new_added_to_cart =
      case added_to_cart do
        # If added_to_cart is nil, assign an empty map
        nil -> %{}
        # Otherwise, keep its existing value
        _ -> added_to_cart
      end

    # Assign products and the updated added_to_cart to the socket
    {:ok, assign(socket, carts: Carts.list_carts(), added_to_cart: new_added_to_cart)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cart")
    |> assign(:cart, Carts.get_cart!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cart")
    |> assign(:cart, %Cart{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Carts")
    |> assign(:cart, nil)
  end

  @impl true
  def handle_info({EcomWeb.CartLive.FormComponent, {:saved, cart}}, socket) do
    {:noreply, stream_insert(socket, :carts, cart)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cart = Carts.get_cart!(id)
    {:ok, _} = Carts.delete_cart(cart)

    {:noreply, stream_delete(socket, :carts, cart)}
  end
end
