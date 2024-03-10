defmodule Ecom.Repo.Migrations.AddImagesToProducts do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:name, :string)
    end

    alter table(:products) do
      add(:image, :string)
      add(:category_id, references(:categories))
    end
  end
end
