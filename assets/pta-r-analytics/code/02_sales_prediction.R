# Predict sales volume for new products (PC / Laptop / Netbook / Smartphone) from review & price attributes.
source("00_setup.R"); suppressPackageStartupMessages({library(randomForest); library(kernlab); library(gbm); library(corrplot)})
ex  <- read.csv(file.path(DATA_DIR, "Task 3 Files/existingproductattributes2017 copy.csv"))
new <- read.csv(file.path(DATA_DIR, "Task 3 Files/newproductattributes2017 copy.csv"))
cat("Existing:", nrow(ex), "products | New:", nrow(new), "\n"); print(table(ex$ProductType))

# Clean: ExtendedWarranty rows 134-141 are near-duplicates; BestSellersRank is 1/3 missing -> drop
ex$BestSellersRank <- NULL; new$BestSellersRank <- NULL
dv <- dummyVars(~ ., ex); exd <- data.frame(predict(dv, ex))
# Correlation matrix (all numeric attributes incl. dummies)
png(file.path(OUT_DIR, "sales-01-correlation.png"), 1800, 1500, res = 200)
corrplot(cor(exd), method = "circle", type = "upper", tl.cex = .65, tl.col = "black", title = "Correlation with Volume", mar = c(0,0,2,0)); dev.off()
cv <- sort(cor(exd)[, "Volume"], decreasing = TRUE); print(round(cv, 2))

# Feature selection: drop physical dimensions/weight/margin/ID (near-zero correlation with Volume),
# and 5-star reviews (r = 1.0 with Volume -> leakage-like), 3/2-star (collinear with 4-star)
drop <- c("ProductNum", "ShippingWeight", "ProductDepth", "ProductWidth", "ProductHeight", "ProfitMargin",
          "x5StarReviews", "x3StarReviews", "x2StarReviews")
X <- exd[, setdiff(names(exd), drop)]
cat("\nUsing:", paste(setdiff(names(X), "Volume"), collapse = ", "), "\n")

set.seed(SEED); idx <- createDataPartition(X$Volume, p = .75, list = FALSE)
tr <- X[idx, ]; te <- X[-idx, ]
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(SEED); rf  <- train(Volume ~ ., tr, method = "rf", trControl = ctrl, tuneLength = 3)
set.seed(SEED); svm <- suppressWarnings(train(Volume ~ ., tr, method = "svmPoly", trControl = ctrl, tuneLength = 3, preProcess = c("center","scale")))
set.seed(SEED); gb  <- train(Volume ~ ., tr, method = "gbm", trControl = ctrl, tuneLength = 3, verbose = FALSE)
set.seed(SEED); lm_ <- train(Volume ~ ., tr, method = "lm", trControl = ctrl)

rmse <- function(a, p) sqrt(mean((a - p)^2))
tab <- data.frame(model = c("Random Forest", "SVM (poly)", "Gradient Boosting", "Linear regression"),
  cv_RMSE = c(min(rf$results$RMSE), min(svm$results$RMSE), min(gb$results$RMSE), lm_$results$RMSE),
  holdout_RMSE = sapply(list(rf, svm, gb, lm_), function(m) rmse(te$Volume, predict(m, te))),
  negative_preds_on_new = NA)
cat("\nBaseline (predict mean): hold-out RMSE =", round(rmse(te$Volume, mean(tr$Volume)), 1), " SD(Volume) =", round(sd(X$Volume), 1), "\n")

# Score the new products (same dummy encoding as training)
new$Volume <- 0
ndv <- data.frame(predict(dv, new))
preds <- sapply(list(rf, svm, gb, lm_), function(m) predict(m, ndv[, setdiff(names(X), "Volume")]))
colnames(preds) <- c("rf", "svm", "gbm", "lm")
tab$negative_preds_on_new <- colSums(preds < 0); print(tab, digits = 5)

out <- cbind(new[, c("ProductType", "ProductNum", "Price", "ProfitMargin")], round(preds, 0))
out$pred_volume <- out$rf; out$revenue <- out$pred_volume * out$Price; out$profit <- out$revenue * out$ProfitMargin
four <- subset(out, ProductType %in% c("PC", "Laptop", "Netbook", "Smartphone")); print(four[order(-four$profit), ])
agg <- aggregate(cbind(pred_volume, revenue, profit) ~ ProductType, four, sum)
agg$vol_share <- agg$pred_volume / sum(agg$pred_volume); agg$profit_share <- agg$profit / sum(agg$profit); print(agg, digits = 4)
write.csv(four, file.path(OUT_DIR, "sales_predictions_four_types.csv"), row.names = FALSE)

# Charts
vi <- varImp(rf)$importance; vi$f <- factor(rownames(vi), levels = rownames(vi)[order(vi$Overall)])
png(file.path(OUT_DIR, "sales-02-variable-importance.png"), 1400, 800, res = 200)
print(ggplot(vi, aes(f, Overall)) + geom_col(fill = "#2b6cb0") + coord_flip() + labs(title = "What drives predicted sales volume", x = NULL, y = "Random Forest importance")); dev.off()
long <- rbind(data.frame(ProductType = agg$ProductType, share = agg$vol_share, measure = "Share of predicted volume"),
              data.frame(ProductType = agg$ProductType, share = agg$profit_share, measure = "Share of predicted profit"))
png(file.path(OUT_DIR, "sales-03-volume-vs-profit.png"), 1400, 800, res = 200)
print(ggplot(long, aes(ProductType, share, fill = measure)) + geom_col(position = "dodge") + scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("#a0aec0", "#2b6cb0"), name = NULL) + labs(title = "Volume is not profit", x = NULL, y = NULL) + theme(legend.position = "top")); dev.off()
png(file.path(OUT_DIR, "sales-04-reviews-vs-volume.png"), 1400, 800, res = 200)
print(ggplot(ex[ex$Volume > 0, ], aes(x4StarReviews, Volume)) + geom_point(colour = "#2b6cb0", alpha = .7) + geom_smooth(method = "lm", se = FALSE, colour = "#e07a5f") +
  labs(title = "4-star review count vs sales volume (existing products)", x = "4-star reviews", y = "Volume")); dev.off()
