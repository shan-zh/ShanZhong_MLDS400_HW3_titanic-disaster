# MLDS 400 — HW3: Titanic Survival Prediction

This repository provides reproducible Python and R Docker environments to explore the Titanic dataset, perform data cleaning, train a logistic regression model, show the model accuracy, and save predictions on the test set to a CSV file.

Important notes
- You only need Docker to run the project; Python/R installations on the host are optional.

## Repository structure
```bash
├─ README.md
├─ src/
│  ├─ data/
│  ├─ python_app/
│  │  ├─ Dockerfile
│  │  ├─ requirements.txt
│  │  └─ main.py
│  └─ r_app/
│     ├─ Dockerfile
│     ├─ install_packages.R
│     └─ main.R
└─ .gitignore
```


## Prerequisites
- Docker installed and running.
- Local data files train.csv and test.csv in src/data/ (see next section).


## How to get the data (no data in repo)
You can obtain the Titanic dataset from Kaggle ([Titanic: Machine Learning from Disaster](https://www.kaggle.com/competitions/titanic/code)).
1. Download train.csv and test.csv.
2. Create the folder if it doesn’t exist: src/data/
3. Move both files into src/data/  
4. Final layout expected:
```bash
src/data/train.csv  
src/data/test.csv  
```
Do NOT upload the dataset to GitHub. The ```.gitignore``` file already excludes it.


## Run with Docker — Python implementation
The Python container reads src/data/train.csv and src/data/test.csv, prints dataset information, handles data cleaning, trains a logistic regression, reports training accuracy, and writes predictions for the test set to a CSV file (```predictions_python.csv```).

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
- Predictions saved to: ```src/data/predictions_python.csv```


## Run with Docker — R implementation
The R container mirrors the same flow: loads train.csv, prints structure/summary, cleans a few fields, fits a logistic regression via glm (binomial), reports training accuracy, loads test.csv, and saves test predictions to predictions_r.csv.

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
- Predictions saved to: ```src/data/predictions_r.csv```


## What each script does
- Python: src/python_app/main.py
    - Loads train.csv
    - Prints info/summary/missing values
    - Fills Age (median) and Embarked (mode), encodes Sex
    - Trains LogisticRegression on: Pclass, Sex, Age, SibSp, Parch, Fare
    - Prints training accuracy
    - Loads test.csv, fills Age and Fare if needed, encodes Sex
    - Predicts and saves predictions
- R: src/r_app/main.R
    - Same logic with glm(family = binomial), prints coefficients and training accuracy
    - Predicts on test set and saves the results
