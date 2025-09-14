defmodule Mcex.Mappings do
  defstruct [
    args: Mcex.Modifier.Args,
    base64: Mcex.Modifier.Base64,
    bufferv: Mcex.Modifier.BufferV,
    date: Mcex.Modifier.Date,
    debug: Mcex.Modifier.Debug,
    exec: Mcex.Modifier.Exec,
    findx: Mcex.Modifier.FindX,
    have: Mcex.Modifier.Have,
    if: Mcex.Modifier.If,
    inline: Mcex.Modifier.Inline,
    max: Mcex.Modifier.Max,
    min: Mcex.Modifier.Min,
    mods: Mcex.Modifier.Mods,
    padl: Mcex.Modifier.PadL,
    rand: Mcex.Modifier.Random,
    rest: Mcex.Modifier.Rest,
    round: Mcex.Modifier.Round,
    select: Mcex.Modifier.Select,
    sleep: Mcex.Modifier.Sleep,
    splitc: Mcex.Modifier.SplitC,
    tee: Mcex.Modifier.Tee,
    time: Mcex.Modifier.Time,
    timeu: Mcex.Modifier.TimeU,
    trap: Mcex.Modifier.Trap,
    trunc: Mcex.Modifier.Truncate,
    uniq: Mcex.Modifier.Uniq,
    urid: Mcex.Modifier.UriD,
    urie: Mcex.Modifier.UriE,
    uuid: Mcex.Modifier.Uuid,
    wrap: Mcex.Modifier.Wrap,

    # Aliases
    bv: Mcex.Modifier.BufferV
  ]
end
