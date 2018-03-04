
#' Catch Insensitive, Inconsiderate Writing
#'
#' Whether your own or someone else's writing, alex helps you find
#' gender favouring, polarising, race related, religion inconsiderate,
#' or other unequal phrasing.
#'
#' @param value If it is a connection object, then we read all
#'   lines from it with \code{readLines()} and then run \code{alex}
#'   on them. Otherwise if it is a character vector, we run \code{alex}
#'   on it. If \code{NULL}, then we run \code{alex} on all markdown
#'   (.Rmd and .md) files in the current working directory.
#' @return An object with S3 class \code{alex}. It's \code{messages}
#'   entry contains the suggestions for changes, see examples below.
#'
#' @export
#' @examples
#' x <- alex(c("The boogeyman wrote all changes to the **master server**.",
#'              "Thus, the slaves were read-only copies of master.",
#'              "But not to worry, he was a cripple."))
#' x
#' x$message

alex <- function(value = NULL) {

  if (inherits(value, "connection")) {
    filename <- summary(value)$description
    text <- paste(readLines(value), collapse = "\n")
    close(value)
    res <- ct$call("alex", text)$messages
    res$file <- filename

  } else if (is.character(value)) {
    res <- ct$call("alex", paste(value, collapse = "\n"))$messages
    res$file <- "<value>"

  } else if (is.null(value)) {
    files <- files_for_alex()
    res <- lapply(files, function(x) alex(file(x)))

  } else {
    stop("Unknown value for alex, must be a connection, string, or NULL")
  }

  class(res) <- c("alex", class(res))
  res
}


files_for_alex <- function() {
  rmd <- list.files(pattern = "\\.(Rmd|rmd)$")
  md <- list.files(pattern = "\\.md$")
  md <- setdiff(md, sub("\\.[rR]md$", ".md", rmd))
  c(rmd, md)
}

## TODO: use 'tab' for formatting, once it is fast enough

#' @method print alex
#' @export

print.alex <- function(x, ...) {

  ## List of files or single file?

  if (inherits(x[[1]], "alex")) {
    lapply(x, print.alex)

  } else {
    print_alex_file(x)
  }

  invisible(x)
}


print_alex_file <- function(x) {

  num_msg <- nrow(x) %||% 0
  num_err <- sum(x$fatal)
  num_war <- num_msg - num_err

  head <- paste0(
    if (num_msg == 0) "* " else "X ",
    if (x$file[1] == "") "<text>" else x$file[1], "  ",
    num_msg, " messages",
    " (", num_err, " errors, ", num_war, " warnings)"
  )
  cat(sep = "", head, "\n", rep("-", nchar(head)), "\n")

  if (!inherits(x, "data.frame")) return()

  msg <- c("warning", "error")[x$fatal + 1]
  w_name <- max(nchar(x$name))
  w_msg  <- max(nchar(msg))
  head_width <- w_name + w_msg + 2 + 2 + 4
  text_width <- getOption("width") - head_width

  for (i in seq_len(nrow(x))) {
    cat(
      " ",
      format(x[i, "name"], justify = "right", width = w_name),
      " ",
      format(msg[i], justify = "left", width = w_msg)
    )
    cat(
      sep = "",
      "  ",
      paste(
        strwrap(x[i, "reason"], width = text_width, exdent = head_width),
        collapse = "\n"
      ),
      "\n"
    )
  }
  cat("\n")
}


ct <- NULL

#' @importFrom V8 v8 JS

.onLoad <- function(libname, pkgname){
  # highlight.js assumes 'window' object
  ct <<- v8(c("global", "window"))
  libs <- list.files(
    system.file("js", package = pkgname),
    full.names = TRUE,
    pattern="*.js");
  lapply(sort(libs), function(path) ct$source(path) )
}
