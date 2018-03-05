
#' Catch Insensitive, Inconsiderate Writing
#'
#' Whether your own or someone else's writing, alex helps you find
#' gender favouring, polarising, race related, religion inconsiderate,
#' or other unequal phrasing.
#'
#' @param text If it is a connection object, then we read all
#'   lines from it with \code{readLines()} and then run \code{alex}
#'   on them. Otherwise if it is a character vector, we run \code{alex}
#'   on it. If \code{NULL}, then we run \code{alex} on all markdown
#'   (.Rmd and .md) files in the current working directory.
#' @return An object with S3 class \code{alex}, which is also a data frame.
#'
#' @export
#' @examples
#' x <- alex(c("The boogeyman wrote all changes to the **master server**.",
#'              "Thus, the slaves were read-only copies of master.",
#'              "But not to worry, he was a cripple."))
#' x

alex <- function(text = NULL) {
  if (is.null(text)) return(alex_files(md_files()))

  if (inherits(text, "connection")) {
    con <- text
    text <- readLines(con)
    close(con)
  }

  input <- paste(text, collapse = "\n")

  ct$assign("input", input)
  ct$eval("output = alex(input);")
  res <- ct$get("output", simplifyVector = FALSE)$messages

  res <- format_alex_result(res)
  class(res) <- c("alex", class(res))
  res
}

#' @rdname alex
#' @param files Files to check.
#' @export

alex_files <- function(files) {
  res <- lapply(files, function(x) alex(file(x)))
  for (i in seq_along(res)) {
    if (nrow(res[[i]])) res[[i]]$file <- files[i]
  }
  res <- do.call(rbind, res)
  class(res) <- c("alex", class(res))
  attr(res, "files") <- files
  res
}

md_files <- function() {
  rmd <- list.files(pattern = "\\.(Rmd|rmd)$")
  md <- list.files(pattern = "\\.md$")
  md <- setdiff(md, sub("\\.[rR]md$", ".md", rmd))
  c(rmd, md)
}

format_alex_result <- function(res) {
  res <- data.frame(
    stringsAsFactors = FALSE,
    file = if (length(res)) "<object>" else character(),
    message = map_chr(res, "[[", "message"),
    start_line = map_int(res, function(x) x$location$start$line),
    start_column = map_int(res, function(x) x$location$start$column),
    end_line = map_int(res, function(x) x$location$end$line),
    end_column = map_int(res, function(x) x$location$end$column),
    source = map_chr(res, "[[", "source"),
    rule_id = map_chr(res, "[[", "ruleId"),
    fatal = map_lgl(res, "[[", "fatal"),
    profanity_severity =
      map_int(res, function(x) x$profanitySeverity %||% NA_integer_)
  )
  attr(res, "files") <- "<object>"
  res
}


#' @export

print.alex <- function(x, ...) {
  files <- attr(x, "files")
  for (f in files) print_alex_file(x, f)
  invisible(x)
}


print_alex_file <- function(x, file) {

  x <- x[x$file == file, ]

  num_msg <- nrow(x) %||% 0
  num_err <- sum(x$fatal)
  num_war <- num_msg - num_err

  head <- paste0(
    if (num_msg == 0) "* " else "X ",
    file, "  ",
    num_msg, " messages",
    " (", num_err, " errors, ", num_war, " warnings)"
  )
  cat(sep = "", head, "\n", rep("-", nchar(head)), "\n")

  msg <- c("warning", "error")[x$fatal + 1]
  pos <- paste0(
    x$start_line, ":", x$start_column, "-",
    x$end_line, ":", x$end_column)
  w_name <- max(nchar(pos), 0)
  w_msg  <- max(nchar(msg), 0)
  head_width <- w_name + w_msg + 2 + 2 + 4
  text_width <- getOption("width") - head_width

  for (i in seq_len(nrow(x))) {
    cat(
      " ",
      format(pos[i], justify = "right", width = w_name),
      " ",
      format(msg[i], justify = "left", width = w_msg)
    )
    cat(
      sep = "",
      "  ",
      paste(
        strwrap(x$message[i], width = text_width, exdent = head_width),
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
