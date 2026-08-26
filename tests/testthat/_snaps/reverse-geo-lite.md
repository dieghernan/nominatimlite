# reverse_geo_lite() rejects nonnumeric and mismatched coordinates

    Code
      reverse_geo_lite(0, c(2, 3))
    Condition
      Error:
      ! `lat` and `long` must have the same length.

---

    Code
      reverse_geo_lite("a", "a")
    Condition
      Error:
      ! `lat` and `long` must be numeric.

# reverse_geo_lite() reports and clamps coordinates outside bounds

    Code
      out <- reverse_geo_lite(0, 200)
    Message
      Longitude values outside [-180, 180] were clamped to that range.
      No results were found for the query: lat = 0, long = 180.

---

    Code
      out <- reverse_geo_lite(200, 0)
    Message
      Latitude values outside [-90, 90] were clamped to that range.
      No results were found for the query: lat = 90, long = 0.

# reverse_geo_lite() returns a typed row when no address matches

    Code
      obj <- reverse_geo_lite(89.999999, 179.9999)
    Message
      No results were found for the query: lat = 89.999999, long = 179.9999.

---

    Code
      obj_renamed <- reverse_geo_lite(89.999999, 179.9999, address = "adddata")
    Message
      No results were found for the query: lat = 89.999999, long = 179.9999.

# reverse_geo_lite() returns a typed row after API failure

    Code
      several <- reverse_geo_lite(40.75728, -73.98, full_results = TRUE)
    Message
      Could not reach the API endpoint: https://nominatim.openstreetmap.org/reverse?lat=40.75728&lon=-73.98&format=jsonv2&addressdetails=1.

