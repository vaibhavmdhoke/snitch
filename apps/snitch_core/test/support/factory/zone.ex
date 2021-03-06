defmodule Snitch.Factory.Zone do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Snitch.Data.Schema.{Zone, StateZone, CountryZone}

      def zone_factory do
        %Zone{
          name: sequence(:area, fn area_code -> "area-#{area_code + 51}" end),
          description: "Does area-51 exist?"
        }
      end

      def zones(context) do
        sz_count = Map.get(context, :state_zone_count, 0)
        cz_count = Map.get(context, :country_zone_count, 0)

        [
          zones:
            insert_list(sz_count, :zone, zone_type: "S") ++
              insert_list(cz_count, :zone, zone_type: "C")
        ]
      end
    end
  end
end
