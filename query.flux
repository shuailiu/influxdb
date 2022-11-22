from(bucket:"mydb")
  |> range(start: -24h)
  |> filter(fn: (r) =>
    r._measurement == "mem" and
    r._field == "used" and
    r.host == "server2"
  )