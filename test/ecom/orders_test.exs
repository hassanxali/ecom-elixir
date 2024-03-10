defmodule Ecom.OrdersTest do
  use Ecom.DataCase

  alias Ecom.Orders

  describe "orders" do
    alias Ecom.Orders.Order

    import Ecom.OrdersFixtures

    @invalid_attrs %{user: nil, products: nil, price: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{user: 42, products: "some products", price: 42}

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.user == 42
      assert order.products == "some products"
      assert order.price == 42
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{user: 43, products: "some updated products", price: 43}

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.user == 43
      assert order.products == "some updated products"
      assert order.price == 43
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
