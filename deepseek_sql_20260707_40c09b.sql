-- 61. Dense rank overall by score.
SELECT first_name, last_name, average_score,
       DENSE_RANK() OVER (ORDER BY average_score DESC) AS overall_dense_rank
FROM student_records;

-- 62. Row number per grade ordered by score descending.
SELECT first_name, last_name, grade_level, average_score,
       ROW_NUMBER() OVER (PARTITION BY grade_level ORDER BY average_score DESC) AS row_num
FROM student_records;

-- 63. LAG: previous student's score within the same grade.
SELECT first_name, last_name, grade_level, average_score,
       LAG(average_score) OVER (PARTITION BY grade_level ORDER BY average_score) AS previous_score
FROM student_records;

-- 64. LEAD: next student's score within the same grade.
SELECT first_name, last_name, grade_level, average_score,
       LEAD(average_score) OVER (PARTITION BY grade_level ORDER BY average_score) AS next_score
FROM student_records;

-- 65. Moving average of scores over 3 preceding rows (ordered by student_id).
SELECT student_id, first_name, average_score,
       AVG(average_score) OVER (ORDER BY student_id ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS moving_avg_3
FROM student_records;

-- 66. Percentile rank of each student by score.
SELECT first_name, average_score,
       PERCENT_RANK() OVER (ORDER BY average_score) AS percentile_rank
FROM student_records;

-- 67. Students who have the maximum score in their grade (correlated subquery).
SELECT * FROM student_records s1
WHERE average_score = (SELECT MAX(average_score) FROM student_records s2 WHERE s2.grade_level = s1.grade_level);

-- 68. Students who have the minimum score in their grade.
SELECT * FROM student_records s1
WHERE average_score = (SELECT MIN(average_score) FROM student_records s2 WHERE s2.grade_level = s1.grade_level);

-- 69. Grade with the highest average score.
SELECT grade_level, AVG(average_score) AS avg_score
FROM student_records
GROUP BY grade_level
ORDER BY avg_score DESC
LIMIT 1;

-- 70. Teacher with the highest average student score.
SELECT homeroom_teacher, AVG(average_score) AS avg_score
FROM student_records
GROUP BY homeroom_teacher
ORDER BY avg_score DESC
LIMIT 1;

-- 71. Most common favorite_subject per grade.
SELECT DISTINCT ON (grade_level) grade_level, favorite_subject, COUNT(*) AS count
FROM student_records
GROUP BY grade_level, favorite_subject
ORDER BY grade_level, count DESC;

-- 72. Students scoring more than 1 standard deviation above their grade average.
SELECT first_name, last_name, grade_level, average_score
FROM student_records s1
WHERE average_score > (SELECT AVG(average_score) + STDDEV(average_score) 
                       FROM student_records s2 WHERE s2.grade_level = s1.grade_level);

-- 73. Cumulative sum of attendance_days ordered by enrollment_date.
SELECT student_id, first_name, enrollment_date, attendance_days,
       SUM(attendance_days) OVER (ORDER BY enrollment_date) AS cumulative_attendance
FROM student_records;

-- 74. Students with a higher score than the previous student in the same grade.
SELECT first_name, last_name, grade_level, average_score,
       LAG(average_score) OVER (PARTITION BY grade_level ORDER BY average_score) AS prev_score
FROM student_records
WHERE average_score > LAG(average_score) OVER (PARTITION BY grade_level ORDER BY average_score);

-- 75. Students with the same favorite_subject as student with ID = 1.
SELECT * FROM student_records
WHERE favorite_subject = (SELECT favorite_subject FROM student_records WHERE student_id = 1)
AND student_id <> 1;

-- 76. Find duplicate parent_contact emails (if any).
SELECT parent_contact, COUNT(*) 
FROM student_records 
WHERE parent_contact LIKE '%@%' 
GROUP BY parent_contact 
HAVING COUNT(*) > 1;

-- 77. Students who enrolled before turning 10 years old (enrollment date vs birth date).
SELECT first_name, last_name, date_of_birth, enrollment_date
FROM student_records
WHERE EXTRACT(YEAR FROM AGE(enrollment_date, date_of_birth)) < 10;

-- 78. Median score using PERCENTILE_CONT (PostgreSQL).
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_score) AS median_score
FROM student_records;

-- 79. Low attendance AND low score (below 150 days AND below 60).
SELECT * FROM student_records WHERE attendance_days < 150 AND average_score < 60;

-- 80. Top 3 students per grade (using window function).
SELECT student_id, first_name, last_name, grade_level, average_score, grade_rank
FROM (
    SELECT *, RANK() OVER (PARTITION BY grade_level ORDER BY average_score DESC) AS grade_rank
    FROM student_records
) ranked
WHERE grade_rank <= 3;