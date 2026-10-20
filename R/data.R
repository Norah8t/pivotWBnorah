#' Maternal mortality ratio by country and year (World Bank, wide format)
#'
#' @description
#' Example data for [clean_wb()]: the maternal mortality file used in the
#' CHL5233 armed conflict project, kept in its original World Bank wide
#' layout (one row per country, one column per year) so that it can be used
#' to show how `clean_wb()` reshapes it to long format.
#'
#' @docType data
#' @format A data frame with 186 rows (one per country) and 21 variables:
#' * `iso`: ISO 3166-1 alpha-3 country code (e.g. `"CAN"`).
#' * `X2000`, `X2001`, ..., `X2019`: maternal mortality ratio (modelled
#'   estimate, maternal deaths per 100,000 live births) in each year from
#'   2000 to 2019. The names start with `X` because [utils::read.csv()]
#'   adds it to column names that begin with a number. Values for 2018
#'   and 2019 are all `NA` in this file, as are all years for Andorra
#'   (AND), Dominica (DMA) and the Marshall Islands (MHL).
#' @source World Bank, World Development Indicators, indicator
#'   SH.STA.MMRT (Maternal mortality ratio, modeled estimate, per 100,000
#'   live births). <https://data.worldbank.org/indicator/SH.STA.MMRT>
#' @seealso [clean_wb()]
#' @examples
#' dim(maternal_mortality)
#' maternal_mortality[1:3, 1:5]
"maternal_mortality"
