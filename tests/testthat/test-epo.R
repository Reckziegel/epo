x <- diff(log(EuStockMarkets))
x <- matrix(x, nrow = nrow(x), ncol = ncol(x))
colnames(x) <- colnames(EuStockMarkets)
s <- colMeans(x)

# Traditional Mean-Variance Analysis
simple_zero_shrinkage <- epo(x = x, signal = s, method = "simple", w = 0)
# 100% Shrinkage
simple_full_shrinkage <- epo(x = x, signal = s, method = "simple", w = 1)
# 50% Classical MVO and 50% Shrinkage
simple_half_way <- epo(x = x, signal = s, method = "simple", w = 0.5)

test_that("Simple EPO works", {

  expect_type(simple_zero_shrinkage, "double")
  expect_length(simple_zero_shrinkage, 4L)
  expect_equal(sum(simple_zero_shrinkage), 1L)

  expect_type(simple_full_shrinkage, "double")
  expect_length(simple_full_shrinkage, 4L)
  expect_equal(sum(simple_full_shrinkage), 1L)

  expect_type(simple_half_way, "double")
  expect_length(simple_half_way, 4L)
  expect_equal(sum(simple_half_way), 1L)

})


benchmark <- rep(0.25, 4) # 1/N Portfolio

# Traditional Mean-Variance Analysis
anchored_zero_shrinkage <- epo(x = x, signal = s, method = "anchored", w = 0.0, anchor = benchmark)
# 100% on the Anchor portfolio
anchored_full_shrinkage <- epo(x = x, signal = s, method = "anchored", w = 1.0, anchor = benchmark)
# Somewhere between the two worlds
anchored_half_way <- epo(x = x, signal = s, method = "anchored", w = 0.5, anchor = benchmark)


test_that("Anchored EPO works", {

  expect_type(anchored_zero_shrinkage, "double")
  expect_length(anchored_zero_shrinkage, 4L)
  expect_equal(sum(anchored_zero_shrinkage), 1L)

  expect_type(anchored_full_shrinkage, "double")
  expect_length(anchored_full_shrinkage, 4L)
  expect_equal(sum(anchored_full_shrinkage), 1L)

  expect_type(anchored_half_way, "double")
  expect_length(anchored_half_way, 4L)
  expect_equal(sum(anchored_half_way), 1L)

})


test_that("Simple and Anchored are equal on the extremes", {

  # Full shrinkage in EPO yields the reference allocation
  expect_equal(anchored_full_shrinkage, benchmark)

  # Zero shrinkage yields the MVO
  expect_equal(simple_zero_shrinkage, anchored_zero_shrinkage)

})

test_that("`epo` can handle with signals in which ncol() > 1", {

    expect_equal(anchored_zero_shrinkage,
                 epo(x = x, signal = t(s), method = "anchored", w = 0, anchor = benchmark))

})


test_that("`method only accepts `simple` or `anchored`", {

  expect_error(epo(x = x, signal = s, method = "some_new_type", w = 0))

})

test_that("`anchored` requires and 'anchor'", {

  expect_error(epo(x = x, signal = s, method = "anchored", w = 0))

})


# Methods -----------------------------------------------------------------

# tibble
x_tbl <- dplyr::as_tibble(x)
epo_tbl <- epo(x = x_tbl, signal = s, method = "anchored", w = 0.5, anchor = benchmark)

test_that("Anchored EPO works", {

  expect_type(epo_tbl, "double")
  expect_length(epo_tbl, 4L)
  expect_equal(sum(epo_tbl), 1L)

})

# xts
data <- stats::runif(100)
index <- seq(Sys.Date(), Sys.Date() + 24, "day")
# data xts
x_xts <- xts::xts(matrix(data, ncol = 4), order.by = index)

epo_xts <- epo(x = x_xts, signal = s, method = "anchored", w = 0.5, anchor = benchmark)

test_that("Anchored EPO works", {

  expect_type(epo_xts, "double")
  expect_length(epo_xts, 4L)
  expect_equal(sum(epo_xts), 1L)

})

