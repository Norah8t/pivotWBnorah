# pivotWBnorah

World Bank indicator files have one row per country and one column per year
(`X2000`, `X2001`, ... once read into R). **pivotWBnorah** reshapes them into
a long country-year data set — one row per country per year — so different
indicators can be merged on `iso` and `year`.

It was written for the CHL5233 armed conflict project, where the maternal,
infant, neonatal and under-5 mortality files are each reshaped and joined.

## Installation

```r
# install.packages("devtools")
devtools::install_github("Norah8t/pivotWBnorah")
```

## Usage

The package has one function, `clean_wb()`, and one example data set,
`maternal_mortality` (wide format, straight from the World Bank file).

```r
library(pivotWBnorah)

# Wide: one column per year
maternal_mortality[1:3, 1:5]

# Long: one row per country-year
mm_long <- clean_wb(maternal_mortality, varname = "maternal_mortality")
head(mm_long)
#> columns: iso, year, maternal_mortality
```

`data` can also be a path to the CSV, so a raw file is cleaned in one step:

```r
clean_wb("data/raw/infant_mortality.csv", varname = "infant_mortality")
```

Reshaping several indicators and merging them (as in the armed conflict
project):

```r
library(dplyr)
library(purrr)

files <- c(maternal_mortality = "maternal_mortality.csv",
           infant_mortality   = "infant_mortality.csv",
           neonatal_mortality = "neonatal_mortality.csv",
           under5_mortality   = "under5_mortality.csv")

wb_mortality <- imap(files, \(f, v) clean_wb(file.path("data", "raw", f), v)) |>
  reduce(full_join, by = c("iso", "year"))
```

See `?clean_wb` and `?maternal_mortality` for details.
