defmodule Ecom.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user, :integer
      add :data, {:array, :integer}

      timestamps(type: :utc_datetime)
    end
  end
end
