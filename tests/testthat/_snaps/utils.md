# cap helpers report changes

    Code
      cap_coordinates("a", 1)
    Condition
      Error in `cap_coordinates()`:
      ! `lat` and `long` must be numeric.

---

    Code
      cap_coordinates(1, c(1, 2))
    Condition
      Error in `cap_coordinates()`:
      ! `lat` and `long` must have the same length.

---

    Code
      coords <- cap_coordinates(200, -200)
    Message
      Latitude values outside [-90, 90] were clamped to that range.
      Longitude values outside [-180, 180] were clamped to that range.

