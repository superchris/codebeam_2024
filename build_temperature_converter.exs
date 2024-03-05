File.write!("temperature_converter.wat", Orb.to_wat(TemperatureConverter))
System.cmd("wat2wasm", ["temperature_converter.wat", "-o", "temperature_converter.wasm"])
