defmodule Mcex.Mappings do
  defstruct [
    base64: {Mcex.Modifier.Base64, :modify},
    date: {Mcex.Modifier.Date, :modify},
    getm: {Mcex.Modifier.Getm, :modify},
    inline: {Mcex.Modifier.Inline, :modify},
    rand: {Mcex.Modifier.Random, :modify},
    select: {Mcex.Modifier.Select, :modify},
    setm: {Mcex.Modifier.Setm, :modify},
    sleep: {Mcex.Modifier.Sleep, :modify},
    time: {Mcex.Modifier.Time, :modify},
    trap: {Mcex.Modifier.Trap, :modify},
    urljson: {Mcex.Modifier.Urljson, :modify},
    uuid: {Mcex.Modifier.Uuid, :modify}
  ]
end
