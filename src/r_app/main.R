library(readr)
library(dplyr)


train_path <- "src/data/train.csv"
test_path  <- "src/data/test.csv"

# 1) Load training data
if (!file.exists(train_path)) {
  cat("Dataset not found at", train_path, "\n")
  cat("Please download 'train.csv' from Kaggle and place it in src/data/\n")
  quit(status = 0)
}

df <- read_csv(train_path, show_col_types = FALSE)
cat("Loaded training dataset.\n")

# 2) Basic exploration
cat("\nBasic structure:\n")
print(str(df))
cat("\nSummary statistics (numeric columns):\n")
print(summary(df))

# 3) Cleaning 
cat("\nMissing values per column before cleaning:\n")
print(colSums(is.na(df)))

# Fill Age with median
age_missing_before <- sum(is.na(df$Age))
age_med <- median(df$Age, na.rm = TRUE)
df$Age[is.na(df$Age)] <- age_med
cat(sprintf("\nFilled %d missing Age values with median (%.2f).\n", age_missing_before, age_med))

cat("\nMissing values per column after cleaning:\n")
print(colSums(is.na(df)))

# Convert Sex to numeric: male = 0, female = 1
cat("\nConverting 'Sex' column to numeric (male = 0, female = 1)\n")
df$Sex <- ifelse(df$Sex == "male", 0L, 1L)

# 4) Train logistic regression (glm with binomial)
features <- c("Pclass","Sex","Age","SibSp","Parch","Fare")
formula <- as.formula("Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare")

cat("\nTraining logistic regression (glm, binomial).\n")
model <- glm(formula, data = df, family = binomial())

cat("Model training complete.\n")
cat("\nCoefficients:\n")
print(coef(summary(model)))

# 5) Training accuracy
train_prob <- predict(model, newdata = df, type = "response")
train_pred <- ifelse(train_prob >= 0.5, 1L, 0L)
train_acc  <- mean(train_pred == df$Survived, na.rm = TRUE)
cat(sprintf("\nTraining set accuracy: %.4f\n", train_acc))

# 6) Load test set and predict
if (!file.exists(test_path)) {
  cat("\nTest dataset not found at", test_path, "\n")
  cat("Please download 'test.csv' from Kaggle and place it in src/data/\n")
  quit(status = 0)
}

test_df <- read_csv(test_path, show_col_types = FALSE)
cat("\nLoaded test dataset.\n")
cat("\nMissing values per column in test set before cleaning:\n")
print(colSums(is.na(test_df)))

# Fill missing values using training medians
test_age_missing_before <- sum(is.na(test_df$Age))
test_df$Age[is.na(test_df$Age)]  <- age_med
cat(sprintf("\nFilled %d missing Age values in test set with training median (%.2f).", test_age_missing_before, age_med))

if ("Fare" %in% names(test_df)) {
  fare_med <- median(df$Fare, na.rm = TRUE)
  test_fare_missing_before <- sum(is.na(test_df$Fare))
  test_df$Fare[is.na(test_df$Fare)] <- fare_med
  cat(sprintf("\nFilled %d missing Fare values in test set with training median (%.2f).\n", test_fare_missing_before, fare_med))
}

cat("\nMissing values per column in test set after cleaning:\n")
print(colSums(is.na(test_df)))

# Convert Sex to numeric: male = 0, female = 1
cat("\nConverting 'Sex' column to numeric (male = 0, female = 1)\n")
test_df$Sex <- ifelse(test_df$Sex == "male", 0L, 1L)

# Build the design frame for prediction
X_test <- test_df[, features, drop = FALSE]

cat("\nPredicting survivability on test set.\n")
test_prob <- predict(model, newdata = X_test, type = "response")
test_pred <- ifelse(test_prob >= 0.5, 1L, 0L)
cat("Predictions complete.\n")

# Save the results
output <- tibble(
  PassengerId = test_df$PassengerId,
  Survived = test_pred
)
write_csv(output, "src/data/predictions_r.csv")
cat("\nPredictions saved to src/data/predictions_r.csv\n")

