import pandas as pd
import os
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

def main():
    # Define the relative path to your dataset
    data_path = "src/data/train.csv"
    test_path = "src/data/test.csv"

    # Check if the file exists
    if not os.path.exists(data_path):
        print(f"Dataset not found at {data_path}")
        print("Please download 'train.csv' from Kaggle and place it in src/data/")
        return

    if not os.path.exists(test_path):
        print(f"Test dataset not found at {test_path}")
        print("Please download 'test.csv' from Kaggle and place it in src/data/")
        return

    # Load dataset using pandas
    df = pd.read_csv(data_path)
    print("Loaded training dataset.")

    # Basic info
    print("Basic dataset info:")
    print(df.info())
    print("\nSummary statistics:")
    print(df.describe(include="all").T.head(10))

    # Check missing values
    print("\nMissing values per column:")
    print(df.isnull().sum())

    # Fill missing ages with median
    df["Age"].fillna(df["Age"].median(), inplace=True)

    # Fill missing embarked values with mode
    df["Embarked"].fillna(df["Embarked"].mode()[0], inplace=True)

    # Feature engineering
    # Convert 'Sex' to numeric
    df["Sex"] = df["Sex"].map({"male": 0, "female": 1})

    # Select features for training
    features = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare"]
    X_train = df[features]
    y_train = df["Survived"]

    # Build logistic regression model
    print("\nBuilding Logistic Regression model")
    model = LogisticRegression(max_iter=200)
    model.fit(X_train, y_train)
    print("Model training complete.")

    # Measure accuracy on training set
    train_preds = model.predict(X_train)
    train_acc = accuracy_score(y_train, train_preds)
    print(f"Training set accuracy: {train_acc:.4f}")

    # Load test data
    test_df = pd.read_csv(test_path)
    print("\nLoaded test dataset.")
    print("Missing values per column in test set:")
    print(test_df.isnull().sum())

    # Fill missing ages and fares in test set
    test_df["Age"].fillna(df["Age"].median(), inplace=True)
    test_df["Fare"].fillna(df["Fare"].median(), inplace=True)
    test_df["Sex"] = test_df["Sex"].map({"male": 0, "female": 1})

    # Prepare test features
    X_test = test_df[features]

    # Predict on test set
    print("\nPredicting survivability on test set")
    test_preds = model.predict(X_test)
    print("Predictions complete.")

    # If test.csv contains 'Survived' column (for checking accuracy)
    if "Survived" in test_df.columns:
        y_test = test_df["Survived"]
        test_acc = accuracy_score(y_test, test_preds)
        print(f"Test set accuracy: {test_acc:.4f}")
    else:
        print("No 'Survived' column in test.csv, skipping test accuracy calculation.")


if __name__ == "__main__":
    main()


