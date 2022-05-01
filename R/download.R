#' Download R installers
#'
#' @param base_url Base URL for CRAN mirror
#' @param dir_installer Directory to store the installers
download_r_installer <- function(base_url = "https://cran.rstudio.com/", dir_installer = "installer/") {
  # Scrape CRAN mirror to get available installer versions ---------------------
  html <- rvest::read_html(paste0(base_url, "bin/windows/base/old/"))
  link <- html |>
    rvest::html_elements("a") |>
    rvest::html_text2()
  version_txt <- link[grep(pattern = "^R\\W\\d", x = link)]
  version_num <- gsub(pattern = "R ", replacement = "", x = version_txt)

  # Remove some as <= 1.8.1 are shown as "corrupted"
  version_num <- rev(version_num)[-c(1:3)]
  k <- length(version_num)

  # Construct installer URL ----------------------------------------------------
  url_bin <- rep(NA, k)
  for (i in seq_len(k)) {
    # version >= 3.4.0 or <= 3.3.3 have different hosting locations
    url_bin_base <- if (is_geq(version_num[i], "3.4.0")) {
      paste0(base_url, "bin/windows/base/old/")
    } else {
      "https://cran-archive.r-project.org/bin/windows/base/old/"
    }

    # 1.6.2 <= version <= 2.1.1: x.y.z/rwx0yz.exe
    # 2.2.0 <= version <= 2.11.1: x.y.z/R-x.y.z-win32.exe
    # version >= 2.12.0: x.y.z/R-x.y.z-win.exe
    url_bin_slug <- if (is_geq(version_num[i], "1.6.2") & is_leq(version_num[i], "2.1.1")) {
      paste0(version_num[i], "/rw", gsub(pattern = "\\.", replacement = "", x = sub(pattern = "\\.", replacement = "0", version_num[i])), ".exe")
    } else if (is_geq(version_num[i], "2.2.0") & is_leq(version_num[i], "2.11.1")) {
      paste0(version_num[i], "/R-", version_num[i], "-win32.exe")
    } else if (is_geq(version_num[i], "2.12.0")) {
      paste0(version_num[i], "/R-", version_num[i], "-win.exe")
    }

    url_bin[i] <- paste0(url_bin_base, url_bin_slug)
  }

  # Download installers --------------------------------------------------------
  file_bin <- file.path(dir_installer, paste0("R-", version_num, ".exe"))
  for (i in seq_len(k)) {
    message("\nDownloading ", i, "/", k, ": R ", version_num[i])
    curl::curl_download(url_bin[i], destfile = file_bin[i], quiet = FALSE)
  }

  invisible(list("version_num" = version_num, "file_bin" = file_bin, "k" = k))
}
