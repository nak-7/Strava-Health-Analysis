# 🏃 Strava Fitness Data Analytics — EDA Case Study

![Python](https://img.shields.io/badge/Python-3.8+-blue)
![Pandas](https://img.shields.io/badge/Pandas-EDA-green)
![SQL](https://img.shields.io/badge/SQL-SQLite-orange)
![PowerBI](https://img.shields.io/badge/PowerBI-Dashboard-yellow)

---

## 📌 Project Overview

This project is an Exploratory Data Analysis (EDA) case study on Fitbit fitness tracker data, conducted as part of the **Bellabeat Marketing Analytics** internship project. The goal is to analyze smart device fitness data to identify consumer usage patterns and generate high-level recommendations for Bellabeat's marketing strategy.

**Project Type:** EDA
**Contribution:** Individual
**Author:** Nakshatra Devkar

---

## 🎯 Business Objective

> *"How can a wellness technology company play it smart?"*

Urška Sršen, co-founder of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities. The analysis focuses on:

1. How consumers are using their smart devices
2. What trends exist in activity, sleep, and calorie data
3. How these trends can inform Bellabeat's marketing strategy
4. Which features and products should be promoted to target users

---

## 📂 Project Structure

```
Strava-EDA/
│
├── Nakshatra_Strava_EDA_Project.ipynb    # Main Python EDA notebook (15 charts)
├── Nakshatra_Strava_Python_Analysis.pdf  # PDF export of executed notebook
├── Nakshatra_Strava_SQL_Analysis.sql     # SQL queries (25+ queries, 8 sections)
├── Nakshatra_Strava_SQL_Analysis.pdf     # Formatted SQL report with results
├── Nakshatra_Strava_PowerBI_Dashboard.pdf# 2-page Power BI style dashboard
│
└── data/
    ├── dailyActivity_merged.csv
    ├── dailyCalories_merged.csv
    ├── dailyIntensities_merged.csv
    ├── dailySteps_merged.csv
    ├── sleepDay_merged.csv
    └── weightLogInfo_merged.csv
```

---

## 📊 Dataset

| Property | Value |
|---|---|
| Source | Fitbit Fitness Tracker Data (Kaggle — Mobius) |
| License | Creative Commons (CC0) |
| Records | 940 daily activity records |
| Users | 33 unique Fitbit users |
| Period | April 12 – May 9, 2016 |
| DOI | 10.5281/zenodo.53894 |

### Files Used

| File | Description |
|---|---|
| dailyActivity_merged.csv | Main activity data — steps, distance, calories, active minutes |
| dailyCalories_merged.csv | Daily calorie data |
| dailyIntensities_merged.csv | Activity intensity breakdown |
| dailySteps_merged.csv | Daily step counts |
| sleepDay_merged.csv | Sleep duration and records |
| weightLogInfo_merged.csv | Weight and BMI logs |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Python 3.8+** | Core programming language |
| **Pandas** | Data manipulation and analysis |
| **NumPy** | Numerical operations |
| **Matplotlib & Seaborn** | Data visualization (15 charts) |
| **Missingno** | Missing value visualization |
| **SQLite / DB Browser** | SQL queries and data exploration |
| **Power BI** | Interactive dashboard creation |

---

## 🔄 Project Architecture

```
Raw CSV Data
     ↓
Data Merging (6 datasets → 1 master)
     ↓
Data Cleaning & Wrangling
     ↓
EDA & Visualization (15 Charts)
     ↓
SQL Analysis (25+ queries)
     ↓
Power BI Dashboard (2 pages)
     ↓
Business Recommendations
```

---

## 📈 Key Findings

### Activity Patterns
- Average daily steps: **7,638** — below CDC's recommended 10,000 steps
- Only **32%** of daily records meet the 10,000-step CDC goal
- **Saturday** is the most active day (8,153 avg steps); **Sunday** is the least active (6,933)
- **Tuesday** is the second most active day — midweek motivation spike

### Sedentary Behavior
- Users average **991 minutes (~16.5 hours)** of sedentary time per day
- Even Very Active users (>10K steps) average over 900 sedentary minutes
- **1/3 of users** have sedentary minutes consistently above 1,000 per day

### Sleep
- Average sleep duration: **6.99 hours** — below CDC's recommended 8 hours
- **Sunday** shows the highest average sleep (recovery pattern)
- **Wednesday/Thursday** show the lowest sleep (mid-week work stress)

### User Classification (by avg daily steps)
| User Type | Steps | % of Users |
|---|---|---|
| Very Active | >10,000 | 32% |
| Fairly Active | 7,500–10,000 | 18% |
| Low Active | 5,000–7,500 | 18% |
| Sedentary | <5,000 | 24% |

### Correlations
- TotalSteps & TotalDistance: **0.99** (near perfect)
- VeryActiveMinutes & Calories: **0.62** (strong)
- SedentaryMinutes & TotalSteps: **-0.33** (negative)

---

## 💡 Business Recommendations

1. **Step Challenges** — Launch personalized step-up challenges targeting users below 10K steps, with weekly badges and progress notifications
2. **Sedentary Alerts** — Introduce hourly movement reminders for users with >60 consecutive sedentary minutes
3. **Sleep Coaching** — Add a premium Sleep + Recovery Score feature combining sleep data with activity metrics
4. **Saturday Campaigns** — Schedule community events and leaderboard competitions on Saturdays (peak activity day)
5. **Beginner Plans** — Target the 24% Sedentary user segment with beginner-friendly challenges to convert them into active users

---

## 📋 SQL Analysis Sections

1. Data Integrity & Cleaning
2. Steps & Activity Analysis
3. Calories & Active Minutes
4. Sedentary Behaviour
5. Sleep Analysis
6. Weight & BMI
7. Combined Joined Analysis
8. Summary Insights

---

## 🚀 How to Run

### Python Notebook
```bash
# Install dependencies
pip install pandas numpy matplotlib seaborn missingno plotly

# Place all CSV files in the same directory as the notebook
# Run all cells top to bottom
jupyter notebook Nakshatra_Strava_EDA_Project.ipynb
```

### SQL Queries
```bash
# Open DB Browser for SQLite
# File → Open Database → select strava_fitness.db
# Execute → Run All Queries from Nakshatra_Strava_SQL_Analysis.sql
```

---

## 📊 Charts in the Notebook

| Chart | Type | Key Insight |
|---|---|---|
| 1 | Bar Chart | Average steps by day of week |
| 2 | Scatter Plot | Calories vs Steps (colored by Active Minutes) |
| 3 | Pie Chart | Activity time distribution |
| 4 | Histogram + KDE | Steps distribution |
| 5 | Box Plot | Sleep duration by day |
| 6 | Donut Chart | User type classification |
| 7 | Heatmap | Correlation matrix |
| 8 | Bar Chart | Sedentary minutes by user type |
| 9 | Scatter Plot | Steps vs Sleep (colored by calories) |
| 10 | Dual-axis Chart | Calories and steps by day |
| 11 | Scatter Plot | Very active vs fairly active minutes |
| 12 | Bar Chart | Top 10 most active users |
| 13 | Side-by-side | Distance tracking analysis |
| 14 | Heatmap | Full correlation heatmap |
| 15 | Pair Plot | Key numerical features |

---

## ⚠️ Data Limitations

- **Sample size:** Only 33 users — not representative of the full Fitbit user base
- **Demographics:** No age, sex, height, or profession data available
- **Time period:** Only 28 days (April–May 2016) — seasonal patterns not captured
- **Data age:** Dataset from 2016 — user behavior may have changed significantly
- **Distance units:** No information on distance measuring units in the dataset

---

## 📁 Submission Files

| File | Description |
|---|---|
| `.ipynb` | Python EDA notebook |
| `_Python_Analysis.pdf` | PDF of executed notebook |
| `_SQL_Analysis.sql` | SQL file |
| `_SQL_Analysis.pdf` | SQL report PDF |
| `_PowerBI_Dashboard.pdf` | Power BI dashboard PDF |

---

*Project completed as part of Data Analytics Internship — Nakshatra Devkar*
