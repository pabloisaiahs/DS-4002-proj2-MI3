# DS-4002-proj2-MI3
MI3 Repository - Group 7  

## PRESIDENTIAL APPROVAL RATINGS 

### **Contents of this Repository**  
This repository contains the code, data, and output for the presidential approval ratings project. This project was completed as part of the **DS 4002** course at UVA.  

---

## **1. Software and Platform**  
- **Software:** Python, R  
- **Packages Used:**  
  - **Python:**  
    - `pandas`
    - `matplotlib`
  - **R:**  
    - `ggplot2`
    - `dplyr`
    - `patchwork`
    - `padr`
    - `tidyr`
- **Platform:** Windows 10 / macOS Monterey / Ubuntu 20.04  

---

## **2. Documentation Map**  

📂 **Root Directory**  
  - `README.md` → This documentation file  
  - `LICENSE.md` → MIT License  

📂 **DATA/**  
  - `data-1-15.csv` → time-series data of approval rating and dates for 15 presidents
  - `allData.csv` → combined data, product of `data_consolidation_proj2.R`
  - `allDataInferredGDP.csv` → above, but extended quarterly GDP values to cover each month in the quarter (inaccurate, but potentially necessary for regression)

📂 **SCRIPTS/**  
  - `ApprovalEDA.py` → compiles data from presidents' timelines and normalizes them into one CSV.
  - `data_consolidation_proj2.R` → combines and normalizes data from all sources.
  - `forecasting_regression.ipynb` → perform regression analysis.
  - `approval_basic.ipynb` → perform basic analysis of time series.

📂 **OUTPUT/**  
  - `approval_ratings_clean.csv` → compiles data from `ApprovalEDA.py`, it's all the time series data for each President into one.
  - `approval_unemployment.png` → EDA for the relationship between approval ratings and unemployment.
  - `modelWithGDP.png` → Regression output for the model that includes nominal GDP.
  - `modelWithoutGDP.png` → Regression output for the model that excludes nominal GDP.
  - `ratings_time_president.png` → Approval ratings for each President.
  - `avg_ratings_party.png` → Approval ratings for each party.

---

## 3. Instructions for Reproducing Regression Results

### Regression Analysis Including GDP
- **Setup:**  
  Place `allDataInferredGDP.csv` in the DATA/ folder and open `forecasting_regression.ipynb` in Google Colab.
- **Data Preparation:**  
  The notebook merges all data sources and uses inferred monthly GDP values.
- **Model Fitting:**  
  Fit a full OLS model with predictors: CPIChange, UnemploymentRate, GDP, GDPchange, PctVotes, PrezParty, Chamber, and ChamberParty. Backward elimination is then applied.
- **Outputs:**  
  Regression summary and diagnostic plots are generated. Results are saved as `modelWithGDP.png` in OUTPUT/.

---

### Regression Analysis Excluding GDP
- **Setup:**  
  In the same notebook, navigate to the section for the model without GDP.
- **Data Preparation:**  
  The same data is used but the predictor GDP is omitted.
- **Model Fitting:**  
  Fit an OLS model with predictors: CPIChange, UnemploymentRate, GDPchange, PctVotes, PrezParty, and Chamber. Backward elimination is applied.
- **Outputs:**  
  Regression summary and diagnostics are generated. Results are saved as `modelWithoutGDP.png` in OUTPUT/.

### **1. Data Loading and Preparation**
   - Load the data set.
   - ensure the dataset is in chronological order, and the key variables are Approval, CPIChange, UnemploymentRate, GDP, GDPchange, PctVotes, PrezParty, Chamber.
   - Observations with missing values in any of the key variables should be removed to ensure complete cases for regression modeling.
### **2. Model Specification
   - A regression model was specified, including all numeric predictors (CPIChange, UnemploymentRate, GDP, GDPchange, and PctVotes) and categorical variables (PrezParty and Chamber).
   - Remove Chamber to avoid redundancy and potential multicolinearity.
### **3. Fitting the Full Model
   - The full model was estimated using ordinary least squares (OLS) regression, provided by statsmodels (use `statsmodel.formula.api` for fitting the OLS regression).
   - The model summary output was reviewed to assess the statistical significance of each predictor and the overall explanatory power of the model, as indicated by the R-squared and adjusted R-squared values.
### **4. Backwards Elimination and Final Model Evaluation**
   - A backward elimination procedure was applied to refine the model. Predictors with the highest p-values above the 0.05 significance threshold were removed.
   - The final model, after backward elimination, was reviewed in detail. The selected predictors, their coefficients, and statistical significance were reported.
   - The explanatory power of the model was reassessed through the adjusted R-squared value provided in the final model summary.
### **5. Repeat Procedure Using Data without GDP
   - Repeat the procdure using data without GDP and compare the two models performances 


---

## **4. Citations**  

### Data Sources

https://fred.stlouisfed.org/series/MEDCPIM158SFRBCLE

https://fred.stlouisfed.org/series/GDPC1#

https://fred.stlouisfed.org/series/UNRATE

[Brookings Institution - Congressional political statistics - Table 8-2](https://www.brookings.edu/articles/vital-statistics-on-congress/)

https://news.gallup.com/poll/116677/presidential-approval-ratings-gallup-historical-statistics-trends.aspx

### Resources Used

https://www.statology.org/convert-strings-to-dates-in-r/

https://www.geeksforgeeks.org/element-wise-concatenation-of-string-vector-in-r/

https://www.reddit.com/r/rstats/comments/ii95ue/making_two_graphs_side_by_side_ggplot2/

https://stackoverflow.com/questions/61532807/r-how-to-remove-the-day-from-a-date

https://www.reddit.com/r/Rlanguage/comments/18bqdwr/issue_merging_datasets/

https://dplyr.tidyverse.org/reference/filter.html

https://stackoverflow.com/questions/16787038/insert-rows-for-missing-dates-times

https://stackoverflow.com/questions/71843108/how-to-convert-character-to-date-with-two-different-types-of-date-formats-in-r

https://tidyr.tidyverse.org/reference/fill.html

https://stackoverflow.com/questions/70068826/new-column-with-percentage-change-in-r

---

## **5. Summary**
This project examines presidential approval ratings and the factors that contribute to them.
- 
In order to accomplish the above, we looked at average presidential approval rating in a given month as our response variable, and paired it with GDP quarterly change, unemployment rate, CPI yearly change, presidential party affiliation, and the percentage of senators from a president's party voting in favor of the president's supported legislation in a given year. We created a linear model with some of these factors to attempt to predict approval rating for a hypothetical president with certain values of these variables. 

In the end, based on backwards selection, we found that the most effective models included unemployment rate, GDP (nominal) and percentage favorable votes in the senate (if we include nominal GDP as a predictor variable), and CPI change and percentage favorable votes in the senate if we did not include nominal GDP as a predictor variable. Our R-squared for the former model was around 0.4, which means that our final model was at least somewhat predictive of presidential approval ratings. 

**Team 7, The Unsupervised Learners - DS 4002**
