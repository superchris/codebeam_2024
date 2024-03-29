(module $TemperatureConverter
  (global $mode (mut i32) (i32.const 0))
  (func $celsius_to_fahrenheit (export "celsius_to_fahrenheit") (param $celsius f32) (result f32)
    (f32.add (f32.mul (local.get $celsius) (f32.div (f32.const 9.0) (f32.const 5.0))) (f32.const 32.0))
  )
  (func $fahrenheit_to_celsius (export "fahrenheit_to_celsius") (param $fahrenheit f32) (result f32)
    (f32.mul (f32.sub (local.get $fahrenheit) (f32.const 32.0)) (f32.div (f32.const 5.0) (f32.const 9.0)))
  )
  (func $convert_temperature (export "convert_temperature") (param $temperature f32) (result f32)
    (global.get $mode)
    (if (result f32)
      (then
        (call $celsius_to_fahrenheit (local.get $temperature))
      )
      (else
        (call $fahrenheit_to_celsius (local.get $temperature))
      )
    )
  )
  (func $set_mode (export "set_mode") (param $mode i32)
    (local.get $mode)
    (global.set $mode)
  )
)
