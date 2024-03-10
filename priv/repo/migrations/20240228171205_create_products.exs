defmodule Ecom.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
