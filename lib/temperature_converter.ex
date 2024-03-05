defmodule TemperatureConverter do
  use Orb

  wasm_mode(Orb.F32)

  global do
    @mode 0
  end

  defw celsius_to_fahrenheit(celsius: F32), F32 do
    celsius * (9.0 / 5.0) + 32.0
  end

  defw fahrenheit_to_celsius(fahrenheit: F32), F32 do
    (fahrenheit - 32.0) * (5.0 / 9.0)
  end

  defw convert_temperature(temperature: F32), F32 do
    if @mode do
      celsius_to_fahrenheit(temperature)
    else
      fahrenheit_to_celsius(temperature)
    end
  end

  defw set_mode(mode: I32) do
    @mode = mode
  end

end
