# A small made-up data set in World Bank wide format: 2 countries x 3 years,
# plus a country-name column that clean_wb() should drop and one missing value.
toy <- data.frame(
  Country.Name = c("Canada", "Saudi Arabia"),
  iso          = c("CAN", "SAU"),
  X2000        = c(9.5, 20.1),
  X2001        = c(9.8, 18.7),
  X2002        = c(10.2, NA)
)

test_that("output is long: one row per country-year", {
  out <- clean_wb(toy, "mmr")
  expect_equal(nrow(out), 2 * 3)
  expect_named(out, c("iso", "year", "mmr"))
})

test_that("year is numeric with the X prefix removed", {
  out <- clean_wb(toy, "mmr")
  expect_type(out$year, "double")
  expect_equal(sort(unique(out$year)), c(2000, 2001, 2002))
})

test_that("values end up in the right country-year", {
  out <- clean_wb(toy, "mmr")
  expect_equal(out$mmr[out$iso == "SAU" & out$year == 2001], 18.7)
  expect_equal(out$mmr[out$iso == "CAN" & out$year == 2002], 10.2)
})

test_that("missing values are kept as NA, not dropped", {
  out <- clean_wb(toy, "mmr")
  expect_equal(sum(is.na(out$mmr)), 1)
  expect_true(is.na(out$mmr[out$iso == "SAU" & out$year == 2002]))
})

test_that("varname sets the name of the value column", {
  out <- clean_wb(toy, "infant_mortality")
  expect_true("infant_mortality" %in% names(out))
  expect_false("mmr" %in% names(out))
})

test_that("a row-number column called X is not treated as a year", {
  toy_x <- cbind(X = 1:2, toy)
  expect_equal(clean_wb(toy_x, "mmr"), clean_wb(toy, "mmr"))
})

test_that("year columns without the X prefix also work", {
  toy_noX <- toy
  names(toy_noX) <- sub("^X", "", names(toy_noX))
  expect_equal(clean_wb(toy_noX, "mmr"), clean_wb(toy, "mmr"))
})

test_that("a path to a CSV file gives the same result as a data frame", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  utils::write.csv(toy, tmp, row.names = FALSE)
  expect_equal(clean_wb(tmp, "mmr"), clean_wb(toy, "mmr"))
})

test_that("bad inputs give informative errors", {
  expect_error(clean_wb(list(a = 1), "mmr"), "data frame")
  expect_error(clean_wb("no_such_file.csv", "mmr"), "File not found")
  expect_error(clean_wb(toy[, names(toy) != "iso"], "mmr"), "iso")
  expect_error(clean_wb(toy[, c("Country.Name", "iso")], "mmr"),
               "No year columns")
  expect_error(clean_wb(toy, c("a", "b")), "single")
  expect_error(clean_wb(toy, 5), "single")
  expect_error(clean_wb(toy, "year"), "cannot be")
})

test_that("works on the maternal_mortality example data", {
  n_years <- sum(grepl("^X[0-9]{4}$", names(maternal_mortality)))
  out <- clean_wb(maternal_mortality, "maternal_mortality")
  expect_equal(nrow(out), nrow(maternal_mortality) * n_years)
  expect_named(out, c("iso", "year", "maternal_mortality"))
  expect_setequal(unique(out$iso), unique(maternal_mortality$iso))
})
