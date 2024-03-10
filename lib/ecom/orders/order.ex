defmodule Ecom.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field(:user_id, :integer)
    field(:product_ids, {:array, :integer})
    field(:total_price, :integer)
    field(:status, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:user_id, :product_ids, :total_price, :status])
    |> validate_required([:user_id, :product_ids, :total_price, :status])
  end
end
