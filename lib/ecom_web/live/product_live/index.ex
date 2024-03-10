defmodule EcomWeb.ProductLive.Index do
  use EcomWeb, :live_view

  alias Ecom.Products
  alias Ecom.Products.Product

  @impl true
  def mount(_params, _session, socket) do
    products = Products.list_products()

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
    {:ok, assign(socket, products: products, added_to_cart: new_added_to_cart)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # <img src={product.image_url} alt={product.name}>

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Products.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({EcomWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Products.get_product!(id)
    {:ok, _} = Products.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end

  def handle_event("product_clicked", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: "/products/#{id}")}
  end

  # def handle_event("add_to_cart", %{"id" => id}, socket) do
  #   current_added_to_cart = Map.get(socket.assigns, :added_to_cart, %{})
  #   new_added_to_cart = Map.put(current_added_to_cart, id, true)
  #   {:noreply, assign(socket, added_to_cart: new_added_to_cart)}
  # end

  def handle_event("add_to_cart", %{"id" => id}, socket) do
    current_added_to_cart = Map.get(socket.assigns, :added_to_cart, %{})
    new_added_to_cart = Map.put(current_added_to_cart, id, true)

    Phoenix.PubSub.broadcast(
      Ecom.PubSub,
      "cart_updated",
      {:new_item_added_to_cart, new_added_to_cart}
    )

    {:noreply, assign(socket, added_to_cart: new_added_to_cart)}
  end

  # defp get_added_to_cart(socket) do
  #   added_to_cart =
  #     Map.keys(Map.filter(socket.assigns[:added_to_cart], fn {_id, value} -> value end))

  #   added_to_cart
  # end
end
