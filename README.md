****📊 Healthcare Database SQL Analytics Project****

/
This project contains a collection of advanced SQL queries built on a healthcare data warehouse designed using a star schema structure. The database includes a central FactTable connected to multiple dimension tables such as:

**dimPatient**

**dimPhysician**

**dimLocation**
 
**dimDiagnosisCode**

**dimCptCode**

**dimTransaction**

**dimPayer**

**dimDate**

The goal of this project is to analyze healthcare operations, financial performance, and patient demographics using real-world business scenarios.

**🔍 Key Business Questions Solved**

This SQL file answers critical healthcare analytics questions, including:

**💰 Financial Performance & Revenue Analytics**
Count of encounters with Gross Charges > $100

Gross Collection Rate (GCR) by location

Total credentialing write-offs (adjustments)

Location with highest adjustment impact

Payments by physician specialty

CPT codes exceeding 100 total units

**🏥 Operational Insights**
Physicians submitting Medicare claims

CPT code distribution by grouping

Diagnosis-based CPT unit analysis (e.g., "J code" diagnoses)

Impact of credentialing adjustments on physicians

**👩‍⚕️ Patient Demographics & Population Health**
Unique patient counts

Patient age segmentation (Under 18, 18–65, Over 65)

Gender-based average age analysis

Diabetes (Type 2) patient analysis by location

**🧠 Skills Demonstrated**

Complex JOIN operations across multiple dimension tables

Aggregations using SUM(), COUNT(), AVG()

CASE statements for business logic segmentation

Subqueries with HAVING clauses

Data quality handling (e.g., division-by-zero prevention)

Real-world healthcare KPI calculations

**📈 Business Impact**

This project simulates real healthcare analytics reporting, helping stakeholders:

Monitor revenue cycle performance

Evaluate physician and specialty performance

Identify financial leakage (adjustments/write-offs)

Analyze patient demographics and disease trends

Support operational and strategic decision-making

**🛠 Technologies Used**

**SQL (T-SQL compatible syntax)**
**Relational Database Design (Star Schema)**
**Healthcare Revenue Cycle Concepts**
