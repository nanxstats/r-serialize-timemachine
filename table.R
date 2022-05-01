rds <- stringr::str_sort(fs::dir_ls("output/"), numeric = TRUE) # Natural sorting
version <- gsub(pattern = "R-|.rds", replacement = "", x = fs::path_file(rds))

get_file_size <- function(file) {
  file.info(file)$size
}

readbin_to_char <- function(path) {
  as.character(readBin(path, what = "raw", n = get_file_size(path)))
}

k <- length(version)
hex <- rep(NA, k)
for (i in seq_len(k)) hex[i] <- paste(readbin_to_char(rds[i]), collapse = " ")
df <- data.frame("version" = version, "hex" = hex)

htmltools::browsable(
  htmltools::HTML(
    knitr::kable(
      df,
      format = "html",
      col.names = c("R Version", "Hex value of serialized \"ABCDEF\"")
    )
  )
)
