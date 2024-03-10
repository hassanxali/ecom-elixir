defmodule EcomWeb.CartLive.FormComponent do
  use EcomWeb, :live_component

  alias Ecom.Carts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage cart records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="cart-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:user]} type="number" label="User" />
        <.input
          field={@form[:data]}
          type="select"
          multiple
          label="Data"
          options={[{"1", 1}, {"2", 2}]}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Cart</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{cart: cart} = assigns, socket) do
    changeset = Carts.change_cart(cart)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"cart" => cart_params}, socket) do
    changeset =
      socket.assigns.cart
      |> Carts.change_cart(cart_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"cart" => cart_params}, socket) do
    save_cart(socket, socket.assigns.action, cart_params)
  end

  defp save_cart(socket, :edit, cart_params) do
    case Carts.update_cart(socket.assigns.cart, cart_params) do
      {:ok, cart} ->
        notify_parent({:saved, cart})

        {:noreply,
         socket
         |> put_flash(:info, "Cart updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_cart(socket, :new, cart_params) do
    case Carts.create_cart(cart_params) do
      {:ok, cart} ->
        notify_parent({:saved, cart})

        {:noreply,
         socket
         |> put_flash(:info, "Cart created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
