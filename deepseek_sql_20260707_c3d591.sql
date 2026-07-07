-- 101. CTE: Get grade averages, then list students above their grade average.
WITH grade_avg AS (
    SELECT grade_level, AVG(average_score) AS avg_grade_score
    FROM student_records
    GROUP BY grade_level
)
SELECT s.first_name, s.last_name, s.grade_level, s.average_score, ga.avg_grade_score
FROM student_records s
JOIN grade_avg ga ON s.grade_level = ga.grade_level
WHERE s.average_score > ga.avg_grade_score;

-- 102. CTE: Count students per teacher, filter for teachers with >10 students.
WITH teacher_counts AS (
    SELECT homeroom_teacher, COUNT(*) AS student_count
    FROM student_records
    GROUP BY homeroom_teacher
)
SELECT s.first_name, s.last_name, s.homeroom_teacher
FROM student_records s
WHERE s.homeroom_teacher IN (SELECT homeroom_teacher FROM teacher_counts WHERE student_count > 10);

-- 103. CTE: Top 3 scores per grade using RANK, then select them.
WITH ranked_students AS (
    SELECT *, RANK() OVER (PARTITION BY grade_level ORDER BY average_score DESC) AS rank
    FROM student_records
)
SELECT student_id, first_name, last_name, grade_level, average_score
FROM ranked_students
WHERE rank <= 3
ORDER BY grade_level, rank;

-- 104. Recursive CTE: Generate grades 1-12, left join to ensure all grades appear even if empty.
WITH RECURSIVE grade_series AS (
    SELECT 1 AS grade
    UNION ALL
    SELECT grade + 1 FROM grade_series WHERE grade < 12
)
SELECT gs.grade, COUNT(s.grade_level) AS student_count
FROM grade_series gs
LEFT JOIN student_records s ON s.grade_level = gs.grade
GROUP BY gs.grade
ORDER BY gs.grade;

-- 105. CTE: Overall school average, then flag students above it with a subquery.
WITH school_avg AS (
    SELECT AVG(average_score) AS overall_avg FROM student_records
)
SELECT first_name, last_name, average_score,
       CASE WHEN average_score > (SELECT overall_avg FROM school_avg) THEN 'Above School Avg' ELSE 'Below/Equal' END AS status
FROM student_records;

-- 106. CTE: Rank students within grade, then select only rank 1.
WITH grade_rank AS (
    SELECT *, RANK() OVER (PARTITION BY grade_level ORDER BY average_score DESC) AS rnk
    FROM student_records
)
SELECT * FROM grade_rank WHERE rnk = 1;

-- 107. CTE: Min and max score per grade, join to find students at extremes.
WITH grade_extremes AS (
    SELECT grade_level, MIN(average_score) AS min_score, MAX(average_score) AS max_score
    FROM student_records
    GROUP BY grade_level
)
SELECT s.first_name, s.last_name, s.grade_level, s.average_score,
       CASE WHEN s.average_score = ge.min_score THEN 'Min' 
            WHEN s.average_score = ge.max_score THEN 'Max' 
            ELSE 'Middle' END AS extreme
FROM student_records s
JOIN grade_extremes ge ON s.grade_level = ge.grade_level
WHERE s.average_score = ge.min_score OR s.average_score = ge.max_score;

-- 108. CTE: Most popular subject per grade, then list students who like that subject.
WITH popular_subjects AS (
    SELECT DISTINCT ON (grade_level) grade_level, favorite_subject, COUNT(*) AS freq
    FROM student_records
    GROUP BY grade_level, favorite_subject
    ORDER BY grade_level, freq DESC
)
SELECT s.first_name, s.last_name, s.grade_level, s.favorite_subject
FROM student_records s
JOIN popular_subjects ps ON s.grade_level = ps.grade_level AND s.favorite_subject = ps.favorite_subject;

-- 109. CTE with LAG/LEAD: Find students whose score is a local maximum (higher than both previous and next).
WITH score_comparison AS (
    SELECT student_id, first_name, last_name, grade_level, average_score,
           LAG(average_score) OVER (PARTITION BY grade_level ORDER BY average_score) AS prev_score,
           LEAD(average_score) OVER (PARTITION BY grade_level ORDER BY average_score) AS next_score
    FROM student_records
)
SELECT * FROM score_comparison
WHERE average_score > COALESCE(prev_score, 0) 
  AND average_score > COALESCE(next_score, 0);

-- 110. CTE: Union of top 5 scorers and bottom 5 scorers.
WITH top5 AS (
    SELECT student_id, first_name, last_name, average_score, 'Top 5' AS category
    FROM student_records
    ORDER BY average_score DESC
    LIMIT 5
),
bottom5 AS (
    SELECT student_id, first_name, last_name, average_score, 'Bottom 5' AS category
    FROM student_records
    ORDER BY average_score ASC
    LIMIT 5
)
SELECT * FROM top5
UNION ALL
SELECT * FROM bottom5
ORDER BY category, average_score DESC;

