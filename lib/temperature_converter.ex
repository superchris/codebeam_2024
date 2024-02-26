defmodule TemperatureConverter do
  use Orb

  defw celsius_to_fahrenheit(celsius: F32), F32 do
    F32.mul(celsius, 9.0)
  end

  defw fahrenheit_to_celsius(fahrenheit: F32), F32 do
    (fahrenheit - 32.0) * 5.0 / 9.0
  end

  defw get_mime_type(), I32 do
    ~S"text/html"
  end

  defw get_body(), I32 do
    ~S"""
    <!doctype html>
    <meta charset=utf-8>
    <h1>Hello world</h1>
    """
  end
end
