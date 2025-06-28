# 📊 Power BI Service – Contoso Workspace

![Power BI Pro](https://github.com/user-attachments/assets/6e4eef0e-63f9-47b5-a779-6b9c74c82543)


## 🧾 Type of Service
**Business Intelligence (BI) and data visualization service** powered by **Microsoft Power BI Pro**.

It enables organizations to connect to data sources, transform raw data into semantic models, create visual reports, and share dashboards that support data-driven decision-making.

---

## 🧩 Components and Features

### 1. Data Source
- **SQL Server** as the primary data source.
- Connected via a **gateway**, enabling automatic data refresh from on-premises infrastructure.

### 2. Semantic Model
- Name: `Contoso`
- Type: **Semantic model** (data model).
- Last refreshed: `June 28, 2025, 2:00:44 PM`.
- Acts as the central data source for reports.

### 3. Reports
- `Contoso Report` – the main analytical report.
- `Contoso Mobile` – a version optimized for mobile devices.

### 4. Dashboard
- `Contoso Dashboard` – aggregates key visuals from reports.
- Used for high-level KPI monitoring and quick insights.

### 5. Management and Administration
- Features: `Import`, `Migrate`, `Manage Access`, `Update App`.
- Used for version control, data migration, access management, and publishing content.

---

## 🔄 How the Service Works – Step by Step

1. **Data Connection**  
   The service connects to a local SQL Server via a gateway to retrieve up-to-date data.

2. **Semantic Model Creation**  
   Data is transformed and published as a semantic model, which serves as the foundation for all connected reports.

3. **Report Development**  
   Visual reports are created based on the semantic model—one of which is optimized for mobile viewing.

4. **Dashboard Creation**  
   Selected visuals from the reports are pinned to a dashboard for consolidated monitoring and alerting.

5. **Sharing and Publishing**  
   The content (reports and dashboards) is shared with end users through the Power BI app, with role-based access control.

---

> 🔐 **Security and Access:**  
> The service enforces report-, dashboard-, and dataset-level access controls using RBAC (Role-Based Access Control).
