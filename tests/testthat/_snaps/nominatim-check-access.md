# api_call() rejects unsupported cache formats before downloading

    Code
      api_call("https://example.com", ext = ".txt", quiet = TRUE)
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of ".json", ".geojson"

