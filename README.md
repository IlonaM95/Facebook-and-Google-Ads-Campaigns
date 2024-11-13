# Facebook and Google Ads Campaigns
***Data preparation including calculation of metrics and KPIs for Facebook and Google advertising campaigns (PostgreSQL)***
<br>
<br>
## Overview
This project involves preparing data (PostgreSQL, DBeaver) relating to advertising campaigns conducted on Facebook and Google, aimed at further analysis and dashboard creation.
<br>
<br>
## Project details
**The data comes from 4 different tables:**
- 3 tables related to Facebook campaigns,
- 1 table related to Google campaigns.
### Using Common Table Expressions (CTEs), the following steps were performed:
1. **Merging of tables:**
   - information related to Facebook campaigns was merged using LEFT JOINs,
   - appropriate Google campaigns data was then appended using UNION ALL,
   - NULL values were replaced with zeros.
     
     ![left_join_union_all](https://github.com/user-attachments/assets/e3ca7dc9-84b7-444c-9f17-cb8b128e09b1)

2. **Data extraction:**
   - months were extracted from date fields,
   - campaign names were extracted from URL parameters using regular expressions.
3. **Metrics and KPIs calculation:**
   - calculated the following metrics and KPIs: Total spend, Total impressions, Total clicks, Total value, CPC, CPM, CTR and ROMI (with zero division error handling),
   - using window functions, calculated the Month-over-Month (MoM) growth rate for CTR, CPM, and ROMI.
<br>

## Result
The resulting table was saved as a materialized view for efficient querying and analysis.

<br>

![materialized_view_1](https://github.com/user-attachments/assets/7055884e-d199-420b-86ff-d02b3e27e6f3)

![materialized_view_2](https://github.com/user-attachments/assets/47445f79-cad6-49ae-8d84-e80b6aa9d58d)