-- 111. Subquery in SELECT: Show each student's score alongside the average score of their grade.
SELECT first_name, last_name, grade_level, average_score,
       (SELECT AVG(average_score) FROM student_records s2 WHERE s2.grade_level = s1.grade_level) AS grade_avg
FROM student_records s1;

-- 112. EXISTS subquery: Find students who have at least one other student in the same grade with the same favorite_subject.
SELECT s1.first_name, s1.last_name, s1.grade_level, s1.favorite_subject
FROM student_records s1
WHERE EXISTS (
    SELECT 1 FROM student_records s2
    WHERE s2.grade_level = s1.grade_level
      AND s2.favorite_subject = s1.favorite_subject
      AND s2.student_id <> s1.student_id
);

-- 113. Subquery in FROM (derived table): Join grade counts back to the main table.
SELECT s.first_name, s.last_name, s.grade_level, s.average_score, gc.total_in_grade
FROM student_records s
JOIN (SELECT grade_level, COUNT(*) AS total_in_grade FROM student_records GROUP BY grade_level) gc
ON s.grade_level = gc.grade_level
WHERE s.average_score > 80;

-- 114. CTE: Cumulative sum of enrollments by year.
WITH yearly_enrollments AS (
    SELECT EXTRACT(YEAR FROM enrollment_date) AS year, COUNT(*) AS enrolled
    FROM student_records
    GROUP BY EXTRACT(YEAR FROM enrollment_date)
)
SELECT year, enrolled,
       SUM(enrolled) OVER (ORDER BY year) AS cumulative_enrollments
FROM yearly_enrollments
ORDER BY year;

-- 115. CTE: Moving average of scores over 5 rows (window function inside CTE).
WITH moving_avg AS (
    SELECT student_id, first_name, average_score,
           AVG(average_score) OVER (ORDER BY student_id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS moving_avg_5
    FROM student_records
)
SELECT * FROM moving_avg WHERE average_score > moving_avg_5;

-- 116. Subquery: Find grade(s) where the average score is higher than the overall school average.
SELECT grade_level, AVG(average_score) AS grade_avg
FROM student_records
GROUP BY grade_level
HAVING AVG(average_score) > (SELECT AVG(average_score) FROM student_records);

-- 117. CTE: Birth year averages, then join to compare student scores.
WITH year_avg AS (
    SELECT EXTRACT(YEAR FROM date_of_birth) AS birth_year, AVG(average_score) AS avg_score_year
    FROM student_records
    GROUP BY EXTRACT(YEAR FROM date_of_birth)
)
SELECT s.first_name, s.last_name, s.date_of_birth, s.average_score, ya.avg_score_year
FROM student_records s
JOIN year_avg ya ON EXTRACT(YEAR FROM s.date_of_birth) = ya.birth_year
WHERE s.average_score > ya.avg_score_year;

-- 118. Correlated subquery: Score above the average of their homeroom_teacher's students.
SELECT first_name, last_name, homeroom_teacher, average_score
FROM student_records s1
WHERE average_score > (SELECT AVG(average_score) FROM student_records s2 WHERE s2.homeroom_teacher = s1.homeroom_teacher);

-- 119. Multiple CTEs: Compare grade average vs subject average per grade.
WITH grade_avg AS (
    SELECT grade_level, AVG(average_score) AS avg_grade
    FROM student_records
    GROUP BY grade_level
),
subject_avg AS (
    SELECT grade_level, favorite_subject, AVG(average_score) AS avg_subject
    FROM student_records
    GROUP BY grade_level, favorite_subject
)
SELECT sa.grade_level, sa.favorite_subject, sa.avg_subject, ga.avg_grade,
       sa.avg_subject - ga.avg_grade AS diff_from_grade_avg
FROM subject_avg sa
JOIN grade_avg ga ON sa.grade_level = ga.grade_level
ORDER BY sa.grade_level, diff_from_grade_avg DESC;

-- 120. Ultimate advanced: CTE for percentile ranks, filter top 10% per grade, show gap to top scorer.
WITH grade_stats AS (
    SELECT grade_level,
           PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY average_score) AS p90,
           MAX(average_score) AS max_score
    FROM student_records
    GROUP BY grade_level
),
student_ranks AS (
    SELECT s.*, 
           PERCENT_RANK() OVER (PARTITION BY s.grade_level ORDER BY s.average_score) AS pct_rank,
           gs.max_score - s.average_score AS gap_to_top
    FROM student_records s
    JOIN grade_stats gs ON s.grade_level = gs.grade_level
)
SELECT student_id, first_name, last_name, grade_level, average_score, 
       ROUND(pct_rank::numeric, 4) AS percentile_rank,
       gap_to_top
FROM student_ranks
WHERE average_score >= (SELECT p90 FROM grade_stats WHERE grade_level = student_ranks.grade_level)
ORDER BY grade_level, average_score DESC;