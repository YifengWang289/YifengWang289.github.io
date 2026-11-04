# Which brand (Acer vs Sony) will a customer prefer? Classification on survey demographics.
source("00_setup.R"); suppressPackageStartupMessages({library(C50); library(randomForest)})
d <- read.csv(file.path(DATA_DIR, "Task 2 Materials 3/CompleteResponses.csv"))
d$brand <- factor(d$brand, levels = c(0, 1), labels = c("Acer", "Sony"))
# elevel, car, zipcode are coded categories, not quantities
for (v in c("elevel", "car", "zipcode")) d[[v]] <- factor(d[[v]])
cat("Rows:", nrow(d), " Sony share:", round(mean(d$brand == "Sony"), 3), "\n")

set.seed(SEED); idx <- createDataPartition(d$brand, p = .75, list = FALSE)
train <- d[idx, ]; test <- d[-idx, ]
ctrl <- trainControl(method = "cv", number = 10)

set.seed(SEED); m_c50 <- train(brand ~ ., train, method = "C5.0", trControl = ctrl, tuneLength = 2)
set.seed(SEED); m_rf  <- train(brand ~ ., train, method = "rf",   trControl = ctrl, tuneLength = 5)

res <- resamples(list(C5.0 = m_c50, RandomForest = m_rf)); print(summary(res))
for (nm in c("C5.0", "RandomForest")) {
  m <- if (nm == "C5.0") m_c50 else m_rf
  cm <- confusionMatrix(predict(m, test), test$brand)
  cat("\n==", nm, "hold-out ==\n"); print(cm$table)
  cat("Accuracy:", round(cm$overall["Accuracy"], 4), " Kappa:", round(cm$overall["Kappa"], 4), "\n")
}
# Honest baseline: always predict the majority class
cat("Majority-class baseline:", round(max(prop.table(table(test$brand))), 4), "\n")

# Variable importance
vi <- varImp(m_rf)$importance; vi$feature <- rownames(vi); vi <- vi[order(vi$Overall), ]
vi$feature <- factor(vi$feature, levels = vi$feature)
print(vi[order(-vi$Overall), ])
png(file.path(OUT_DIR, "brand-01-variable-importance.png"), 1400, 800, res = 200)
print(ggplot(vi, aes(feature, Overall)) + geom_col(fill = "#2b6cb0") + coord_flip() +
  labs(title = "What drives brand preference", x = NULL, y = "Random Forest importance (scaled)")); dev.off()

# Why salary + age: preference by age band x salary band
d$salary_band <- cut(d$salary, c(0, 40000, 60000, 80000, 100000, 150000), labels = c("<$40K", "$40-60K", "$60-80K", "$80-100K", "$100K+"))
d$age_band <- cut(d$age, c(19, 40, 60, 80), include.lowest = TRUE, labels = c("20-40", "41-60", "61-80"))
agg <- aggregate(brand == "Sony" ~ salary_band + age_band, d, mean); names(agg)[3] <- "sony"
png(file.path(OUT_DIR, "brand-02-salary-age-heatmap.png"), 1400, 800, res = 200)
print(ggplot(agg, aes(salary_band, age_band, fill = sony)) + geom_tile(colour = "white") +
  geom_text(aes(label = scales::percent(sony, 1)), colour = "white") +
  scale_fill_gradient(low = "#e07a5f", high = "#2b6cb0", name = "Prefer Sony") +
  labs(title = "Sony preference by salary and age", x = "Salary", y = "Age")); dev.off()

# Score the 5,000 incomplete survey responses (brand column is a placeholder there)
inc <- read.csv(file.path(DATA_DIR, "Task 2 Materials 3/SurveyIncomplete.csv"))
cat("\nIncomplete survey brand values:", paste(names(table(inc$brand)), table(inc$brand), collapse = " | "), "\n")
for (v in c("elevel", "car", "zipcode")) inc[[v]] <- factor(inc[[v]], levels = levels(train[[v]]))
pr <- predict(m_rf, inc); print(table(pr)); print(round(prop.table(table(pr)), 3))
saveRDS(list(cv = res, cm_rf = confusionMatrix(predict(m_rf, test), test$brand)), file.path(OUT_DIR, "brand_results.rds"))
