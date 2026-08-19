# Motor Vehicle Collisions Analysis
## 📌 Project Overview
This repository contains an end-to-end data analytics project analyzing motor vehicle collision data across New York City. The project aims to engineer a clean data pipeline that transforms raw, unstandardized data into an interactive executive dashboard and visualizations that identify dangerous locations, common crash causes, peak-risk hours, and opportunities to improve road safety. The dataset includes crash dates/times, locations, boroughs, vehicle types, injuries/fatalities, and contributing factors. This is real open data collected by the NYPD.

---

## 🚗 Data Cleaning and Imputation Pipeline
This automated pipeline ingests raw NYPD Motor Vehicle Collision data, resolves missing information using spatial mapping, standardizes variable formats, and securely stores the production-ready dataset in both CSV and SQL Database formats.

*   **Data Ingestion and Initial Health Check.**
    *  **What Happens:** The necessary Python modules are installed first. Then the dataset is loaded into the pipeline, and an initial audit is run to inspect overall missing values and structure.
    *  **Key Action:** Identifies and removes duplicate records so that each accident report is represented only once.

  
*   **Column Standardization and Shortening.**
    *   **What Happens:** Column names in the raw public dataset are inconsistent, long, or difficult to work with (e.g., NUMBER OF PEDESTRIANS INJURED or VEHICLE TYPE CODE 1).
    *   **Key Action:** Converts all column names to lowercase, cleans up extra spaces, and renames long descriptions into brief, standard identifiers (e.g., ped_injured and vehicle_1).
  

*   **Date and Time Feature Engineering.**
    * **What Happens:** Raw date and time entries are extracted and converted into proper standardized time formats.
    * **Key Action:** Generates useful time-based metadata for reporting, including:
      * Day of the week (e.g., Monday, Tuesday)
      * Month, Year, and Calendar Quarter
      * Time of Day buckets (e.g., Morning, Afternoon, Late Night).


*   **Smart Location and Spatial Imputation.**
Where accident locations are missing street or borough names, the pipeline uses a two-step geographic recovery process:
    * **Step A (Internal Coordinate Matching):** The script checks if an accurate latitude/longitude pair matches another accident in the dataset. If it finds a match, it automatically fills in the missing street names, borough, and zip code.
    * **Step B (Spatial Boundary Mapping):** If the borough is still unknown, the pipeline plots the GPS coordinates onto an official map boundary of New York City to determine precisely which borough the crash occurred in.
    * **Step C (Cross-Field Fallback):** Infers missing boroughs from existing ZIP Codes, assigns missing ZIP Codes as "Unknown", and fills missing streets as "Unspecified".


* **Text Formatting and Missing Value Handling**
    * **What Happens:** Raw text entries often mix uppercase, lowercase, and shorthand abbreviations.
    * **Key Action:**
        *	**Capitalization:** Standardizes street names, boroughs, and descriptions into Title Case (e.g., converts WHITESTONE EXPRESSWAY to Whitestone Expressway).
        *	**Vehicle Mapping:** Cleans and groups erratic vehicle type names into standard categories (e.g., converting FDNY AMBUL to Ambulance or PKUP to Pick-Up Truck).
        *	**Default Fallbacks:** Missing secondary vehicles or contributing factors are populated with "Not Applicable", while missing injury or casualty counts are safely filled with 0.


* **Automated Export and Data Storage.**
Once all validation and cleaning checks pass, the dataset is exported into two destination formats for downstream business use:
1.	**Flat File (CSV):** Exported as a portable CSV file for fast reporting, dashboard ingestion, and spreadsheet analysis.
2.	**Database Table (SQLite/SQL):** Loaded directly into a structured database (nyc_collisions.db) with an indexed layout to enable fast SQL querying.

**💻 Complete Pipeline Code**

[Click here](https://nbviewer.org/github/Madivoli/Motor-Vehicle-Collisions-Analysis/blob/main/collisions_analysis.ipynb) for the complete, self-contained Python script that implements the entire workflow, including SQL database creation.


## 💻 Data Analysis

*   **Data Analysis:**
    *   [SQL](https://github.com/Madivoli/Motor-Vehicle-Collisions-Analysis/blob/main/collision_analysis.sql) — *The repository of structured queries used to calculate margin percent, determine revenue and cost drivers, carry out marketing attribution and channel audit, and so on. Using SELECT statements, JOINS, GROUP BY & ORDER BY functions, WHERE filter, Common Table Expression (CTE), etc.*

*   **Business Intelligence and Dashboards:**
    *   [Tableau Workbook (Packaged)](./dashboards/ecommerce_executive_analytics.twbx) — *The interactive workbook containing Metrics, executive-ready visual stories, dashboards, calculated fields, actions, and parameters.*

*   **Executive Summary and Reports:**
    *   [Executive Summary](https://github.com/Madivoli/Motor-Vehicle-Collisions-Analysis/blob/main/EXECUTIVESUMMARY.md) — *Summary of numerous reports containing main findings and numbers, recommendations, conclusion, and call-to-action sections for management.*
    *   [Motor Vehicle Collisions Analysis Report](https://github.com/Madivoli/e-commerce_profitability_analysis/blob/main/PROFITABILITY%20AND%20COST%20ANALYSIS%20REPORT.pdf)

