defmodule Mcex.Mappings do
  alias Mcex.Modifier, as: X

  def standard do
    %{
      args: X.Args,
      base64: X.Base64,
      bufferv: X.BufferV,
      bv: X.BufferV,
      date: X.Date,
      debug: X.Debug,
      exec: X.Exec,
      findx: X.FindX,
      have: X.Have,
      if: X.If,
      inline: X.Inline,
      max: X.Max,
      min: X.Min,
      mods: X.Mods,
      padl: X.PadL,
      rand: X.Random,
      rest: X.Rest,
      round: X.Round,
      sleep: X.Sleep,
      splitc: X.SplitC,
      tee: X.Tee,
      time: X.Time,
      timeu: X.TimeU,
      trap: X.Trap,
      trunc: X.Truncate,
      uniq: X.Uniq,
      urid: X.UriD,
      urie: X.UriE,
      uuid: X.Uuid,
      wrap: X.Wrap
    }
  end

  def s, do: standard()
end
