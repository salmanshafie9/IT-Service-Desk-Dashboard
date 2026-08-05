-- ============================================
-- PROJECT: IT Service Desk Performance Analysis
-- ============================================


-- ============================================
-- 1. TOTAL TICKETS
-- ============================================

SELECT
    COUNT(*) AS total_tickets
FROM Tickets;


-- ============================================
-- 2. OPEN TICKETS
-- ============================================

SELECT
    COUNT(*) AS open_tickets
FROM Tickets
WHERE Status = 'Open';


-- ============================================
-- 3. RESOLVED TICKETS
-- ============================================

SELECT
    COUNT(*) AS resolved_tickets
FROM Tickets
WHERE Status = 'Resolved';


-- ============================================
-- 4. HIGH PRIORITY TICKETS
-- ============================================

SELECT
    COUNT(*) AS high_priority_tickets
FROM Tickets
WHERE Priority = 'High';


-- ============================================
-- 5. KPI SUMMARY
-- ============================================

SELECT
    COUNT(*) AS total_tickets,

    SUM(CASE
        WHEN Status = 'Open'
        THEN 1 ELSE 0
    END) AS open_tickets,

    SUM(CASE
        WHEN Status = 'Resolved'
        THEN 1 ELSE 0
    END) AS resolved_tickets,

    SUM(CASE
        WHEN Priority = 'High'
        THEN 1 ELSE 0
    END) AS high_priority_tickets,

    SUM(CASE
        WHEN Status = 'Resolved'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS resolution_rate

FROM Tickets;


-- ============================================
-- 6. TICKETS BY TEAM
-- ============================================

SELECT
    t.TeamName,
    COUNT(*) AS total_tickets

FROM Tickets tk
LEFT JOIN Teams t
    ON tk.TeamID = t.TeamID

GROUP BY t.TeamName
ORDER BY total_tickets DESC;


-- ============================================
-- 7. OPEN AND RESOLVED TICKETS BY TEAM
-- ============================================

SELECT
    t.TeamName,

    COUNT(*) AS total_tickets,

    SUM(CASE
        WHEN tk.Status = 'Open'
        THEN 1 ELSE 0
    END) AS open_tickets,

    SUM(CASE
        WHEN tk.Status = 'Resolved'
        THEN 1 ELSE 0
    END) AS resolved_tickets

FROM Tickets tk
LEFT JOIN Teams t
    ON tk.TeamID = t.TeamID

GROUP BY t.TeamName
ORDER BY total_tickets DESC;


-- ============================================
-- 8. HIGH PRIORITY TICKETS BY TEAM
-- ============================================

SELECT
    t.TeamName,

    COUNT(*) AS total_tickets,

    SUM(CASE
        WHEN tk.Priority = 'High'
        THEN 1 ELSE 0
    END) AS high_priority_tickets

FROM Tickets tk
LEFT JOIN Teams t
    ON tk.TeamID = t.TeamID

GROUP BY t.TeamName
ORDER BY high_priority_tickets DESC;


-- ============================================
-- 9. RESOLUTION RATE BY TEAM
-- ============================================

SELECT
    t.TeamName,

    COUNT(*) AS total_tickets,

    SUM(CASE
        WHEN tk.Status = 'Resolved'
        THEN 1 ELSE 0
    END) AS resolved_tickets,

    SUM(CASE
        WHEN tk.Status = 'Resolved'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS resolution_rate

FROM Tickets tk
LEFT JOIN Teams t
    ON tk.TeamID = t.TeamID

GROUP BY t.TeamName
ORDER BY resolution_rate DESC;


-- ============================================
-- 10. TEAM SUMMARY USING A CTE
-- ============================================

WITH TeamSummary AS
(
    SELECT
        TeamID,

        COUNT(*) AS total_tickets,

        SUM(CASE
            WHEN Status = 'Open'
            THEN 1 ELSE 0
        END) AS open_tickets,

        SUM(CASE
            WHEN Status = 'Resolved'
            THEN 1 ELSE 0
        END) AS resolved_tickets,

        SUM(CASE
            WHEN Priority = 'High'
            THEN 1 ELSE 0
        END) AS high_priority_tickets

    FROM Tickets

    GROUP BY TeamID
)

SELECT
    t.TeamName,
    ts.total_tickets,
    ts.open_tickets,
    ts.resolved_tickets,
    ts.high_priority_tickets,

    ts.resolved_tickets * 100.0
        / ts.total_tickets AS resolution_rate

FROM TeamSummary ts
LEFT JOIN Teams t
    ON ts.TeamID = t.TeamID

ORDER BY resolution_rate DESC;


-- ============================================
-- 11. TEAM PERFORMANCE RANKING
-- ============================================

WITH TeamSummary AS
(
    SELECT
        TeamID,

        COUNT(*) AS total_tickets,

        SUM(CASE
            WHEN Status = 'Open'
            THEN 1 ELSE 0
        END) AS open_tickets,

        SUM(CASE
            WHEN Status = 'Resolved'
            THEN 1 ELSE 0
        END) AS resolved_tickets,

        SUM(CASE
            WHEN Priority = 'High'
            THEN 1 ELSE 0
        END) AS high_priority_tickets

    FROM Tickets

    GROUP BY TeamID
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            ts.resolved_tickets * 100.0
            / ts.total_tickets DESC
    ) AS team_rank,

    t.TeamName,
    ts.total_tickets,
    ts.open_tickets,
    ts.resolved_tickets,
    ts.high_priority_tickets,

    ts.resolved_tickets * 100.0
        / ts.total_tickets AS resolution_rate

FROM TeamSummary ts
LEFT JOIN Teams t
    ON ts.TeamID = t.TeamID

ORDER BY team_rank;