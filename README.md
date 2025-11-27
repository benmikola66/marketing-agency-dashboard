# Marketing Funnel & Attribution Dashboard (SQL + Tableau)

[View Dashboard](marketing_attribution_performance.png)

This project analyzes the full marketing funnel from lead acquisition to revenue attribution, using SQL-cleaned data and Tableau visualizations.

---

## Business Problems Solved

1. **How much revenue is being generated overall?**
2. **How much is being spent on marketing?**
3. **How efficiently are leads converting through the funnel?**
   - Lead → Opportunity rate  
   - Opportunity → Closed Won rate  
4. **Which channels (UTM mediums) convert best?**
5. **Which channel receives credit for revenue under last-touch attribution?**

---

## Key Metrics & Funnel Logic

### **Total Revenue**
Sum of all invoice amounts after cleaning and standardizing invoice data.

### **Total Ad Spend**
Daily ad spend aggregated across all channels.

### **Lead → Opportunity Rate**
Percentage of leads that progress to opportunity status, segmented by UTM Medium:
- cpc  
- display  
- email  
- none  
- paid social  
- referral  
- unknown  

### **Opportunity → Deal Rate**
Percentage of opportunities that close as “Closed Won,” broken down by UTM Medium.

### **Conversion Funnel**
Sequential count of:
- Total Leads  
- Total Opportunities  
- Total Closed Won deals  

Visualizes drop-off and pipeline strength.

### **Last Touch Attribution**
SQL logic assigns revenue credit to the **most recent session** prior to purchase:
- Joins web_sessions_stg to invoice_stg  
- Ranks sessions using `ROW_NUMBER()`  
- Attributes revenue for `rn = 1`  

Revenue is then grouped by:
- utm_source  
- utm_medium  
- utm_campaign  

---

## Dashboard Layout

The Tableau dashboard includes:

- **Total Ad Spend** (KPI)
- **Total Revenue** (KPI)
- **Conversion Funnel** (left)
- **Lead → Opportunity Rate by Channel** (center)
- **Last Touch Attribution Revenue** (right)

Designed for a single-screen, executive-ready overview of marketing performance.

---

## Data Pipeline Overview (SQL → Tableau)

### 1. SQL Cleaning  
All data sources were cleaned using structured SQL scripts:
- web sessions  
- leads  
- opportunities  
- invoices  
- ad spend  

Standardization included:
- lowercasing strings  
- email cleanup  
- trimming whitespace  
- fixing malformed UTM fields  
- converting datatypes (dates, decimals)  
- removing duplicates  
- filling missing UTM values via joins  

### 2. Modeling  
Data was aligned on:
- `user_email`  
- `session_id`  
- `invoice_datetime`  

Ensuring valid joins across the funnel.

### 3. Attribution Logic  
A last-touch model built using SQL window functions:
- Only sessions occurring before the invoice timestamp were considered.
- The latest session (rn = 1) received 100% revenue credit.

### 4. Tableau Visualization  
Cleaned tables were imported into Tableau to create KPIs, funnel metrics, conversion analysis, and attribution outputs.

---

## Skills Demonstrated

- SQL data cleaning & pipeline creation  
- Window functions for attribution modeling  
- Marketing funnel analysis (lead → opp → closed won)  
- Tableau dashboard design  
- KPI development  
- Channel performance analysis  
- Revenue attribution methodology  
