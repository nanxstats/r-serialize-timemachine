# Version number comparison utilities
is_leq <- function(x, y) {
  z <- compareVersion(x, y)
  z == 0 | z == -1
}

is_geq <- function(x, y) {
  z <- compareVersion(x, y)
  z == 0 | z == 1
}
