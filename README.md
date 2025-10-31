# MLDS 400 — HW3: Titanic Survival Prediction

This repository provides reproducible Python and R Docker environments to explore the Titanic dataset, perform data cleaning, train a logistic regression model, report training accuracy, and save predictions on the test set to a CSV file.

Important note:
- You only need Docker to run the project; Python/R installations on the host are optional.

## Repository structure
```bash
├─ README.md
├─ src/
│  ├─ data/
│  │  ├─ train.csv
│  │  ├─ test.csv
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

## Quick Start
Clone this repository (in Terminal)  
```git clone https://github.com/shan-zh/ShanZhong_MLDS400_HW3_titanic-disaster.git```

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

**Build and Run (run everything in Terminal)**
1) Build the Python image  
```docker build -t titanic-python:latest -f src/python_app/Dockerfile src/python_app```  
2) Run the Python container (mount data folder)  
macOS/Linux  
```docker run --rm -v "$(pwd)/src/data:/app/src/data" titanic-python:latest```  
Windows PowerShell  
```docker run --rm -v "${PWD}\src\data:/app/src/data" titanic-python:latest```  


The Python container runs ```src/python_app/main.py```, which:
- Loads and prints basic dataset info and summary statistics.
- Displays missing-value counts before cleaning.
- Fills missing ```Age``` values with the median and reports how many were filled.
- Converts ```Sex``` to numeric (```male = 0```, ```female = 1```) and confirms the conversion.
- Trains a logistic regression model on the features: ```Pclass, Sex, Age, SibSp, Parch, Fare```
- Prints model training accuracy.
- Cleans the test set (fills missing ```Age``` and ```Fare```, encodes ```Sex```).
Predicts survivability and saves the output file: ```src/data/predictions_python.csv```

**Expected Output (abbreviated):**
```
Loaded training dataset.

Basic dataset info:
...

Summary statistics:
...

Missing values per column:
...

Filled 177 missing Age values with median (28.00).

Missing Age values after cleaning:
0

Converting 'Sex' column to numeric (male = 0, female = 1)

Building Logistic Regression model.
Model training complete.

Training set accuracy: 0.7957

Loaded test dataset.

Missing values per column in test set:
...

Handling missing values in test set:
Filled missing Age values with training median (28.00) and missing Fare values with training median (14.45).

Remaining missing values in test set (should be zero for Age and Fare):
...

Converting 'Sex' column to numeric (male = 0, female = 1)

Predicting survivability on test set.
Predictions complete.

Predictions saved to src/data/predictions_python.csv
```


## Run with Docker — R implementation
The R container mirrors the same flow: loads train.csv, prints structure/summary, cleans a few fields, fits a logistic regression via glm (binomial), reports training accuracy, loads test.csv, and saves test predictions to predictions_r.csv.

**Build and Run (run everything in Terminal)**
1) Build the R image  
```docker build -t titanic-r:latest -f src/r_app/Dockerfile src/r_app```  
2) Run the R container (mount data folder)  
macOS/Linux  
```docker run --rm -v "$(pwd)/src/data:/app/src/data" titanic-r:latest```  
Windows PowerShell  
```docker run --rm -v "${PWD}\src\data:/app/src/data" titanic-r:latest```  


The R container runs ```src/r_app/main.R```, which:
- Loads and prints dataset structure, summary statistics, and missing-value counts.
- Fills missing ```Age``` values with the median, showing how many were filled.
- Converts ```Sex``` to numeric (```male = 0```, ```female = 1```).
- Trains a logistic regression model using:
```glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare, family = binomial)```
- Prints model coefficients and training accuracy.
- Cleans the test set (```Age```, ```Fare```, and ```Sex```), prints before/after missing counts.
- Predicts survivability and saves: ```src/data/predictions_r.csv```

**Expected Output (abbreviated):**
```
Attaching package: ‘dplyr’
...

Loaded training dataset.

Basic structure:
...

Summary statistics (numeric columns):
...                            
                                                                          
Missing values per column before cleaning:
...

Filled 177 missing Age values with median (28.00).

Missing values per column after cleaning:
...

Converting 'Sex' column to numeric (male = 0, female = 1)

Training logistic regression (glm, binomial).
Model training complete.

Coefficients:
                Estimate  Std. Error    z value     Pr(>|z|)
(Intercept)  2.180170565 0.479087392  4.5506741 5.347433e-06
Pclass      -1.087435870 0.139401690 -7.8007367 6.154683e-15
Sex          2.760875291 0.198793469 13.8881590 7.473157e-44
Age         -0.039398000 0.007800706 -5.0505686 4.404968e-07
SibSp       -0.348785013 0.108989504 -3.2001707 1.373462e-03
Parch       -0.106709450 0.117229968 -0.9102574 3.626868e-01
Fare         0.002845885 0.002358624  1.2065871 2.275912e-01

Training set accuracy: 0.7946

Loaded test dataset.

Missing values per column in test set before cleaning:
...

Filled 86 missing Age values in test set with training median (28.00).
Filled 1 missing Fare values in test set with training median (14.45).

Missing values per column in test set after cleaning:
...

Converting 'Sex' column to numeric (male = 0, female = 1)

Predicting survivability on test set.
Predictions complete.

Predictions saved to src/data/predictions_r.csv
```