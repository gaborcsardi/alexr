
`%||%` <- function(l, r) {
  if (!is.null(l)) l else r
}

map_chr <- function(.x, .f, ...) {
  vapply(.x, .f, character(1), ...)
}

map_lgl <- function(.x, .f, ...) {
  vapply(.x, .f, logical(1), ...)
}

map_int <- function(.x, .f, ...) {
  vapply(.x, .f, integer(1), ...)
}
