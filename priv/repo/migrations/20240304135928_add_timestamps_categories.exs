defmodule Ecom.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      timestamps(type: :utc_datetime)
    end
  end
end
