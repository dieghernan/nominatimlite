# reverse_geo_lite_sf() rejects invalid coordinate inputs

    Code
      reverse_geo_lite_sf(0, c(2, 3))
    Condition
      Error:
      ! `lat` and `long` must have the same length.

---

    Code
      reverse_geo_lite_sf("a", "a")
    Condition
      Error:
      ! `lat` and `long` must be numeric.

# reverse_geo_lite_sf() reports coordinates clamped to bounds

    Code
      obj <- reverse_geo_lite_sf(0, 200)
    Message
      Longitude values outside [-180, 180] were clamped to that range.
      No results were found for the query: lat = 0, long = 180.

---

    Code
      obj <- reverse_geo_lite_sf(200, 200)
    Message
      Latitude values outside [-90, 90] were clamped to that range.
      Longitude values outside [-180, 180] were clamped to that range.
      No results were found for the query: lat = 90, long = 180.

# reverse_geo_lite_sf() returns empty geometry without a match

    Code
      obj <- reverse_geo_lite_sf(89.999999, 179.9999)
    Message
      No results were found for the query: lat = 89.999999, long = 179.9999.

---

    Code
      obj_renamed <- reverse_geo_lite_sf(89.999999, 179.9999, address = "adddata")
    Message
      No results were found for the query: lat = 89.999999, long = 179.9999.

# reverse_geo_lite_sf() returns empty geometry after API failure

    Code
      several <- reverse_geo_lite_sf(40.75728, -73.98, full_results = TRUE)
    Message
      Could not reach the API endpoint: https://nominatim.openstreetmap.org/reverse?lat=40.75728&lon=-73.98&format=geojson&addressdetails=1.

