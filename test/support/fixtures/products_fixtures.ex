defmodule Ecom.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecom.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some name",
        price: 42
      })
      |> Ecom.Products.create_product()

    product
  end
end
