context("test build_xgboost")

test_that("test build_xgboost with na.omit", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", NA, "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["w"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["isaa"]] <- test_data$CARRIER == "AA"

  model_ret <- build_model(test_data, model_func = xgboost_binary, formula = isaa ~ . - w - 1, nrounds = 5, weight = log(w), eval_metric = "auc", na.action = na.omit, sparse = FALSE)
  prediction_ret <- prediction_binary(model_ret)
  expect_true(any(prediction_ret$predicted_label))
  expect_true(any(!prediction_ret$predicted_label))
})

test_that("test build_xgboost prediction with optimized threshold", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", NA, "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["w"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["isaa"]] <- test_data$CARRIER == "AA"

  model_ret <- build_model(
    test_data,
    model_func = xgboost_binary,
    formula = isaa ~ . - w - 1,
    nrounds = 5,
    weight = log(w),
    na.action = na.omit,
    sparse = FALSE,
    eval_metric = "auc"
  )

  prediction_ret <- prediction_binary(model_ret)
  expect_true(any(prediction_ret$predicted_label))
  expect_true(any(!prediction_ret$predicted_label))
})

test_that("test build_xgboost prediction with optimized threshold", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", NA, "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["w"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["isaa"]] <- test_data$CARRIER == "AA"

  model_ret <- build_model(
    test_data,
    model_func = xgboost_binary,
    formula = isaa ~ . - w - 1,
    nrounds = 5,
    weight = log(w),
    eval_metric = "auc",
    na.action = na.omit,
    sparse = FALSE
  )
  prediction_ret <- prediction_binary(model_ret)
  expect_true(any(prediction_ret$predicted_label))
  expect_true(any(!prediction_ret$predicted_label))
})

test_that("test xgboost_reg with not clean names", {
  test_data <- data.frame(
    label = rep(seq(3) * 5, 100),
    num1 =  rep(seq(3), 100) + runif(100),
    num2 = rep(seq(3), 100) + runif(100)
  )
  colnames(test_data) <- c("label 1", "num-1", "Num 2")
  model_ret <- build_model(
    test_data,
    model_func = xgboost_reg,
    formula = `label 1` ~ .,
    nrounds = 5,
    na.action = na.omit
    )
  prediction_ret <- prediction(model_ret)
  expect_true(all(prediction_ret$predicted_label %in% c(5, 10, 15)))
})

test_that("test xgboost_reg with add_prediction", {
  train_data <- data.frame(
    label = rep(seq(3) * 5, 100),
    num1 =  rep(seq(3), 100) + runif(100),
    num2 = rep(seq(3), 100) + runif(100)
  )

  test_data <- data.frame(
    label = rep(seq(3) * 5, 100),
    num1 =  rep(seq(3), 100) + runif(100),
    num2 = rep(seq(3), 100) + runif(100)
  )
  colnames(train_data) <- c("label 1", "num-1", "Num 2")
  colnames(test_data) <- colnames(train_data)
  model_ret <- build_model(train_data, model_func = xgboost_reg, formula = `label 1` ~ ., nrounds = 5)
  prediction_ret <- add_prediction(test_data, model_df = model_ret)
  expect_true(all(prediction_ret$predicted_label %in% c(5, 10, 15)))
})

test_that("test xgboost_multi with numeric target", {
  test_data <- data.frame(
    label = rep(seq(3) * 5, 100),
    num1 =  rep(seq(3), 100) + runif(100),
    num2 = rep(seq(3), 100) + runif(100)
  )
  model_ret <- build_model(test_data, model_func = xgboost_multi, formula = label ~ ., nrounds = 5)
  prediction_ret <- prediction(model_ret)
  expect_true(all(prediction_ret$predicted_label %in% c(5, 10, 15)))
})

test_that("test build_xgboost", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))

  test_data[["weight"]] <- seq(nrow(test_data))
  model_ret <- build_model(
    test_data,
    model_func = xgboost_binary,
    formula = CANCELLED ~ DISTANCE,
    nrounds = 5,
    eval_metric = "auc",
    verbose = 0
    )
  coef_ret <- model_coef(model_ret)
  expect_equal(ncol(model_ret), 4)
})

test_that("test build_xgboost with weight", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))

  test_data[["weight"]] <- seq(nrow(test_data))
  model_ret <- build_model(
    test_data,
    model_func = xgboost_binary,
    formula = CANCELLED ~ DISTANCE,
    nrounds = 5,
    output_type = "logistic",
    eval_metric = "auc")
  coef_ret <- model_coef(model_ret)
  expect_equal(ncol(model_ret), 4)
})

test_that("test build_xgboost with weight", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- seq(nrow(test_data))
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  model_ret <- build_model(test_data, model_func = xgboost_binary, formula = IS_AA ~ DISTANCE, nrounds = 5, booster = "dart", eval_metric = "auc", output_type = "logitraw", weight = log(weight))
  coef_ret <- model_coef(model_ret)
  stats_ret <- model_stats(model_ret)
  prediction_ret <- prediction_binary(model_ret)
  expect_true(is.logical(prediction_ret$predicted_label))
  expect_equal(ncol(model_ret), 4)
})

