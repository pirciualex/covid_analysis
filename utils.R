source_dir <- function(path, recursive = FALSE) {
  if (!dir.exists(path)) {
    warning(paste(path, " is not a valid path!"))
    return(NULL)
  }
  
  env <- parent.frame()
  files <- list.files(path = path, pattern = ".*\\.R", all.files = FALSE, full.names = TRUE, recursive = recursive)
  for (fl in files) {
    tryCatch({
      source(fl, local = env)
      cat(fl, " is sourced.")
    }, error = function(cond) {
      message("Failed to load the file: ", fl, ".")
      message(cond)
    })
  }
}