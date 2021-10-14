defmodule Mcex.Mappings do
  defstruct [
    base64: {Mcex.Modifier.Base64, :modify},
    date: {Mcex.Modifier.Date, :modify},
    inline: {Mcex.Modifier.Inline, :modify},
    rand: {Mcex.Modifier.Random, :modify},
    setm: {Mcex.Modifier.Setm, :modify},
    getm: {Mcex.Modifier.Getm, :modify},
    sleep: {Mcex.Modifier.Sleep, :modify},
    time: {Mcex.Modifier.Time, :modify},
    urlalt: {Mcex.Modifier.Urlalt, :modify},
    urljs: {Mcex.Modifier.Urljs, :modify},
    urljson: {Mcex.Modifier.Urljson, :modify},
    uuid: {Mcex.Modifier.Uuid, :modify}
  ]
end
