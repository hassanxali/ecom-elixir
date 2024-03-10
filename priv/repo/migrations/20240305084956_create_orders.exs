defmodule MyApp.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add(:total_price, :integer)
      add(:status, :string)
      add(:user_id, references(:users))
      add(:product_ids, {:array, :integer})

      timestamps()
    end
  end
end
