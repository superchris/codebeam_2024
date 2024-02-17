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

# Beyond Request/Response
### Why and how we should change the way we build web applications
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
## It's also better abstraction boundary
### And this is why it actually matters

---

# Compared to what?
- OTP processes
- HTTP services
- Docker containers

---

# Examples
- Create a temperature converter slider
  - dont wanna round trip to server each time
  - offline
- Create a form handler to drop stuff in a spreadsheet

---

# Runtimes
- Browsers
  - Standard APIs for loading and executing
  - integration with DOM (etc) is
- WASI (WebAssembly System Interface)
  - APIs for server side WASM
  - Inspired by POSIX

---

# Imaginary computers we know and love
- Java
- .NET CLR
  - Stack based (same as WASM)
- BEAM
  - Register based

---

# Java
- Started as browser technology
- Server side came later
  - And that's when it really took off
- Does anyone even remember applets?

---

# My prediction: WASM is going the same (ish) way
- Browser stuff is cool
- Server side is what matters

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

# The competition

---

# WASI
- WebAssembly System Interface
- APIs for server side WASM
- Currently at Preview 2

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

# Writing a WASM module from Elixir
The bad news and the good news

---

# Firefly (formerly Lumen)
- Extremely ambitious goal: port the BEAM to WASM
- Made some promising progress
- Heavily invested in by Dockyard (and others?)
- Not currently active
  - "Looking for a home"

---

# ORB
## A DSL for WebAssembly
- Less ambitious, but works!
- Under

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
