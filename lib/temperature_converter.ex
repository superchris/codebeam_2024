defmodule TemperatureConverter do
  use Orb

  defw celsius_to_fahrenheit(celsius: F32), F32 do
    celsius |> F32.mul(F32.div(9.0, 5.0)) |> F32.add(32.0)
  end

end
