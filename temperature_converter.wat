(module $TemperatureConverter
  (func $celsius_to_fahrenheit (export "celsius_to_fahrenheit") (param $celsius f32) (result f32)
    (f32.add (f32.mul (local.get $celsius) (f32.div (f32.const 9.0) (f32.const 5.0))) (f32.const 32.0))
  )
)
