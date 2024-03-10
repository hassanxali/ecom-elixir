defmodule EcomWeb.CartLiveTest do
  use EcomWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecom.CartsFixtures

  @create_attrs %{data: [1, 2], user: 42}
  @update_attrs %{data: [1], user: 43}
  @invalid_attrs %{data: [], user: nil}

  defp create_cart(_) do
    cart = cart_fixture()
    %{cart: cart}
  end

  describe "Index" do
    setup [:create_cart]

    test "lists all carts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/carts")

      assert html =~ "Listing Carts"
    end

    test "saves new cart", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/carts")

      assert index_live |> element("a", "New Cart") |> render_click() =~
               "New Cart"

      assert_patch(index_live, ~p"/carts/new")

      assert index_live
             |> form("#cart-form", cart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cart-form", cart: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/carts")

      html = render(index_live)
      assert html =~ "Cart created successfully"
    end

    test "updates cart in listing", %{conn: conn, cart: cart} do
      {:ok, index_live, _html} = live(conn, ~p"/carts")

      assert index_live |> element("#carts-#{cart.id} a", "Edit") |> render_click() =~
               "Edit Cart"

      assert_patch(index_live, ~p"/carts/#{cart}/edit")

      assert index_live
             |> form("#cart-form", cart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cart-form", cart: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/carts")

      html = render(index_live)
      assert html =~ "Cart updated successfully"
    end

    test "deletes cart in listing", %{conn: conn, cart: cart} do
      {:ok, index_live, _html} = live(conn, ~p"/carts")

      assert index_live |> element("#carts-#{cart.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#carts-#{cart.id}")
    end
  end

  describe "Show" do
    setup [:create_cart]

    test "displays cart", %{conn: conn, cart: cart} do
      {:ok, _show_live, html} = live(conn, ~p"/carts/#{cart}")

      assert html =~ "Show Cart"
    end

    test "updates cart within modal", %{conn: conn, cart: cart} do
      {:ok, show_live, _html} = live(conn, ~p"/carts/#{cart}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cart"

      assert_patch(show_live, ~p"/carts/#{cart}/show/edit")

      assert show_live
             |> form("#cart-form", cart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cart-form", cart: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/carts/#{cart}")

      html = render(show_live)
      assert html =~ "Cart updated successfully"
    end
  end
end
