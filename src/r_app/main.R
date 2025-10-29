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
cat("Loaded training dataset.\n\n")

# 2) Basic exploration
cat("Basic structure:\n")
print(str(df))
cat("\nSummary statistics (numeric columns):\n")
print(summary(df))
cat("\nMissing values per column:\n")
print(colSums(is.na(df)))

# 3) Cleaning 
# Fill Age with median
age_med <- median(df$Age, na.rm = TRUE)
df$Age[is.na(df$Age)] <- age_med

# Fill Embarked with mode
emb_mode <- names(which.max(table(df$Embarked)))
df$Embarked[is.na(df$Embarked)] <- emb_mode

# Convert Sex to numeric: male = 0, female = 1
df$Sex <- ifelse(df$Sex == "male", 0L, 1L)

cat("\nPreview of adjusted columns:\n")
print(head(df[, c("Survived","Pclass","Sex","Age","SibSp","Parch","Fare")]))

# 4) Train logistic regression (glm with binomial)
features <- c("Pclass","Sex","Age","SibSp","Parch","Fare")
formula <- as.formula("Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare")

cat("\nTraining logistic regression (glm, binomial)...\n")
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
cat("Missing values per column in test set:\n")
print(colSums(is.na(test_df)))

# Match the same minimal cleaning as training
test_df$Age[is.na(test_df$Age)]  <- age_med
if ("Fare" %in% names(test_df)) {
  fare_med <- median(df$Fare, na.rm = TRUE)
  test_df$Fare[is.na(test_df$Fare)] <- fare_med
}
test_df$Sex <- ifelse(test_df$Sex == "male", 0L, 1L)

# Build the design frame for prediction
X_test <- test_df[, features, drop = FALSE]

cat("\nPredicting survivability on test set...\n")
test_prob <- predict(model, newdata = X_test, type = "response")
test_pred <- ifelse(test_prob >= 0.5, 1L, 0L)
cat("Predictions complete.\n")

# If Survived exists, report accuracy; otherwise, print a note
if ("Survived" %in% names(test_df)) {
  test_acc <- mean(test_pred == test_df$Survived, na.rm = TRUE)
  cat(sprintf("Test set accuracy: %.4f\n", test_acc))
} else {
  cat("Note: 'Survived' column not found in test.csv; accuracy cannot be computed on the official test file.\n")
  cat("First 10 predictions (0=did not survive, 1=survived):\n")
  print(head(test_pred, 10))
}

