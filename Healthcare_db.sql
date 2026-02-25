-- 1 How many rows of data are in the FactTable that include a Gross Charge greater than $100?
SELECT 
    COUNT(*) AS Rows_Count
FROM
    FactTable
WHERE
    FactTable.GrossCharge > 100;
    
-- 2 How many unique patients exist is the Healthcare_DB?    
SELECT 
    COUNT(DISTINCT dimPatientPK) AS UniquePatients
FROM
    dimPatient;
    

-- 	3 How many CptCodes are in each CptGrouping?
SELECT 
    CptGrouping, COUNT(DISTINCT CptCode) AS Total_CptCode
FROM
    dimCptCode
GROUP BY CptGrouping
ORDER BY Total_CptCode DESC;

-- 4 How many physicians have submitted a Medicare insurance claim?
SELECT 
    COUNT(DISTINCT f.dimphysicianPK) AS Physicians_Medicare_Claims
FROM
    FactTable f
        JOIN
    Dimpayer p ON f.dimpayerpk = p.dimpayerpk
WHERE
    p.payername = 'Medicare';
    
-- 5 Calculate the Gross Collection Rate (GCR) for each LocationName -
--  See Below GCR = Payments divided GrossCharge Which LocationName has the highest GCR?--     

SELECT l.LocationName,
SUM(f.payment) AS Total_Payments,
SUM(f.GrossCharge) AS Total_GrossCharge,

CASE 
WHEN SUM(f.GrossCharge)=0 THEN 0
ELSE  CAST(SUM(f.payment) AS DECIMAL (18,4))/SUM(f.GrossCharge)
END AS GrossCollectionRate

From FactTable f
JOIN Dimlocation l 
ON f.dimlocationPK = l.dimlocationPK
GROUP BY l.locationName
ORDER BY GrossCollectionRate DESC;

-- 	6 How many CptCodes have more than 100 units?

SELECT 
    COUNT(*) AS CPTCodes_Above_100_Units
FROM
    (SELECT 
        dimCPTCodePK, SUM(CPTUnits) AS TotalUnits
    FROM
        FactTable
    GROUP BY dimCPTCodePK
    HAVING SUM(CPTUnits) > 100) AS SubQuery;

-- 7 Find the physician specialty that has received the highest 
-- amount of payments. Then show the payments by month for this group of physicians. 

SELECT
    p.ProviderSpecialty,
    SUM(f.Payment) AS TotalPayments
FROM FactTable f
JOIN dimPhysician p
    ON f.dimPhysicianPK = p.dimPhysicianPK
GROUP BY p.ProviderSpecialty
ORDER BY SUM(f.Payment) DESC;



-- 8 How many CptUnits by DiagnosisCodeGroup are assigned to a 
-- "J code" Diagnosis (these are diagnosis codes with 
-- 	the letter J in the code)?
SELECT 
    d.DiagnosisCodeGroup, SUM(f.CPTUnits) AS TotalCPTUnits
FROM
    FactTable f
        JOIN
    dimDiagnosisCode d ON f.dimDiagnosisCodePK = d.dimDiagnosisCodePK
WHERE
    d.DiagnosisCode LIKE 'J%'
GROUP BY d.DiagnosisCodeGroup
ORDER BY TotalCPTUnits DESC;


-- 9 You've been asked to put together a report that details Patient demographics. The report should group patients into three buckets- Under 18, between 18-65, & over 65
-- 	Please include the following columns:
-- 		-First and Last name in the same column
-- 		-Email
-- 		-Patient Age
-- 		-City and State in the same column

SELECT 
    CONCAT(FirstName, ' ', LastName),
    Email,
    PatientAge,
    CASE
        WHEN PatientAGE < 18 THEN 'Under 18'
        WHEN PatientAGE BETWEEN 18 AND 65 THEN '18-65'
        ELSE 'OVER 65'
    END AS AgeBucket,
    CONCAT(City, ' ', State)
FROM
    dimpatient
ORDER BY AgeBucket , PatientAge;

-- 10 How many dollars have been written off (adjustments) due to credentialing (AdjustmentReason)?

SELECT 
    SUM(f.Adjustment) AS TotalCredentialing
FROM FactTable f
JOIN dimTransaction t
    ON f.dimTransactionPK = t.dimTransactionPK
WHERE t.AdjustmentReason = 'Credentialing';

 -- Which location has the highest number of credentialing adjustments? 
SELECT
    l.LocationName,
    SUM(f.Adjustment) AS TotalCredentialingWriteOff
FROM FactTable f
JOIN dimTransaction t
    ON f.dimTransactionPK = t.dimTransactionPK
JOIN dimLocation l
    ON f.dimLocationPK = l.dimLocationPK
WHERE t.AdjustmentReason = 'Credentialing'
GROUP BY l.LocationName
ORDER BY TotalCredentialingWriteOff DESC;

--  How many physicians at this location have been impacted by credentialing adjustments? What does this mean?

SELECT 
    COUNT(DISTINCT f.dimPhysicianPK) AS PhysiciansImpacted
FROM FactTable f
JOIN dimTransaction t
    ON f.dimTransactionPK = t.dimTransactionPK
JOIN dimLocation l
    ON f.dimLocationPK = l.dimLocationPK
WHERE t.AdjustmentReason = 'Credentialing'
  AND l.LocationName = '<<Top Location From Previous Query>>';

-- 11 What is the average patientage by gender for patients seen at Big Heart Community Hospital with a Diagnosisthat included Type 2 diabetes? And how many Patients are included in that average?


