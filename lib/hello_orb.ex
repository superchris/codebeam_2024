defmodule HelloOrb do
  use Orb

  defw add(x: I32, y: I32), I32, do: x + y

end
