# Errors

    Code
      reverse_geo_lite(0, c(2, 3))
    Condition
      Error in `cap_coordinates()`:
      ! `lat` and `long` must have the same length.

---

    Code
      reverse_geo_lite("a", "a")
    Condition
      Error in `cap_coordinates()`:
      ! `lat` and `long` must be numeric.

# Messages

    Code
      out <- reverse_geo_lite(0, 200)
    Message
      Longitude values outside [-180, 180] were clamped to that range.
      No results were found for query: lat = 0, long = 180.

---

    Code
      out <- reverse_geo_lite(200, 0)
    Message
      Latitude values outside [-90, 90] were clamped to that range.
      No results were found for query: lat = 90, long = 0.

# Returning empty query

    Code
      obj <- reverse_geo_lite(89.999999, 179.9999)
    Message
      No results were found for query: lat = 89.999999, long = 179.9999.

---

    Code
      obj_renamed <- reverse_geo_lite(89.999999, 179.9999, address = "adddata")
    Message
      No results were found for query: lat = 89.999999, long = 179.9999.

# Fail

    Code
      several <- reverse_geo_lite(40.75728, -73.98, full_results = TRUE,
        nominatim_server = "https://api.jsonserver.io/")
    Message
      Could not reach the API endpoint: https://api.jsonserver.io/reverse?lat=40.75728&lon=-73.98&format=jsonv2&addressdetails=1.

