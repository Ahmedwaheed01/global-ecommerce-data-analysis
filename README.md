# Global E-Commerce Data Analysis

## DEPI – Data Analyst Specialist

A complete e-commerce data analysis project developed as part of the Digital Egypt Pioneers Initiative (DEPI) Data Analyst Specialist track.

## Project Overview

This project analyzes retail transaction data to understand:

- Sales and revenue performance
- Product performance
- Customer behavior
- Country performance
- Customer segmentation using RFM analysis

The project follows a complete data analysis workflow:

**Data Cleaning → Python Analysis → SQL Analysis → Power BI Dashboard → Business Insights**

## Project Components

### Python
`Notebook/Online_Retail_Analysis.ipynb`

Includes data cleaning, exploratory analysis, product and customer analysis, country analysis, and RFM segmentation.

### SQL
`sql/retail_sales_analysis.sql`

Contains SQLite queries for revenue, orders, customers, products, countries, customer behavior, and RFM preparation.

### Power BI
`powerbi/Global-Ecommerce.pbix`

Interactive dashboard presenting the project's main business insights and analysis.

## Dataset

The project uses an online retail transaction dataset containing information such as:

- Invoice Number
- Product Description
- Quantity
- Invoice Date
- Unit Price
- Customer ID
- Country
- Total Sales

## Technologies

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn
- Jupyter Notebook
- SQL / SQLite
- Power BI
- DAX

## Project Structure

```text
Global-Ecommerce-Project/
│
├── DataSet/
│   ├── online_retail.csv
│   ├── cleaned_data.csv
│   └── rfm/
│       └── rfm_segments.csv
│
├── Notebook/
│   └── Online_Retail_Analysis.ipynb
│
├── powerbi/
│   └── Global-Ecommerce.pbix
│
├── report/
│   └── project_roadmap.png
│
├── sql/
│   └── retail_sales_analysis.sql
│
├── README.md
└── requirements.txt