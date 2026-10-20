## Code to prepare the `maternal_mortality` example data set.
##
## Run this once from the package root folder:
##   1. Copy maternal_mortality.csv from data/raw/ in your armed_conflict
##      project into this data-raw/ folder.
##   2. source("data-raw/maternal_mortality.R")
##
## It creates data/maternal_mortality.rda (what users get from
## `maternal_mortality`) and inst/extdata/maternal_mortality.csv (used to show
## that clean_wb() also accepts a file path).

maternal_mortality <- read.csv(file.path("data-raw", "maternal_mortality.csv"),
                               header = TRUE)

# Keep only the country code and the year columns (X2000, ..., X2019).
# The `indicator` column repeats the same label on every row, so it is
# dropped to keep the example small.
year_cols <- grep("^X[0-9]{4}$", names(maternal_mortality), value = TRUE)
maternal_mortality <- maternal_mortality[, c("iso", year_cols)]

# X2018 and X2019 are entirely NA in this file, so read.csv() reads them as
# logical; make every year column numeric so all years have the same type.
maternal_mortality[year_cols] <- lapply(maternal_mortality[year_cols],
                                        as.numeric)

# Saved as data/maternal_mortality.rda
usethis::use_data(maternal_mortality, overwrite = TRUE, compress = "xz")

# Same data as a CSV shipped with the package (inst/extdata/)
dir.create(file.path("inst", "extdata"), recursive = TRUE, showWarnings = FALSE)
write.csv(maternal_mortality,
          file.path("inst", "extdata", "maternal_mortality.csv"),
          row.names = FALSE)
