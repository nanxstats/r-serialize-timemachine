#' Extract R installer to a directory
#'
#' @param installer R installer path
#' @param version Installer R version
#' @param dir_dist Output directory
#'
#' @note This requires innoextract installed under Windows
#' For example, using Chocolatey: `choco install innoextract`
extract_r_installer <- function(installer, version, dir_dist = "dist/") {
  output <- normalizePath(file.path(dir_dist, paste0("R-", version)), mustWork = FALSE)
  system(paste(
    "innoextract",
    normalizePath(installer, mustWork = TRUE),
    "--output-dir", output
  ),
  wait = TRUE, ignore.stdout = TRUE, ignore.stderr = TRUE, invisible = TRUE
  )
  invisible(output)
}

#' Extract R binary, run payload, and clean up
#'
#' @param installer R installer path
#' @param version Installer R version
#' @param dir_output RDS file output directory
#' @param ... Other arguments for `extract_r_installer()`
serialize_versioned <- function(installer, version, dir_output = "output/", ...) {
  # Prepare payload files ------------------------------------------------------
  path_rds <- normalizePath(dir_output, winslash = "/")

  # R >= 2.4.0 switched the default to `compress = TRUE` so set it to FALSE here
  payload_nodot <- paste0('saveRDS("ABCDEF", compress = FALSE, file = paste(', "\"", path_rds, '/R-", paste(R.version$major, R.version$minor, sep = "."), ".rds", sep = ""))')
  payload_dot <- paste0('.saveRDS("ABCDEF", compress = FALSE, file = paste(', "\"", path_rds, '/R-", paste(R.version$major, R.version$minor, sep = "."), ".rds", sep = ""))')

  writeLines(payload_dot, "payload-dot.R")
  writeLines(payload_nodot, "payload-nodot.R")

  # Extract R binaries from installer ------------------------------------------
  output <- extract_r_installer(installer, version = version, ...)

  # Construct and run command line calls ---------------------------------------

  # Only R >= 2.5.0 versions have Rscript.exe. Use Rterm.exe or Rcmd.exe before that.
  rcmd <- if (is_geq(version, "2.5.0")) {
    paste(normalizePath(file.path(output, "app/bin/Rscript.exe")), "--vanilla")
  } else {
    paste(normalizePath(file.path(output, "app/bin/R.exe")), "CMD BATCH --no-restore --no-save")
  }

  # Only R >= 2.13.0 versions have saveRDS(). Use .saveRDS() before that.
  payload <- if (is_geq(version, "2.13.0")) {
    normalizePath("payload-nodot.R")
  } else {
    normalizePath("payload-dot.R")
  }

  invisible(system(paste(rcmd, payload)))

  # Clean up -------------------------------------------------------------------
  fs::dir_delete(output)
}
