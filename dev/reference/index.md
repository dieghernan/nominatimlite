# Package index

## Geocoding

Search addresses and structured queries to return coordinates.

- [`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md)
  : Address search API (free-form query)

- [`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md)
  :

  Address search API with [sf](https://CRAN.R-project.org/package=sf)
  output (free-form query)

- [`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md)
  : Address search API (structured query)

- [`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)
  :

  Address search API with [sf](https://CRAN.R-project.org/package=sf)
  output (structured query)

### Amenity lookup

Search OpenStreetMap amenities within a bounding box.

- [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md)
  : Geocode amenities

- [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md)
  :

  Geocode amenities with [sf](https://CRAN.R-project.org/package=sf)
  output

- [`osm_amenities`](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)
  : OpenStreetMap amenity database

### Address lookup

Retrieve address details for OSM node, way and relation identifiers.

- [`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md)
  : Address lookup API

- [`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md)
  :

  Address lookup API with [sf](https://CRAN.R-project.org/package=sf)
  output

## Reverse geocoding

Reverse geocode coordinates to return addresses and place information.

- [`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite.md)
  : Reverse geocoding API

- [`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)
  :

  Reverse geocoding API with [sf](https://CRAN.R-project.org/package=sf)
  output

## [sf](https://CRAN.R-project.org/package=sf) outputs

Return API results as [sf](https://CRAN.R-project.org/package=sf)
objects and convert bounding boxes to sf geometries.

- [`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/dev/reference/bbox_to_poly.md)
  :

  Coerce a bounding box to a
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) `POLYGON`
  object

- [`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md)
  :

  Address lookup API with [sf](https://CRAN.R-project.org/package=sf)
  output

- [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md)
  :

  Geocode amenities with [sf](https://CRAN.R-project.org/package=sf)
  output

- [`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md)
  :

  Address search API with [sf](https://CRAN.R-project.org/package=sf)
  output (free-form query)

- [`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)
  :

  Address search API with [sf](https://CRAN.R-project.org/package=sf)
  output (structured query)

- [`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)
  :

  Reverse geocoding API with [sf](https://CRAN.R-project.org/package=sf)
  output

## API management

Check API availability and manage request behavior.

- [`nominatim_check_access()`](https://dieghernan.github.io/nominatimlite/dev/reference/nominatim_check_access.md)
  : Check access to Nominatim API

## Datasets

Data shipped with the package.

- [`osm_amenities`](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)
  : OpenStreetMap amenity database

## About the package

- [`nominatimlite`](https://dieghernan.github.io/nominatimlite/dev/reference/nominatimlite-package.md)
  [`nominatimlite-package`](https://dieghernan.github.io/nominatimlite/dev/reference/nominatimlite-package.md)
  : nominatimlite: Interface to the 'Nominatim' API
