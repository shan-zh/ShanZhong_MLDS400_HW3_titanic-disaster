# MLDS 400 — HW3: Titanic Survival Prediction

This repository provides a reproducible environment (Python and R) to load the Titanic dataset, explore/adjust features, train a simple model, and print results. It is designed so a user can clone, read this README, and run the code in a few simple steps.

Important notes
- Do not commit the dataset. This repo shows how to download it locally.
- All commands below are run from the repository root (the same folder as this README).
- You only need Docker to run the project; Python/R installations on the host are optional.

## Repository structure
.  
├── README.md  
├── src/  
│   ├── data/                 # place train.csv and test.csv here (not committed)  
│   ├── python_app/  
│   │   ├── Dockerfile        # Python container  
│   │   ├── requirements.txt  
│   │   └── main.py  
│   └── r_app/  
│       ├── Dockerfile        # R container  
│       ├── install_packages.R  
│       └── main.R  
└── .gitignore                # ignores src/data/, venv/, caches, etc.  


## Prerequisites
- Docker installed and running.
- Local data files train.csv and test.csv in src/data/ (see next section).


## How to get the data (no data in repo)
You can obtain the Titanic dataset from Kaggle ([Titanic: Machine Learning from Disaster](https://www.kaggle.com/competitions/titanic/code)).
1. Download train.csv and test.csv.
2. Create the folder if it doesn’t exist: src/data/
3. Move both files into src/data/  
Final layout expected:  
src/data/train.csv  
src/data/test.csv  


## Run with Docker — Python implementation
The Python container reads src/data/train.csv and src/data/test.csv, prints dataset information, handles minimal cleaning, trains a logistic regression, reports training accuracy, and prints test predictions (accuracy is skipped since the official test set lacks the Survived column).

1) Build the Python image  
```docker build -t titanic-python:latest -f src/python_app/Dockerfile src/python_app```  
2) Run the Python container (mount data folder)  
macOS/Linux  
```docker run --rm -v "$(pwd)/src/data:/app/src/data" titanic-python:latest```  
Windows PowerShell  
```docker run --rm -v "${PWD}\src\data:/app/src/data" titanic-python:latest```  

Expected console output (abbreviated)
- "Loaded training dataset."
- "Basic dataset info:" and data summary
- Missing value counts
- Confirmation of minimal cleaning (e.g., Age/Embarked filled, Sex mapped)
- "Building Logistic Regression model"
- "Training set accuracy: …"
- "Loaded test dataset." and missing values for test
- "Predicting survivability on test set…"
- If Survived not present in test: a note that test accuracy is not computed, plus a preview of predictions


## Run with Docker — R implementation
The R container mirrors the same flow: loads train.csv, prints structure/summary, cleans a few fields, fits a logistic regression via glm (binomial), reports training accuracy, loads test.csv, and prints test predictions (and test accuracy only if a Survived column exists).

1) Build the R image  
```docker build -t titanic-r:latest -f src/r_app/Dockerfile src/r_app```  
2) Run the R container (mount data folder)  
macOS/Linux  
```docker run --rm -v "$(pwd)/src/data:/app/src/data" titanic-r:latest```  
Windows PowerShell  
```docker run --rm -v "${PWD}\src\data:/app/src/data" titanic-r:latest```  

Expected console output (abbreviated)
- Loaded training dataset.
- Structure and summary prints
- Missing value counts
- Minimal cleaning confirmation (Age median, Embarked mode, Sex numeric)
- Coefficient table from glm
- "Training set accuracy: …"
- "Loaded test dataset." and missing values
- "Predicting survivability on test set…"


## What each script does
- Python: src/python_app/main.py
    - Loads train.csv
    - Prints info/summary/missing values
    - Fills Age (median) and Embarked (mode), encodes Sex
    - Trains LogisticRegression on: Pclass, Sex, Age, SibSp, Parch, Fare
    - Prints training accuracy
    - Loads test.csv, fills Age and Fare if needed, encodes Sex
    - Predicts and prints first predictions; skips test accuracy if labels not present
- R: src/r_app/main.R
    - Same logic with glm(family = binomial), prints coefficients and training accuracy
    - Predicts on test set; prints a note if no Survived column exists
