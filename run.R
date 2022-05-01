source("R/utils.R")
source("R/download.R")
source("R/extract.R")
source("R/serialize.R")

installer <- download_r_installer()

for (i in seq_len(installer$k)) {
  message("\nRunning ", i, "/", installer$k, ": R ", installer$version_num[i])
  serialize_versioned(installer$file_bin[i], version = installer$version_num[i])
}
