# Customer 360° Analytics Dashboard (SQL | Python | Power BI)

## Project Overview
The **Customer 360° Analytics Dashboard** is an end-to-end **data analytics and business intelligence project** designed to unify customer, sales, and marketing insights into a single interactive view.  
This project integrates **SQL Server (data modeling)**, **Python (forecasting with Prophet)**, and **Power BI (visual storytelling)** to uncover actionable insights on **sales performance, churn, CLV, and customer segmentation**.

---

## Business Objective
The goal of this project is to enable a retail business (Superstore dataset) to:
- Identify and retain **high-value customers**
- Predict **future sales trends**
- Minimize **customer churn**
- Optimize **marketing and engagement strategies**
- Provide **executive-level visibility** into key KPIs across regions, products, and customer segments

---

## Project Architecture

```
SQL Server (Data Modeling)
       │
       ▼
Python (Prophet Forecast Model)
       │
       ▼
Power BI (Interactive Dashboards)
```

## Power BI Dashboard Pages

### Executive Overview
![pg1](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page1.png)

### RFM Analysis
![pg2](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page2.png)


### Churn Risk Analysis
![pg3](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page3.png)


### Customer Lifetime Value (CLV)
![pg4](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page4.png)


### Marketing Strategy & Segmentation
![pg5](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page5.png)


### Sales Performance
![6](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page6.png)

### Sales Forecasting with ML
![7](https://github.com/Subith-Varghese/Customer-360-Analysis/blob/ce262c53da0f8fda631e43b305edd4c27ed407c6/Images/Page7.png)


---
## Data Model

Primary dataset: Superstore 2025
```
| Table                                                       | Description                                                  |
| ----------------------------------------------------------- | ------------------------------------------------------------ |
| `Superstore 2025`                                           | Raw transactional dataset (Orders, Customers, Sales, Profit) |
| `vw_RFM_Segments`                                           | RFM segmentation view (Recency, Frequency, Monetary)         |
| `vw_Churn_Product / vw_Churn_ShipMode / vw_Churn_Geography` | Churn analysis views                                         |
| `vw_Customer_CLV`                                           | Historical & predictive CLV calculations                     |
| `vw_Customer_Marketing_Matrix`                              | Advanced marketing segmentation (VIP, Growth, Reactivation)  |
| `vw_Sales_Forecast`                                         | Python-generated Prophet forecast integrated into SQL        |


```

---

## SQL Highlights

RFM Segmentation
- Classified customers using percentile-based scoring for Recency, Frequency, and Monetary value.
- Segments include: Champion, Loyal, At Risk, Lost, Big Spenders, Other.

Churn Analysis
- Built churn risk models by Product Category, Ship Mode, and Region.
- Identified high-churn zones for retention campaigns.

Customer Lifetime Value (CLV)
- Computed Predictive CLV (1-Year) using average order value × frequency × tenure.
- Combined with engagement scores for Marketing Matrix Segmentation.

Marketing Segmentation
- Derived Value Segments (High, Medium, Low) and Engagement Segments.
- Combined into actionable categories:
  - VIP Retention
  - VIP Win-Back
  - Growth Opportunity
  - Reactivation Campaign

--- 

## Python & Machine Learning

Time-Series Forecasting (Prophet)  
- Trained a Prophet model on daily sales to forecast the next 6 months.
- Forecast outputs (PredictedSales, Lower/Upper Bounds) written back to SQL (vw_Sales_Forecast).
- Integrated into Power BI for Sales Forecasting Dashboard.

--- 

## Key Insights

- High-Value Customers: ~15% of customers contributed ~60% of revenue.
- Churn Concentration: “At Risk” customers mostly in Furniture and Office Supplies categories.
- Profitability Drivers: Technology and Copiers deliver highest profit margins.
- Forecast Trend: Sales projected to grow by ~33.8% over the next 6 months.
- Marketing Strategy: Prioritize VIP-Retention and Growth-Opportunity segments for ROI lift.

## Business Recommendations

- Launch Retention Campaigns for “At Risk” customers via personalized offers.
- Focus cross-selling on “Loyal” and “Growth Opportunity” segments.
- Enhance supply chain optimization in underperforming regions.
- Implement predictive sales monitoring for inventory planning.
- Use VIP Win-Back strategies to re-engage dormant high-value customers.

---

## Tech Stack

| Tool | Purpose |
|------|----------|
| **SQL Server** | Data modeling, RFM segmentation, churn & CLV views |
| **Python (Pandas, Prophet, SQLAlchemy)** | Data extraction, cleaning, and predictive sales forecasting |
| **Power BI** | Interactive dashboards, DAX measures, KPI visualization |
| **DAX** | KPI calculation and dynamic segmentation logic |

