# Association rules on a competitor's transactions (Apriori), to read buying patterns and B2B signals.
source("00_setup.R"); suppressPackageStartupMessages({library(arules); library(arulesViz)})
tr <- read.transactions(file.path(DATA_DIR, "Task 4 - Market Basket Analysis/ElectronidexTransactions2017.csv"), format = "basket", sep = ",", rm.duplicates = TRUE)
cat("Transactions:", length(tr), " Items:", dim(tr)[2], "\n"); print(summary(size(tr)))
cat("Share of baskets with 1 item:", round(mean(size(tr) == 1), 3), " 5+ items:", round(mean(size(tr) >= 5), 3), "\n")
fr <- sort(itemFrequency(tr), decreasing = TRUE); print(round(head(fr, 10), 3))
png(file.path(OUT_DIR, "basket-01-top-items.png"), 1600, 900, res = 200)
print(ggplot(data.frame(item = factor(names(fr)[1:12], levels = rev(names(fr)[1:12])), f = fr[1:12]), aes(item, f)) +
  geom_col(fill = "#2b6cb0") + coord_flip() + scale_y_continuous(labels = scales::percent) +
  labs(title = "Most frequently purchased items", x = NULL, y = "Share of transactions")); dev.off()

# Drop 1-item baskets (cannot form a rule)
tr2 <- tr[size(tr) >= 2]; cat("Multi-item baskets:", length(tr2), "\n")
rules <- apriori(tr2, parameter = list(supp = 0.01, conf = 0.5, minlen = 2), control = list(verbose = FALSE))
rules <- rules[!is.redundant(rules)]; cat("Rules (non-redundant):", length(rules), "\n")
top <- sort(rules, by = "lift")[1:min(10, length(rules))]; inspect(top)
cat("\nRules with lift > 1:", sum(quality(rules)$lift > 1), "of", length(rules), "\n")
inspect(sort(rules, by = "confidence")[1:min(8, length(rules))])
png(file.path(OUT_DIR, "basket-02-rules-scatter.png"), 1600, 1000, res = 200)
print(plot(rules, measure = c("support", "confidence"), shading = "lift", engine = "ggplot2") + labs(title = "Association rules: support vs confidence")); dev.off()
q <- cbind(as(lhs(top), "list") |> sapply(paste, collapse = " + "), as(rhs(top), "list") |> sapply(paste, collapse = ""), quality(top))
write.csv(data.frame(q, row.names = NULL), file.path(OUT_DIR, "basket_top_rules.csv"), row.names = FALSE)
