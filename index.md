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

# Goals: to convince you that...
- WebAssembly matters
- Elixir support needs to improve
- You can and should help!

---

# Agenda
- What is WebAssembly
- Where is it now
- Where is it going
- What we can do in Elixir
- What we need to able to do

---

# What is Web Assembly?
### A binary instruction format for a stack-based virtual machine.

---

# So what?
- Standardized by W3C (fine folks who brought us HTML etc)
- We supported by all the browsers
- Portable
- Fast
- safe

---

# But rly so what?
## It's also a better abstraction boundary
### And this is why it actually matters

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

# WebAssembly 1.0
- Limited value types
  - numbers
  - functions
    - imported and exported
  - vectors
- Any more complex is just bytes in memory
- Which you get to manage

---

# Runtimes
- Browsers
  - Standard APIs for loading and executing
  - integration with DOM (etc) is
- WASI (WebAssembly System Interface)
  - WASM on the server
  - APIs for server side WASM
  - Inspired by POSIX

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

# The two sides of WASM
## Host
- Code which invokes WASM modules
- Needs to provide a runtime environment
## Guest
- Code which is compiled to WASM modules
- Hosted by a runtimes (eg browser?)
### We'd really like to do both!

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

# Orb by example

---

# Running it in browser

---

# Hosting: calling WASM from Elixir
## Possible scenarios
- Leveraging libs from other languages
- Allowing safe user extenstions to our system
  - E.g., replacing a web hook

---

# What do we need?
- A runtime environment
- Type conversion
  - Low level value types are easier
  - High level types require memory management

---

# An example: Launch Elements
- Custom elements with hosted backend
- Launch Form: simple form wrapper
- What to do with results
  - Store em
  - Email em
  - ~~Send to web hook~~ custom logic in WASM

---

# Extism
## "a plug-in system for everyone"
- Making WASM practical
- Hosts run a plugin
  - Elixir SDK
- Guests are a plugin
  - PDKs are the tool here
  - Not one for Elixir (yet)
- Strings/byte I/O
  - What they mean is up to you

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

# Extism guest
```js
function handleForm() {
  const inputObject = JSON.parse(Host.inputString());
  inputObject.name = `from wasm ${inputObject.name}`;
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

# Live demo time

---

# WASI
- WebAssembly System Interface
- APIs for server side WASM
  - What should a runtime provide?
- Currently at Preview 2

---

# WASM Components
- A layer over WASM modules
- Rich, language agnostic type system
- "lift" and "lower" into memory
- Express high level dependencies
- Composable
- WASI P2 is implemented as components

---

# WIT
#### An Interface Definition Language (IDL) for WASM Components
```
package local:todo-list

world todo-list {
  export init: func() -> list<string>
  export add-todo: func(todo: string, todos: list<string>) -> list<string>
}
```
---

# Runtimes
- Wasmtime
  - Rust
- JCO
  - Javascript

---

# Elixir and WASM Components
- Wasmex
  - components not yet supported
- Rustler
  - rust for elixir

---

# Lets try it!

---

# Is it actually useful tho?
## Err.. maybe?
### Let's do another demo before we decide

---

# Imaginary computers we know and love
- Java
- .NET CLR
  - Stack based (same as WASM)
- BEAM
  - Register based

---

# The competition

---

# WASI

---

<!-- footer: ![](full-color.png) -->
# Who am I?
- 25+ year Web App Developer
- 8+ yr Elixir dev
- Co-Founder of Launch Scout
- Creator of LiveState

---

# Bonus round!:
- WebAssembly!
- Until fairly recently, not super practical
  - Calling WebAssembly modules with anything other than numbers was a nightmare
- Things like Extism and WebAssembly Components eliminate this hurdle
- Writing event handlers in the language of your choice is now possible!

---

## Livestate [todo list](http://localhost:4004) reducer in Javascript (compiled to wasm)
```js
import { wrap } from "./wrap";

export const init = wrap(function() {
  return { todos: ["Hello", "WASM"]};
});

export const addTodo = wrap(function({ todo }, { todos }) {
  return { todos: [`${todo} from WASM!`, ...todos]};
});

```

---