SELECT 
    p.PatientGender,
    AVG(CAST(p.PatientAge AS DECIMAL(10,2))) AS AvgPatientAge,
    COUNT(DISTINCT p.dimPatientPK) AS PatientCount
FROM FactTable f
JOIN dimPatient p
    ON f.dimPatientPK = p.dimPatientPK
JOIN dimLocation l
    ON f.dimLocationPK = l.dimLocationPK
JOIN dimDiagnosisCode d
    ON f.dimDiagnosisCodePK = d.dimDiagnosisCodePK
WHERE l.LocationName = 'Big Heart Community Hospital'
  AND d.DiagnosisCodeDescription LIKE '%Type 2%'
GROUP BY p.PatientGender
ORDER BY p.PatientGender;

-- 12 There are a two visit types that you have been asked to compare (use CptDesc).
-- 		- Office/outpatient visit est
-- 		- Office/outpatient visit new
-- Show each CptCode, CptDesc and the assocaited CptUnits.
-- What is the Charge per CptUnit? (Reduce to two decimals)
-- What does this mean? 

SELECT 
    c.CptCode,
    c.CptDesc,
    SUM(f.CPTUnits) AS TotalCPTUnits,
    ROUND(SUM(f.GrossCharge) / NULLIF(SUM(f.CPTUnits), 0),
            2) AS ChargePerCptUnit
FROM
    FactTable f
        JOIN
    dimCptCode c ON f.dimCPTCodePK = c.dimCPTCodePK
WHERE
    c.CptDesc LIKE '%Office/outpatient visit est%'
        OR c.CptDesc LIKE '%Office/outpatient visit new%'
GROUP BY c.CptCode , c.CptDesc
ORDER BY c.CptDesc;


-- 13 Similar to Question 12, you've been asked to analysis the PaymentperUnit (NOT ChargeperUnit). You've been tasked with finding the PaymentperUnit by PayerName. 
-- Do this analysis on the following visit type (CptDesc)- Initial hospital care
-- Show each CptCode, CptDesc and associated CptUnits.
-- **Note you will encounter a zero value error. If you can't remember what to do find the ifnull lecture in 
-- Section 8. 
-- What does this mean?

SELECT 
    p.PayerName,
    c.CptCode,
    c.CptDesc,
    SUM(f.CPTUnits) AS TotalCPTUnits,
    ROUND(SUM(f.Payment) / NULLIF(SUM(f.CPTUnits), 0),
            2) AS PaymentPerUnit
FROM
    FactTable f
        JOIN
    dimCptCode c ON f.dimCPTCodePK = c.dimCPTCodePK
        JOIN
    dimPayer p ON f.dimPayerPK = p.dimPayerPK
WHERE
    c.CptDesc = 'Initial hospital care'
GROUP BY p.PayerName , c.CptCode , c.CptDesc
ORDER BY p.PayerName;

-- Within the FactTable we are able to see GrossCharges. You've been asked to find the NetCharge, which means Contractual adjustments need to be subtracted from the
-- GrossCharge (GrossCharges - Contractual Adjustments).After you've found the NetCharge then calculate the Net Collection Rate (Payments/NetCharge) for each physician specialty. Which physician specialty has the worst Net Collection Rate with a NetCharge greater than $25,000? What is happening here? Where are the other dollars and why aren't they being collected?
-- What does this mean?

SELECT 
    p.ProviderSpecialty,

    SUM(f.GrossCharge) AS TotalGrossCharge,

    SUM(CASE 
            WHEN t.AdjustmentReason = 'Contractual' 
            THEN f.Adjustment 
            ELSE 0 
        END) AS ContractualAdjustments,

    SUM(f.GrossCharge) 
        - SUM(CASE 
                WHEN t.AdjustmentReason = 'Contractual' 
                THEN f.Adjustment 
                ELSE 0 
              END) AS NetCharge,

    SUM(f.Payment) AS TotalPayments,

    ROUND(
        SUM(f.Payment) /
        NULLIF(
            SUM(f.GrossCharge) 
            - SUM(CASE 
                    WHEN t.AdjustmentReason = 'Contractual' 
                    THEN f.Adjustment 
                    ELSE 0 
                  END),
        0),
    4) AS NetCollectionRate

FROM FactTable f
JOIN dimPhysician p
    ON f.dimPhysicianPK = p.dimPhysicianPK
JOIN dimTransaction t
    ON f.dimTransactionPK = t.dimTransactionPK

GROUP BY p.ProviderSpecialty
HAVING 
    SUM(f.GrossCharge) 
        - SUM(CASE 
                WHEN t.AdjustmentReason = 'Contractual' 
                THEN f.Adjustment 
                ELSE 0 
              END) > 25000

ORDER BY NetCollectionRate ASC;

-- Question 15
-- 	Build a Table that includes the following elements:
-- 		- LocationName
-- 		- CountofPhysicians
-- 		- CountofPatients
-- 		- GrossCharge
-- 		- AverageChargeperPatients 

SELECT 
    l.LocationName,
    COUNT(DISTINCT f.dimPhysicianPK) AS CountOfPhysicians,
    COUNT(DISTINCT f.dimPatientPK) AS CountOfPatients,
    SUM(f.GrossCharge) AS TotalGrossCharge,
    ROUND(SUM(f.GrossCharge) / NULLIF(COUNT(DISTINCT f.dimPatientPK), 0),
            2) AS AverageChargePerPatient
FROM
    FactTable f
        JOIN
    dimLocation l ON f.dimLocationPK = l.dimLocationPK
GROUP BY l.LocationName
ORDER BY TotalGrossCharge DESC;
