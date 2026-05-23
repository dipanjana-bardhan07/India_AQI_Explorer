# 🌏 Pan India AQI Analysis & Prediction Using R

This repository contains an academic project that analyzes the Air Quality Index (AQI) across major Indian cities using R. The study explores pollution patterns and implements a linear regression-based prediction approach using AQI-related features.

---
## 📊 Dataset

The dataset used in this project is sourced from the [Open Government Data Platform India (data.gov.in)](https://data.gov.in/resources/daily-city-wise-air-quality-index-aqi-2015-2020).

- File Used: `city_day.csv`
- Duration: 2015 to 2020
- Data Columns: Date, City, Pollutant Levels (PM2.5, PM10, NO2, etc.), AQI, AQI_Bucket

---

## 🔍 Project Features

- Cleaned and analyzed AQI data using R
- Visualized pollution trends across major cities in India
- Identified most and least polluted cities
- Built a **linear regression-based AQI prediction model** using pollutant values
- Model implementation is available through RStudio workspace (`.RData`) and history file (`.Rhistory`)

---

## 🧠 Tech Stack

- **R Programming Language**
- Libraries: `shiny`,`tidyverse`,`lubricate`,`ggplot2`,`readr`,`dplyr`,`rsconnect`

---

## 📂 Files in This Repo

- `city_day.csv`: Raw dataset used for analysis
- `.Rhistory`: Contains step-by-step code execution
- `.RData`: Contains R environment objects (datasets, model)
- `app`: Contains the Shiny app dashboard source code which includes data cleaning, visualization, and model implementation
- `host`: Contains the R code for hosting the app using rsconnect
- `rsconnect`: Contains `.dcf` file for hosting the app

---

## 📌 Academic Note

This GitHub repository is submitted as part of a college project.  
Code and documentation are original.  
Any reuse must cite the source to avoid academic misconduct.

---

## 📬 Author

👤 **Dipanjana Bardhan**  
B.Tech in Computer Science (Specialization in Data Science)  
GitHub: [@dipanjana-bardhan07](https://github.com/dipanjana-bardhan07/)
RShiny App: [India AQI Explorer](https://dipanjanabardhan.shinyapps.io/india_aqi_explorer/)
