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

# Hi!

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
  - Used byosting provides
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
# Hey wait I thought this talk was about WebAssembly

---

# So what?

- Portable
- Fast
- safe

---

# It's also a better abstraction boundary
### And this is what matters most

---

# Ways to organize code
- Functions
- OTP processes
- HTTP services
  - Multiple languages supported here
- Docker containers

---

# What if we could move it up?
- Functions
  - Multiple languages supported here
- OTP processes
- HTTP services
- Docker containers

---

# WebAssembly terms and concepts
- Modules
  - Code (WASM binary format)
  - Declared imports/exports
- Memory
  - An array of bytes to read/write
- Tables
  - Imported/Exported references
- Instances
  - Bundle of all of the above

---

# Runtimes
- Browsers
  - Standard APIs for loading and executing
  - integration with DOM TBD

---

# Do you remember this guy?

![duke](duke.png)

---

# Java
- Came on the scene as browser technology
  - Netscape 1995
- Server side came later
  - And that's when it really took off
- Does anyone even remember applets?

---

# My prediction: WASM is going the same (ish) way
- Browser stuff is cool
- Server side is what matters
- But now we have a truly open ecosystem

---

# WASM is an *extremely* [dynamic space](https://webassembly.org/features/)
## In particular, we should pay attention to:
- WASM GC
  - Enables garbage collected languages
  - supported by Chrome, Firefox, NodeJS
- Threads
  - Chrome, Firefox, and Safari
- Tail calls
  - Chrome, Firefox

---

# WebAssembly 2.0
- first public draft 4/19/2022
- 3 working drafts last month!

---

# Guesting: Writing a WASM module from Elixir
The bad news and the good news

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
- Official support for WASM would be the best possible future
  - See me if this is something you wanna help advocate for

---

# Orb: A DSL for WebAssembly
- A completely different approach
- Macros that compile to WAT
  - and then to WASM
- Less ambitious, but actually works!
- Maybe worse is better?

---

# More about Orb
- *not* compiling Elixir to WASM
- Thin layer over WebAssembly
- globals, mutable state
- controls flow
  - if/then
  - loops
- Memory management

---

# Orb by example
```elixir
defmodule TemperatureConverter do
  use Orb

  defw celsius_to_fahrenheit(celsius: F32), F32 do
    celsius |> F32.mul(F32.div(9.0, 5.0)) |> F32.add(32.0)
  end

end
```
```
iex> File.write!("temperature_converter.wat", Orb.to_wat(TemperatureConverter))
wasm2wat temperature_converter.wat -o temperature_converter.wasm
```
---

# Running it in [browser](hello.html)
```html
<html>

<head>
  <script type="module">

    const { instance } = await WebAssembly.instantiateStreaming(fetch("temperature_converter.wasm"), {});
    const { celsius_to_fahrenheit } = instance.exports;
    document.getElementById('slider').addEventListener('input', (evt) => {
      console.log(`Celsius: ${evt.target.value}`);
      console.log(`Fahrenheit: ${celsius_to_fahrenheit(Number(evt.target.value))}`);
    })
  </script>
</head>

<body>
  Temperature converter: <input type="range" id="slider" name="celsius" min="0" max="100" />
</body>

</html>
```

---

# WASM Components
- Grew out of WASI

---

# WIT
#### An Interface Definition Language (IDL) for WASM Components
- package
  - world
    - interface
    - functions
    - types
    - import/exports

---
# WIT type system
- built in
  - booleans
  - numeric types
  - string, char
  - lists
- user defined
  - records
  - variants
  - enums

---

# WASM component implementations
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
  - we can "roll our own"

---

# WIT Example
- This defines the interface my WASM component conforms to
```
package local:todo-list

world todo-list {
  export init: func() -> list<string>
  export add-todo: func(todo: string, todos: list<string>) -> list<string>
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

### The Elixir code to call it..
```elixir
defmodule LivestateTestbedWeb.WasmComponent do
  use Rustler, otp_app: :livestate_testbed, crate: "livestatetestbedweb_wasmcomponent"

  # When your NIF is loaded, it will override this function.
  def init(), do: error()
  def add_todo(_todo, _todo_list), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
```

---

## Rust code
```rust
#[rustler::nif(name = "add_todo")]
fn add_todo_impl(todo: String, todo_list: Vec<String>) -> Vec<String> {
    let mut config = Config::default();
    config.wasm_component_model(true);
    let engine = Engine::new(&config).unwrap();
    let linker = Linker::new(&engine);

    let mut table = Table::new();

    let wasi = WasiCtxBuilder::new()
        .build(&mut table);
    let mut store = Store::new(&engine, wasi);

    let component = Component::from_file(&engine, "./todo-list.wasm").context("Component file not found").unwrap();

    let (instance, _) = TodoList::instantiate(&mut store, &component, &linker).unwrap();

    instance.call_add_todo(&mut store, &todo, &todo_list[..]).unwrap()
}

rustler::init!("Elixir.LivestateTestbedWeb.WasmComponent", [init_impl, add_todo_impl]);
```
---

# Lets try it!

---

# What will become possible..
- WASM component based ecosystem is starting to emerge
- WARG package registry
  - Use any library for any language
- WASM components as deployment artifacts
  - Serverless functions for realz tho
  - Already starting to happen

---

# We don't want to be left behind
### The good news: it's still early times
### We have a lot of work to do!

---
