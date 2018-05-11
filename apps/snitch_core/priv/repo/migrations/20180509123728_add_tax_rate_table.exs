defmodule Snitch.Repo.Migrations.AddTaxRateTable do
  use Ecto.Migration

  def change do
    create  table(:snitch_tax_rates) do
      add :name, :string
      add :value, :decimal
      add :calculator, :string
      add :deleted_at, :utc_datetime
      add :included_in_price, :boolean
      add :tax_category_id, references(:snitch_tax_categories)
      add :zone_id, references(:snitch_zones)

      timestamps()
    end
  end
end
