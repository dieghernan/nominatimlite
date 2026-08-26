# bbox_to_poly() rejects incomplete bounding boxes

    Code
      bbox_to_poly()
    Condition
      Error:
      ! Provide `bbox` or non-missing values for `xmin`, `ymin`, `xmax` and `ymax`.

---

    Code
      bbox_to_poly(1)
    Condition
      Error:
      ! `bbox` must contain exactly four elements, but the provided value has 1.

---

    Code
      bbox_to_poly(xmin = 1)
    Condition
      Error:
      ! Provide `bbox` or non-missing values for `xmin`, `ymin`, `xmax` and `ymax`.

