defmodule Mcex.Mappings.Redis do
  defstruct [
    appendk: {Mcex.Modifier.Redis, :appendk},
    find: {Mcex.Modifier.Redis, :find},
    findv: {Mcex.Modifier.Redis, :findv},
    get: {Mcex.Modifier.Redis, :get},
    prependk: {Mcex.Modifier.Redis, :prependk},
    set: {Mcex.Modifier.Redis, :set}
  ]
end
