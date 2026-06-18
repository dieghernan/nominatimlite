# Errors

    Code
      reverse_geo_lite_sf(0, c(2, 3))
    Condition
      Error in `cap_coordinates()`:
      ! `lat` and `long` must have the same length.

---

    Code
      reverse_geo_lite_sf("a", "a")
    Condition
      Error in `cap_coordinates()`:
      ! `lat` and `long` must be numeric.

# Messages

    Code
      obj <- reverse_geo_lite_sf(0, 200)
    Message
      Longitude values outside [-180, 180] were restricted to that range.
      No results found for query: lat = 0, long = 180.

---

    Code
      obj <- reverse_geo_lite_sf(200, 200)
    Message
      Latitude values outside [-90, 90] were restricted to that range.
      Longitude values outside [-180, 180] were restricted to that range.
      No results found for query: lat = 90, long = 180.

# Returning empty query

    Code
      obj <- reverse_geo_lite_sf(89.999999, 179.9999)
    Message
      No results found for query: lat = 89.999999, long = 179.9999.

---

    Code
      obj_renamed <- reverse_geo_lite_sf(89.999999, 179.9999, address = "adddata")
    Message
      No results found for query: lat = 89.999999, long = 179.9999.

# Fail

    Code
      several <- reverse_geo_lite_sf(40.75728, -73.98, full_results = TRUE,
        nominatim_server = "https://api.jsonserver.io/")
    Message
      Cannot reach the API endpoint: https://api.jsonserver.io/reverse?lat=40.75728&lon=-73.98&format=geojson&addressdetails=1.

