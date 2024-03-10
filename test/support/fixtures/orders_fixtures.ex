defmodule Ecom.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecom.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        price: 42,
        products: "some products",
        user: 42
      })
      |> Ecom.Orders.create_order()

    order
  end
end
