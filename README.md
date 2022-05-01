# r-serialize-timemachine

Running serialization in all R releases since 1.9.1.
This project works on Windows only.

## Installing dependencies

Install the R packages used by the project with:

```r
# install.packages("remotes")
remotes::install_deps()
```

Install `innoextract` under Windows, for example, using Chocolatey:

```powershell
choco install innoextract
```

## Reproduce the results

```r
source("run.R")
```
