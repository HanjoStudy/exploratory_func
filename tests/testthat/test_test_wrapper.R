context("tests for wrappers of tests")

test_df <- data.frame(
  cat=rep(c("cat1", "cat2"), 20),
  dim = sort(rep(paste0("dim", seq(4)), 5)),
  dim_na=c(paste0("dim", seq(10)), paste0("dim", seq(10)+3)))

test_df$list_c <- as.list(seq(20))

test_df[["with space"]] <- seq(20)

test_that("test two sample t-test", {
  result <- test_df %>%
    dplyr::group_by(dim) %>%
    do_t.test(`with space`, cat)
  expect_equal(ncol(result), 11)
})

test_that("test two sample t-test more than 2 levels", {
  expect_error({
    result <- test_df %>%
      dplyr::group_by(dim) %>%
      do_t.test(`with space`, dim_na)
  })
})

test_that("test two sample t-test less than 2 levels", {
  expect_error({
    result <- test_df %>%
      dplyr::group_by(dim) %>%
      do_t.test(`with space`, dim)
  })
})

test_that("test one sample t-test", {
  result <- test_df %>%
    dplyr::group_by(dim) %>%
    do_t.test("with space", mu=3)
  expect_equal(result[result[["dim"]]=="dim1", "p.value"][[1]], 1)
})

test_that("test t-test with 3 groups", {
  data <- data.frame(val = seq(12), group = rep(c(1,2,3), each = 4))
  expect_error({
    result <- data %>%
      do_t.test(val, group)
  }, "Group Column has to have 2 unique values")
})

test_that("test f-test", {
  result <- test_df %>%
    dplyr::group_by(dim) %>%
    do_var.test(`with space`, cat)
  expect_equal(ncol(result), 10)
})

test_that("test f-test with 3 groups", {
  data <- data.frame(val = seq(12), group = rep(c(1,2,3), each = 4))
  expect_error({
    result <- data %>%
      do_var.test(val, group)
  }, "Group Column has to have 2 unique values")
})

test_that("test chisq.test with one column", {
  test_df <- data.frame(
    group = rep(letters[1:2], each = 500),
    cat1 = letters[round(runif(1000)*5)+1],
    cat2 = letters[round(runif(1000)*3)+1]
  ) %>%
    dplyr::group_by(group, cat1, cat2) %>%
    dplyr::summarize(count = n()) %>%
    dplyr::group_by(group)

  ret <- test_df %>%
    do_chisq.test(count)

  expect_equal(nrow(ret), 2)

})

test_that("test chisq.test with select argument", {
  test_df <- data.frame(
    group = rep(letters[1:2], each = 500),
    cat1 = letters[round(runif(1000)*5)+1],
    cat2 = letters[round(runif(1000)*3)+1]
  ) %>%
    dplyr::group_by(group, cat1, cat2) %>%
    dplyr::summarize(count = n()) %>%
    tidyr::spread(cat2, count) %>%
    dplyr::group_by(group)

  ret <- test_df %>%
    do_chisq.test(-cat1)

  expect_equal(nrow(ret), 2)

})

test_that("test chisq.test with p column", {
  test_df <- structure(
    list(
      clarity = c("IF", "VS1", "VS2", "VVS1", "VVS2"),
      GIA = c(6, 61, 36, 15, 33),
      HRD = c(4, 13, 15, 23, 24),
      IGI = c(34, 7, 2, 14, 21)),
    .Names = c("clarity", "GIA", "HRD", "IGI"),
    class = "data.frame",
    row.names = c(NA,-5L)) %>%
    dplyr::mutate(p = seq(5))

  ret <- test_df %>%
    do_chisq.test(GIA, p = p)
  expect_equal(nrow(ret), 1)

  p_from_outside <- seq(5)

  ret2 <- test_df %>%
    do_chisq.test(IGI, p = p_from_outside)
  expect_equal(nrow(ret), 1)

  ret3 <- test_df %>%
    do_chisq.test(IGI, p = c(1, 2, 3, 4, 5))
  expect_equal(nrow(ret), 1)

})
