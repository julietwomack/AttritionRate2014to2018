-- Calculating Exit Rate (Past 5 Years: 2014 to 2018)

USE [Human-Resources]
GO

-- Creating two new columns, YrofHire and YrofTermination
SELECT *, 
	YEAR(DateofHire) as YrofHire,
	YEAR(DateofTermination) as YrofTermination
INTO HRDataset2
FROM HRDataset
GO

-- Creating a two temp tables. One determined how many people were hired each year starting in 2014. The second one determines how many people were terminated each year starting in 2014.
SELECT YrofHire, COUNT(EmpID) AS EmpHiredPerYr
INTO #Hire
FROM HRDataset2
WHERE YrofHire >= 2014
GROUP BY YrofHire

SELECT YrofTermination, COUNT(EmpID) AS EmpTerminatedPerYr
INTO #Terminated
FROM HRDataset2
WHERE YrofTermination >= 2014
GROUP BY YrofTermination

-- Using the temp tables, creating a new column that subtracts terminated employees per year from hired employees per year
SELECT 
	A.YrofHire as Year, 
	A.EmpHiredPerYr, 
	B.EmpTerminatedPerYr, 
	A.EmpHiredPerYr - B.EmpTerminatedPerYr AS 'Hired - Left'
INTO #HT
FROM #Hire AS A 
JOIN #Terminated AS B 
ON A.YrofHire = B.YrofTermination 


-- Creating another temp table that calculates the number of employees at the start of each year from 2014 to 2018.

/* 2014 Start of the Year Employees */
SELECT '2014' AS Year, COUNT(EmpID) AS NumofEmp
INTO #StartNum
FROM HRDataset2
WHERE YrofHire < 2014 AND (YrofTermination > 2013 OR YrofTermination IS NULL)
UNION
/* 2015 Start of the Year Employees */
SELECT '2015' AS Year, COUNT(EmpID) AS NumofEmp
FROM HRDataset2
WHERE YrofHire < 2015 AND (YrofTermination > 2014 OR YrofTermination IS NULL)
UNION
/* 2016 Start of the Year Employees */
SELECT '2016' AS Year, COUNT(EmpID) AS NumofEmp 
FROM HRDataset2
WHERE YrofHire < 2016 AND (YrofTermination > 2015 OR YrofTermination IS NULL)
UNION
/* 2017 Start of the Year Employees */
SELECT '2017' AS Year, COUNT(EmpID) AS NumofEmp
FROM HRDataset2
WHERE YrofHire < 2017 AND (YrofTermination > 2016 OR YrofTermination IS NULL)
UNION
/* 2018 Start of the Year Employees */
SELECT '2018' AS Year, COUNT(EmpID) AS NumofEmp
FROM HRDataset2
WHERE YrofHire < 2018 AND (YrofTermination > 2017 OR YrofTermination IS NULL)
GO

-- Joining the #StartNum table to the #HT table, creating a new column that adds the Start Period to the End Period employee headcount, creating a new column the averages the start and end head count, and creating a column for annual attrition rate.
SELECT 
	A.Year,
	A.NumofEmp AS StartHeadCount,
	B.EmpHiredPerYr AS Hired,
	B.EmpTerminatedPerYr AS Terminated,
	B.[Hired - Left] AS 'Hired - Terminated',
	A.NumofEmp + B.[Hired - Left] AS EndHeadCount,
	(A.NumofEmp + (A.NumofEmp + B.[Hired - Left]))/2.00 AS AvgHeadCount,
	B.EmpTerminatedPerYr/((A.NumofEmp + (A.NumofEmp + B.[Hired - Left]))/2.00) AS AttritionRate
INTO AR2014to2018
FROM #StartNum AS A JOIN #HT AS B ON A.Year = B.Year
GO
