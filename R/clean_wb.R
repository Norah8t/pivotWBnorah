#' Reshape a World Bank indicator data set from wide to long format
#'
#' @description
#' World Bank indicator files have one row per country and one column per
#' year. When such a file is read with [utils::read.csv()], the year columns
#' are renamed `X2000`, `X2001`, ... because R names cannot start with a
#' number. `clean_wb()` turns this wide layout into a long country-year data
#' set (one row per country per year), strips the `X` from the year, and
#' names the value column whatever you choose, so several indicators can be
#' merged on `iso` and `year`.
#'
#' @param data A data frame in World Bank wide format, **or** a path to a CSV
#'   file in that format. It must contain an `iso` column (country code) and
#'   one column per year, named like `X2000` (or `2000`). Any other columns,
#'   such as a country name, are dropped.
#' @param varname A single character string: the name to give the column
#'   holding the indicator values in the output (e.g. `"maternal_mortality"`).
#'   It cannot be `"iso"` or `"year"`.
#'
#' @return A tibble with one row per country-year and three columns:
#'   \describe{
#'     \item{iso}{country code, copied from `data`}
#'     \item{year}{numeric year}
#'     \item{`varname`}{the indicator value for that country and year
#'       (missing values are kept as `NA`)}
#'   }
#'
#' @examples
#' # The example data are in World Bank wide format: one column per year
#' maternal_mortality[1:3, 1:5]
#'
#' # Reshape to one row per country-year
#' mm_long <- clean_wb(maternal_mortality, varname = "maternal_mortality")
#' head(mm_long)
#'
#' # The long format makes by-year summaries easy, e.g. the median maternal
#' # mortality ratio across countries in each year
#' aggregate(maternal_mortality ~ year, data = mm_long, FUN = median)
#'
#' # A path to a CSV file works too, so the raw World Bank file can be
#' # cleaned in one step
#' path <- system.file("extdata", "maternal_mortality.csv",
#'                     package = "pivotWBnorah")
#' head(clean_wb(path, varname = "maternal_mortality"))
#'
#' @export
clean_wb <- function(data, varname) {
  # --- 1. Accept a file path as well as a data frame -----------------------
  if (is.character(data) && length(data) == 1) {
    if (!file.exists(data)) {
      stop("File not found: ", data, call. = FALSE)
    }
    data <- utils::read.csv(data, header = TRUE)
  }

  # --- 2. Check the inputs so errors are informative ----------------------
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame or the path to a CSV file.",
         call. = FALSE)
  }
  if (!is.character(varname) || length(varname) != 1 ||
      is.na(varname) || varname == "") {
    stop("`varname` must be a single, non-empty character string.",
         call. = FALSE)
  }
  if (varname %in% c("iso", "year")) {
    stop("`varname` cannot be \"iso\" or \"year\"; those names are used ",
         "for the key columns.", call. = FALSE)
  }
  if (!"iso" %in% names(data)) {
    stop("`data` must contain a column named `iso` (the country code).",
         call. = FALSE)
  }

  # Year columns are exactly four digits, optionally preceded by "X".
  # This is stricter than starts_with("X"), which would also catch a
  # row-number column named "X" left behind by write.csv().
  year_cols <- grep("^X?[0-9]{4}$", names(data), value = TRUE)
  if (length(year_cols) == 0) {
    stop("No year columns found. Year columns should be named like ",
         "`X2000` or `2000`.", call. = FALSE)
  }

  # --- 3. Reshape: one row per country-year --------------------------------
  out <- data |>
    tidyr::pivot_longer(cols = tidyselect::all_of(year_cols),
                        names_to = "year",
                        names_prefix = "X",      # "X2000" -> "2000"
                        values_to = varname) |>  # user-chosen column name
    dplyr::select(tidyselect::all_of(c("iso", "year", varname)))

  # year comes out of the column names as text; make it numeric
  out$year <- as.numeric(out$year)

  out
}