test_that("test build_xgboost reg", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data) -1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  model_ret <- build_model(
    test_data,
    model_func = xgboost_reg,
    formula = IS_AA ~ DISTANCE,
    nrounds = 5,
    weight = log(weight),
    verbose = 1,
    booster = "dart",
    sparse = FALSE
  )
  stats_ret <- model_stats(model_ret)
  expect_equal(ncol(model_ret), 4)
})

test_that("test build_xgboost with dot", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  model_ret <- build_model(
    test_data,
    model_func = xgboost_binary,
    formula = IS_AA ~ .,
    nrounds = 5,
    eval_metric = "auc",
    sparse = FALSE
    )
  prediction_ret <- prediction_binary(model_ret)
  expect_equal(ncol(prediction_ret), ncol(test_data) + 2)
})

test_that("test build_xgboost with multi char", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  model_ret <- build_model(
    test_data,
    model_func = xgboost_multi,
    formula = CARRIER ~ .,
    nrounds = 5,
    output_type = "softmax",
    verbose = 0,
    sparse = FALSE
    )
  prediction_ret <- prediction(model_ret)
  # TODO: This returns factor by now because of build_model behaviour but should return character
  # expect_true(is.character(prediction_ret$predicted_value))
})

test_that("test build_xgboost with multi", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  test_data[["CARRIER"]] <- as.factor(test_data[["CARRIER"]])
  model_ret <- build_model(
    test_data,
    model_func = xgboost_multi,
    formula = CARRIER ~ .,
    nrounds = 5,
    verbose = 0,
    sparse = FALSE
    )
  prediction_ret <- prediction(model_ret)
  # expect_true(is.factor(prediction_ret$predicted_value))
  expect_true(!any(is.na(prediction_ret$predicted_value)))
})

test_that("test build_xgboost with multi softprob", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  test_data[["CARRIER"]] <- as.factor(test_data[["CARRIER"]])
  model_ret <- build_model(
    test_data,
    model_func = xgboost_multi,
    formula = CARRIER ~ .,
    nrounds = 5,
    verbose = 0,
    sparse = FALSE
    )
  prediction_ret <- prediction(model_ret)
  prob <- prediction_ret$predicted_probability
  expect_true(all(prob[!is.na(prob)] > 0))
  expect_true(length(unique(prediction_ret$predicted_label)) > 1)
})

test_that("test build_xgboost with linear booster", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  model_ret <- build_model(test_data, model_func = xgboost_reg, formula = DISTANCE ~ CANCELLED, nrounds = 5, booster = "gblinear", eval_metric = "map")
  coef_ret <- model_coef(model_ret)
  stats_ret <- model_stats(model_ret)
  expect_equal(nrow(stats_ret), 5)
})

test_that("test build_xgboost with linear booster", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  expect_error({
    model_ret <- build_model(test_data, model_func = xgboost_binary, formula = CANCELLED ~ DISTANCE, nrounds = 5, booster = "gblinear")
  }, "The target only contains positive or negative values")
})

test_that("test build_xgboost prediction with optimized threshold", {
  test_data <- structure(
    list(
      CANCELLED = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0),
      `Carrier Name` = c("Delta Air Lines", "American Eagle", "American Airlines", "Southwest Airlines", "SkyWest Airlines", "Southwest Airlines", "Southwest Airlines", "Delta Air Lines", "Southwest Airlines", "Atlantic Southeast Airlines", "American Airlines", "Southwest Airlines", "US Airways", "US Airways", "Delta Air Lines", "Atlantic Southeast Airlines", NA, "Atlantic Southeast Airlines", "Delta Air Lines", "Delta Air Lines"),
      CARRIER = c("DL", "MQ", "AA", "DL", "MQ", "AA", "DL", "DL", "MQ", "AA", "AA", "WN", "US", "US", "DL", "EV", "9E", "EV", "DL", "DL"),
      DISTANCE = c(1587, 173, 646, 187, 273, 1062, 583, 240, 1123, 851, 852, 862, 361, 507, 1020, 1092, 342, 489, 1184, 545)), row.names = c(NA, -20L),
    class = c("tbl_df", "tbl", "data.frame"), .Names = c("CANCELLED", "Carrier Name", "CARRIER", "DISTANCE"))
  test_data[["weight"]] <- c(seq(nrow(test_data)-1), NA)
  test_data[["IS_AA"]] <- test_data$CARRIER == "AA"
  model_ret <- build_model(
    test_data,
    model_func = xgboost_binary,
    formula = IS_AA ~ .,
    nrounds = 5,
    eval_metric = "auc",
    sparse = FALSE
  )
  prediction_ret <- prediction_binary(model_ret, threshold = "f_score")
  expect_true(any(prediction_ret$predicted_label))
  expect_true(any(!prediction_ret$predicted_label))
})
