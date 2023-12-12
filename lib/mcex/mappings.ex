defmodule Mcex.Mappings do
  defstruct [
    base64: Mcex.Modifier.Base64,
    date: Mcex.Modifier.Date,
    getm: Mcex.Modifier.Getm,
    inline: Mcex.Modifier.Inline,
    rand: Mcex.Modifier.Random,
    select: Mcex.Modifier.Select,
    setm: Mcex.Modifier.Setm,
    sleep: Mcex.Modifier.Sleep,
    time: Mcex.Modifier.Time,
    trap: Mcex.Modifier.Trap,
    urljson: Mcex.Modifier.Urljson,
    uuid: Mcex.Modifier.Uuid
  ]
end
