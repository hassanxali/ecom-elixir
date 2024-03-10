defmodule EcomWeb.SidebarLive do
  use EcomWeb, :live_view

  defimpl Jason.Encoder, for: Ecom.Products.Product do
    def encode(product, _opts) do
      %{
        "id" => product.id,
        "name" => product.name,
        "price" => product.price,
        "inserted_at" => product.inserted_at,
        "updated_at" => product.updated_at
      }
    end
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Ecom.PubSub, "cart_updated")

    added_to_cart = Map.get(socket.assigns, :added_to_cart)
    cart_items = %{}

    new_added_to_cart =
      case added_to_cart do
        nil ->
          %{}

        _ ->
          added_to_cart
      end

    {:ok,
     assign(socket, added_to_cart: new_added_to_cart, cart_items: cart_items, total_price: 0)}
  end

  def handle_event("remove_from_cart", %{"id" => id}, socket) do
    IO.puts("Removing item from cart")

    updated_cart_items =
      Enum.reject(socket.assigns.cart_items, fn item -> item.id == String.to_integer(id) end)

    cart_items_ids = Enum.map(updated_cart_items, & &1.id)
    IO.inspect(cart_items_ids)

    socket =
      socket
      |> push_event("store", %{
        key: "cart",
        data: cart_items_ids
      })

    {:noreply, assign(socket, cart_items: updated_cart_items)}
  end

  # def handle_info(:new_item_added_to_cart, socket) do
  #   {:noreply, socket}
  # end

  def handle_info({:new_item_added_to_cart, new_added_to_cart}, socket) do
    cart_items = Ecom.Products.get_cart(new_added_to_cart)

    total_price =
      Enum.reduce(cart_items, 0, fn product, acc ->
        acc + product.price
      end)

    socket =
      socket
      |> push_event("store", %{
        key: "cart",
        data: Map.keys(new_added_to_cart)
      })

    {:noreply, assign(socket, cart_items: cart_items, total_price: total_price)}
  end

  def handle_event("restore", %{"cart" => nil}, socket), do: {:noreply, socket}

  def handle_event("restore", %{"cart" => cart}, socket) do
    ids_list = String.split(cart, ",")
    new_added_to_cart = Enum.into(ids_list, %{}, fn id -> {id, true} end)
    cart_items = Ecom.Products.get_cart(new_added_to_cart)

    total_price =
      Enum.reduce(cart_items, 0, fn product, acc ->
        acc + product.price
      end)

    socket = socket |> assign(cart_items: cart_items, total_price: total_price)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div phx-hook="restore" id="restore_this" class="relative z-10" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

      <div class="fixed inset-0 overflow-hidden">
        <div class="absolute inset-0 overflow-hidden">
          <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full">
            <div class="pointer-events-auto w-screen max-w-md">
              <div class="flex h-full flex-col overflow-y-scroll bg-white shadow-xl">
                <div class="flex-1 overflow-y-auto px-4 py-6 sm:px-6">
                  <div class="flex items-start justify-between">
                    <h2 class="text-lg font-medium text-gray-900" id="slide-over-title">Shopping cart</h2>
                    <div class="ml-3 flex h-7 items-center">
                      <button type="button" class="relative -m-2 p-2 text-gray-400 hover:text-gray-500">
                        <span class="absolute -inset-0.5"></span>
                        <span class="sr-only">Close panel</span>
                        <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                          aria-hidden="true">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </button>
                    </div>
                  </div>

                  <div class="mt-8">
                    <div class="flow-root">
                      <ul role="list" class="-my-6 divide-y divide-gray-200">
                        <%= if not Enum.empty?(@cart_items) do %>
                          <%= for product <- @cart_items do %>

                            <li class="flex py-6">
                              <div class="h-24 w-24 flex-shrink-0 overflow-hidden rounded-md border border-gray-200">
                                <img
                                  src="https://tailwindui.com/img/ecommerce-images/shopping-cart-page-04-product-02.jpg"
                                  alt="Front of satchel with blue canvas body, black straps and handle, drawstring top, and front zipper pouch."
                                  class="h-full w-full object-cover object-center">
                              </div>

                              <div class="ml-4 flex flex-1 flex-col">
                                <div>
                                  <div class="flex justify-between text-base font-medium text-gray-900">
                                    <h3>
                                      <a href="#">
                                        <%= product.name %>

                                      </a>
                                    </h3>
                                    <p class="ml-4">$<%= product.price %>
                                    </p>
                                  </div>
                                  <p class="mt-1 text-sm text-gray-500">Blue</p>
                                </div>
                                <div class="flex flex-1 items-end justify-between text-sm">
                                  <p class="text-gray-500">Qty 1</p>

                                  <div class="flex">
                                    <button type="button" phx-value-id={product.id}
                                      class="font-medium text-indigo-600 hover:text-indigo-500" phx-click="remove_from_cart">Remove</button>
                                  </div>
                                </div>
                              </div>
                            </li>

                            <% end %>
                              <% else %>
                                <div>
                                  <!-- Display a message when there are no products in the cart -->
                                  No products added to the cart.
                                </div>
                                <% end %>

                                  <!-- More products... -->
                      </ul>
                    </div>
                  </div>
                </div>

                <div class="border-t border-gray-200 px-4 py-6 sm:px-6">
                  <div class="flex justify-between text-base font-medium text-gray-900">
                    <p>Subtotal</p>
                    <p>$<%= @total_price %></p>
                  </div>
                  <p class="mt-0.5 text-sm text-gray-500">Shipping and taxes calculated at checkout.</p>
                  <div class="mt-6">
                    <a href="/checkout"
                      class="flex items-center justify-center rounded-md border border-transparent bg-indigo-600 px-6 py-3 text-base font-medium text-white shadow-sm hover:bg-indigo-700">Checkout</a>
                  </div>
                  <div class="mt-6 flex justify-center text-center text-sm text-gray-500">
                    <p>
                      or
                      <button type="button" class="font-medium text-indigo-600 hover:text-indigo-500">
                        Continue Shopping
                        <span aria-hidden="true"> &rarr;</span>
                      </button>
                    </p>
                  </div>
                </div>
              </div>
          </div>
        </div>
      </div>
    </div>

    </div>
    """
  end
end
