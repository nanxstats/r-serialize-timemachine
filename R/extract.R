#' Extract R installer to a directory
#'
#' @param installer R installer path
#' @param version Installer R version
#' @param dir_dist Output directory
#'
#' @note This function requires innoextract installed under Windows
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
