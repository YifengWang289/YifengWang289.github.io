# Shared setup. Set DATA_DIR to the folder holding the raw CSVs, OUT_DIR for charts/results.
DATA_DIR <- Sys.getenv("DATA_DIR", unset = ".")
OUT_DIR  <- Sys.getenv("OUT_DIR",  unset = "../charts")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
suppressPackageStartupMessages({library(caret); library(ggplot2)})
theme_set(theme_minimal(base_size = 13))
SEED <- 123
