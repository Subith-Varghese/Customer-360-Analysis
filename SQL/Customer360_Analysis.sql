-- Project: Customer 360° Analytics 

-- Step 1: Create Database
CREATE DATABASE Customer360_DB;
USE Customer360_DB;
-- ============================================

-- Step 2: Inspect Table Structure
EXEC sp_columns 'dbo.Superstore';
-- Preview top 5 rows to verify dataset
SELECT TOP 5 * FROM  [Superstore 2025]
-- ============================================

-- Step 3: RFM Analysis
CREATE OR ALTER VIEW vw_RFM_Segments AS
WITH RFM_Calculation AS (
    SELECT
        Customer_ID,
        Customer_Name,
        DATEDIFF(DAY, MAX(Order_Date), (SELECT MAX(Order_Date) FROM [Superstore 2025])) AS Recency,
        COUNT(DISTINCT Order_ID) AS Frequency,
        SUM(Sales) AS Monetary
    FROM dbo.[Superstore 2025]
    GROUP BY Customer_ID, Customer_Name
),
RFM_Percentile AS (
    SELECT *,
        PERCENT_RANK() OVER (ORDER BY Recency DESC) AS Recency_Percentile,
        PERCENT_RANK() OVER (ORDER BY Frequency ASC) AS Frequency_Percentile,
        PERCENT_RANK() OVER (ORDER BY Monetary ASC) AS Monetary_Percentile
    FROM RFM_Calculation
),
RFM_Scored AS (
    SELECT *,
        CASE 
            WHEN Recency_Percentile >= 0.8 THEN 5
            WHEN Recency_Percentile >= 0.6 THEN 4
            WHEN Recency_Percentile >= 0.4 THEN 3
            WHEN Recency_Percentile >= 0.2 THEN 2
            ELSE 1
        END AS Recency_Score,
        CASE 
            WHEN Frequency_Percentile >= 0.8 THEN 5
            WHEN Frequency_Percentile >= 0.6 THEN 4
            WHEN Frequency_Percentile >= 0.4 THEN 3
            WHEN Frequency_Percentile >= 0.2 THEN 2
            ELSE 1
        END AS Frequency_Score,
        CASE 
            WHEN Monetary_Percentile >= 0.8 THEN 5
            WHEN Monetary_Percentile >= 0.6 THEN 4
            WHEN Monetary_Percentile >= 0.4 THEN 3
            WHEN Monetary_Percentile >= 0.2 THEN 2
            ELSE 1
        END AS Monetary_Score
    FROM RFM_Percentile
)
SELECT *,
    CASE 
        WHEN Recency_Score >= 4 AND Frequency_Score >= 4 AND Monetary_Score >= 4 THEN 'Champion'
        WHEN Recency_Score >= 3 AND Frequency_Score >= 3 AND Monetary_Score >= 3 THEN 'Loyal Customers'
        WHEN Monetary_Score >= 4 AND Recency_Score <= 2 THEN 'Big Spenders'
        WHEN Recency_Score <= 1 AND Frequency_Score <= 1 AND Monetary_Score <= 1 THEN 'Lost'
        WHEN Recency_Score <= 2 AND Frequency_Score <= 3 AND Monetary_Score <= 3 THEN 'At Risk'
        ELSE 'Other'
    END AS RFM_Segment
FROM RFM_Scored;
-- ============================================

-- Step 4:Churn Analysis
-- Churn by Product (Category/Sub-Category)
CREATE OR ALTER VIEW vw_Churn_Product AS
SELECT
    rfm.Customer_ID,
    rfm.Customer_Name,
    rfm.RFM_Segment,
    ss.Category,
    ss.Sub_Category,
    SUM(ss.Sales) AS TotalSales,
    SUM(ss.Profit) AS TotalProfit,
    COUNT(DISTINCT ss.Order_ID) AS OrderCount
FROM vw_RFM_Segments rfm
JOIN dbo.[Superstore 2025] ss
    ON rfm.Customer_ID = ss.Customer_ID
WHERE rfm.RFM_Segment IN ('At Risk', 'Lost')
GROUP BY rfm.Customer_ID, rfm.Customer_Name, rfm.RFM_Segment, ss.Category, ss.Sub_Category;

-- Churn by Ship Mode
CREATE OR ALTER VIEW vw_Churn_ShipMode AS
SELECT
    rfm.Customer_ID,
    rfm.Customer_Name,
    rfm.RFM_Segment,
    ss.Ship_Mode,
    SUM(ss.Sales) AS TotalSales,
    COUNT(DISTINCT ss.Order_ID) AS OrderCount
