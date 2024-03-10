defmodule Ecom.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecom.Carts` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        data: [1, 2],
        user: 42
      })
      |> Ecom.Carts.create_cart()

    cart
  end
end
