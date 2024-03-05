---
marp: true
style: |

  section h1 {
    color: #6042BC;
  }

  section code {
    background-color: #e0e0ff;
  }

  footer {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 100px;
  }

  footer img {
    position: absolute;
    width: 120px;
    right: 20px;
    top: 0;

  }
  section #title-slide-logo {
    margin-left: -60px;
  }
---

## It's time to start paying attention to WebAssembly (again)!
Chris Nelson
@superchris
chris@launchscout.com
![h:200](full-color.png#title-slide-logo)

---

# What is Web Assembly?
### AKA WASM
- A spec for a virtual machine
- Kinda like
  - BEAM
  - JVM
  - CLR
## But..
- Standardized by W3C (fine folks who brought us HTML etc)
- Implemented by all the browsers
- Lots of languages compile to WASM

---

# The two sides of WebAssembly
## Host
- Code which invokes WASM modules
- Needs to provide a runtime environment
## Guest
- Code which is compiled to WASM modules
- Hosted by a runtimes (eg browser?)

---

# We'd love to do both
## But I think hosting is more practical
## So I'm gonna talk about it first

---

# Story time

---

# Launch Elements
- A set of hosted custom elements
- Drop in functionality for static websites
- Think: universal plugins for websites
  - Ecommerce
  - comments
  - Hosted forms

---

# <launch-form>
- a wrapper element for forms
- saves the responses
  - email
  - posts to a webhook

---

## It sure would be cool to let users tell me what to do with their form responses

---

# That means I need
- A way for user to provide code
- Using whatever language they'd like
- A way to execute it safely

---

# WebAssembly fits the bill!
- Lots o languages compile to it
- Runtimes for Elixir exist
- It's safe and sandboxed
  - No access to anything to explicitly granted

---

# But it needs a little help
- Limited value types
  - numbers
  - functions
    - imported and exported
  - vectors
- Any more complex is just bytes in memory
- Which you get to manage :(

---

# Doesn't sound awesome...

---

# Extism
## "a plug-in system for everyone"
- Making WASM practical
- Just enough memory management to do useful things
- Strings/byte I/O
  - What they mean is up to 
  - JSON works well here

---

# How it works
- Hosts use an SDK
  - Elixir has one
- Guests use a PDK
  - most languages that compile to WASM supported

---

# A form handler function using Extism JS PDK
```js
function handleForm() {
  const inputObject = JSON.parse(Host.inputString());
  inputObject.source = `CodeBEAM 2024`;
  const request = {
    method: "POST",
    url: 'https://eoqkynla62cbht1.m.pipedream.net'
  }
  const response = Http.request(request, JSON.stringify(inputObject));
  console.log(response);
  if (response.status != 200) throw new Error(`Got non 200 response ${response.status}`)
  Host.outputString(JSON.stringify(inputObject));
}

module.exports = { handleForm };
```

---

# Extism host
```elixir
  defp fire_wasm_handler(%WasmHandler{wasm: %{file_name: file_name}}, response) do
    manifest = %{wasm: [%{path: "./priv/static/uploads/#{file_name}"}], allowed_hosts: ["*"]}
    {:ok, plugin} = Extism.Plugin.new(manifest, true)
    Extism.Plugin.call(plugin, "handleForm", response |> Jason.encode!())
  end
```

---

# [Live Demo](form-demo.html)

---

# That's awesome, but..
- Maybe a little more structure?
- More than just HTTP plz

---

# WASI
## WebAssembly System Interface
  - WASM on the server
  - APIs Filesystems, networking, etc
  - Used by hosting providers
    - wasmedge
    - fermyon
---

# WebAssembly Component Model
- Rich, language agnostic type system
- "lift" and "lower" into memory
- Express both imports and exports
- Composable
- WASI P2 is implemented as components

---

# WIT
## WebAssembly Interface Definition Language
- Defines the interface to a component
- Much richer type system
  - strings
  - booleans
  - lists
  - enums
  - variants
  - records
  - UDTs

---

# WASM component runtime support
- Wasmtime (Rust)
- JCO (Javascript)
- componentize_py (Python)
- ??? (Elixir)

---

# Elixir and WASM Components
- Wasmex
  - wrapper for wasmtime
  - components not yet supported
- Rustler
  - rust for elixir
  - we can "roll our own" component wrapper

---

# Let's make a Todo List!
## todo-list.wit
```
package local:todo-list;

world todo-list {
  export init: func() -> list<string>;
  export add-todo: func(todo: string, todos: list<string>) -> list<string>;
}
```

---

### The JS implementation...
```js
export function init() {
  return ['Hello', 'WASM Components'];
}

export function addTodo(todo, todos) {
  return [todo, ...todos];
}
```
### Building it
```
jco componentize todo-list.js --wit todo-list.wit -n todo-list -o todo-list.wasm
```

---

# Elixir wrapper
```elixir
defmodule TodoList do
  use Rustler, otp_app: :wasm_component_demo, crate: "todo_list"

  # When your NIF is loaded, it will override this function.
  def init(serialized_component), do: error()
  def add_todo(serialized_component, todo, todo_list), do: error()

  def load_component(), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
```

---

# Let's try it...

---

# Components: Yes, it's still early but...
- WASM component based ecosystem is starting to emerge
- Scenarios:
  - Deployment artifacts
  - User extensions for SAAS eg replacing web hooks
  - ???

---

# But what about the browser?
### Elixir as a Guest

---

# Firefly (formerly Lumen)
- Extremely ambitious goal: port the BEAM to WASM
- Made some promising progress
- Heavily invested in by Dockyard (and others?)
- Not currently active

---

# Firefly challenges
- probably started to soon?
- Needs some key extensions
  - WASM GC
  - Threads/async
  - tail call
- These things have made significant progress
- Might be time for a restart?

---

# But then what?
- Let's say Firefly gets "done"
- Tracking Elixir/Erlang and keeping up
- Official support for WASM would be the "gold standard"
- Lot of work to get there
- Lots of advocacy needed to make it happen

---

# Orb: A DSL for WebAssembly
- A completely different approach
- Macros that compile to WASM (via WAT)
- Pretty low level
  - No component support (yet)
  - Memory management is up to you

---

# Orb by example
```elixir
defmodule TemperatureConverter do
  use Orb

  wasm_mode(Orb.F32)

  global do
    @mode 0
  end

  defw set_mode(mode: I32) do
    @mode = mode
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

end

```
---

# Running it in [browser](temperature_converter.html)
```html
<html>

<head>
  <script type="module">
    const { instance } = await WebAssembly.instantiateStreaming(fetch("temperature_converter.wasm"), {});
    const { convert_temperature, set_mode } = instance.exports;
    document.getElementById('mode').addEventListener('input', (evt) => {
      set_mode(Number(evt.target.value));
    });
    document.getElementById('slider').addEventListener('input', (evt) => {
      document.getElementById('temperature').innerHTML = convert_temperature(Number(evt.target.value));
    })
  </script>
</head>

<body>
  <div>
    0 <input type="range" id="slider" name="celsius" min="0" max="100" /> 100
  </div>
  <select id="mode">
    <option value="0">Fahrenheit to Celsius</option>
    <option value="1">Celsius to Fahrenheit</option>
  </select>
  <div>Temperature: <span id="temperature"></span></div>
</body>

</html>
```

---

# Other things Orb can do
- Mutable globals (eww?)
- Loops and conditionals
- Memory allocation
- String constants
- Compile time Elixir

---

# What would it take to support WASM components
- Community involvement
- Deep understanding of component spec
- Lift/lower of erlang terms into WASM memory
- Not easy, but definitely doable    

---
