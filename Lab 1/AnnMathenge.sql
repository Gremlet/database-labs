USE everyloop;

GO

-- Moon Missions

DROP TABLE IF EXISTS SuccessfulMissions;

GO

SELECT
    [Spacecraft],
    [Launch date],
    [Carrier rocket],
    [Operator],
    [Mission type]
INTO SuccessfulMissions
FROM MoonMissions
WHERE [Outcome] = 'Successful';

GO

UPDATE SuccessfulMissions 
SET Operator = TRIM(' ' FROM Operator);

GO

UPDATE SuccessfulMissions
SET [Spacecraft] = TRIM(LEFT([Spacecraft], CHARINDEX('(', [Spacecraft]) - 1))
WHERE CHARINDEX('(', [Spacecraft]) > 0;

GO

SELECT
    [Operator],
    [Mission type],
    COUNT(*) 
AS [Mission count]
FROM SuccessfulMissions
GROUP BY [Operator], [Mission type]
HAVING COUNT(*) > 1
ORDER BY [Operator], [Mission type];

GO

-- Users

DROP TABLE IF EXISTS NewUsers;

GO

SELECT
    ID,
    UserName,
    [Password],
    CONCAT(FirstName, ' ', LastName) AS [Name],
    CASE WHEN
        CAST(SUBSTRING(ID, 10, 1) AS int) % 2 = 0
        THEN 'Female'
        ELSE 'Male'
    END AS Gender,
    Email,
    Phone
INTO NewUsers
FROM Users;

GO

SELECT
    [UserName],
    COUNT(*) 
AS [Repeated]
FROM NewUsers
GROUP BY [UserName]
HAVING COUNT([UserName]) > 1;

GO

UPDATE NewUsers
SET UserName = 'sipett'
WHERE ID = '811008-5301';

UPDATE NewUsers
SET UserName = 'sigter'
WHERE ID = '630303-4894';

UPDATE NewUsers
SET UserName = 'lixber'
WHERE ID = '880706-3713';

GO

DELETE FROM NewUsers
WHERE CAST(LEFT(ID, 2) AS int) < 70
    AND [Gender] = 'Female';

GO

INSERT INTO NewUsers
    (
    ID,
    UserName,
    [Password],
    [Name],
    Gender,
    Email,
    Phone
    )
VALUES
    (
        '830113-2345',
        'annmat',
        '6abdd35d1f774c0d98d588dcd1d0feff',
        'Ann Mathenge',
        'Female',
        'ann.mathenge@iths.se',
        '076-1234567'
);

GO

SELECT
    Gender,
    AVG(DATEDIFF(YEAR, CONVERT(date, '19' + LEFT(ID, 6), 112), GETDATE())) AS [Average age]
FROM NewUsers
GROUP BY Gender;

GO

-- Company (joins)

SELECT
    p.Id AS [Id],
    p.ProductName AS [Product],
    s.CompanyName AS [Supplier],
    c.CategoryName AS [Category]
FROM company.products AS p
    JOIN company.suppliers AS s
    ON p.SupplierId = s.Id
    JOIN company.categories AS c
    ON p.CategoryId = c.Id;

GO

SELECT
    r.RegionDescription,
    COUNT(DISTINCT e.Id) AS [Employee count]
FROM company.employees AS e
    JOIN company.employee_territory AS et
    ON e.Id = et.EmployeeId
    JOIN company.territories AS t
    ON et.TerritoryId = t.Id
    JOIN company.regions AS r
    ON t.RegionId = r.Id
GROUP BY r.RegionDescription;

GO

SELECT
    e.Id AS [Id],
    CONCAT(e.TitleOfCourtesy, ' ', e.FirstName, ' ', e.LastName) AS [Name],
    CASE
        WHEN e.ReportsTo IS NULL
            THEN 'Nobody!'
        ELSE CONCAT(m.TitleOfCourtesy, ' ', m.FirstName, ' ', m.LastName)
    END AS [Reports to]
FROM company.employees AS e
    LEFT JOIN company.employees AS m
    ON e.ReportsTo = m.Id
ORDER BY e.Id;