FROM vw_RFM_Segments rfm
JOIN dbo.[Superstore 2025] ss
    ON rfm.Customer_ID = ss.Customer_ID
WHERE rfm.RFM_Segment IN ('At Risk', 'Lost')
GROUP BY rfm.Customer_ID, rfm.Customer_Name, rfm.RFM_Segment, ss.Ship_Mode;

-- Churn by State / Region
CREATE OR ALTER VIEW vw_Churn_Geography AS
SELECT
    rfm.Customer_ID,
    rfm.Customer_Name,
    rfm.RFM_Segment,
    ss.Region,
    ss.State,
    SUM(ss.Sales) AS TotalSales,
    SUM(ss.Profit) AS TotalProfit,
    COUNT(DISTINCT ss.Order_ID) AS OrderCount
FROM vw_RFM_Segments rfm
JOIN dbo.[Superstore 2025] ss
    ON rfm.Customer_ID = ss.Customer_ID
WHERE rfm.RFM_Segment IN ('At Risk', 'Lost')
GROUP BY rfm.Customer_ID, rfm.Customer_Name, rfm.RFM_Segment, ss.Region, ss.State;

-- ============================================

-- Step 5: Customer Lifetime Value (CLV) Prediction
-- Historical CLV calculations WITH PREDICTIVE CLV
CREATE OR ALTER VIEW vw_Customer_CLV AS
WITH CustomerBaseMetrics AS (
	SELECT
		Customer_ID,
		SUM(Sales) AS TotalRevenue,
		SUM(Profit) AS TotalProfit,
		AVG(Sales) AS AvgSales,
		COUNT(DISTINCT Order_ID) AS TotalOrders,
		CASE 
            WHEN DATEDIFF(DAY, MIN(Order_Date), MAX(Order_Date)) = 0 THEN 1
            ELSE DATEDIFF(DAY, MIN(Order_Date), MAX(Order_Date))
        END AS CustomerTenureDays
	FROM dbo.[Superstore 2025]
	GROUP BY Customer_ID
),
CustomerDetailedMetrics AS(
	SELECT *,
		(AvgSales * (TotalOrders / CustomerTenureDays * 30.44) * 12) AS Predictive_CLV_1Year
	FROM CustomerBaseMetrics
)
SELECT * FROM CustomerDetailedMetrics;
-- ============================================

-- Step 6:  Advanced marketing segmentation using vw_RFM_Segments
select * from vw_Customer_Marketing_Matrix;

CREATE OR ALTER VIEW vw_Customer_Marketing_Matrix AS
WITH CLV_Percentile AS (
    SELECT
        rfm.Customer_ID,
        rfm.Recency,
        rfm.Frequency,
        rfm.Monetary,
        rfm.Recency_Score,
        rfm.Frequency_Score,
        rfm.Monetary_Score,
        rfm.RFM_Segment,
        clv.Predictive_CLV_1Year,
        PERCENT_RANK() OVER (
            ORDER BY clv.Predictive_CLV_1Year
        ) AS CLV_Percentile
    FROM vw_RFM_Segments rfm
    JOIN vw_Customer_CLV clv ON rfm.Customer_ID = clv.Customer_ID
)
SELECT
    Customer_ID,
    Recency,
    Frequency,
    Monetary,
    Recency_Score,
    Frequency_Score,
    Monetary_Score,
    RFM_Segment,
    Predictive_CLV_1Year,
    CASE 
        WHEN Predictive_CLV_1Year = 0 THEN 'Low Value'
        WHEN CLV_Percentile >= 0.8 THEN 'High Value'
        WHEN CLV_Percentile >= 0.2 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Value_Segment,
    -- Engagement Segment
    CASE 
        WHEN Recency_Score >= 4 AND Frequency_Score >= 4 THEN 'Highly Engaged'
        WHEN Recency_Score >= 3 AND Frequency_Score >= 3 THEN 'Moderately Engaged'
        ELSE 'Low Engaged'
    END AS Engagement_Segment,
    -- Combined Marketing Segment
    CASE 
        WHEN (CLV_Percentile >= 0.8 AND Recency_Score >= 4) THEN 'VIP-Retention'
        WHEN (CLV_Percentile >= 0.8 AND Recency_Score <= 2) THEN 'VIP-WinBack'
        WHEN (CLV_Percentile >= 0.2 AND CLV_Percentile < 0.8 AND Recency_Score >= 3) THEN 'Growth-Opportunity'
        WHEN Recency_Score <= 2 THEN 'Reactivation-Campaign'
        ELSE 'Maintenance'
    END AS Marketing_Priority
FROM CLV_Percentile; 



