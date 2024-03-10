defmodule Ecom.Carts.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    field :data, {:array, :integer}
    field :user, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:user, :data])
    |> validate_required([:user, :data])
  end
end
