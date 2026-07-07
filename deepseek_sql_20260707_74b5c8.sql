-- 81. Pivot: Count of students by grade and gender.
SELECT grade_level,
       COUNT(*) FILTER (WHERE gender = 'M') AS male_count,
       COUNT(*) FILTER (WHERE gender = 'F') AS female_count
FROM student_records
GROUP BY grade_level
ORDER BY grade_level;

-- 82. Pivot: Average score by grade and favorite_subject (cross-tab).
SELECT grade_level,
       AVG(average_score) FILTER (WHERE favorite_subject = 'Math') AS math_avg,
       AVG(average_score) FILTER (WHERE favorite_subject = 'Science') AS science_avg,
       AVG(average_score) FILTER (WHERE favorite_subject = 'History') AS history_avg,
       AVG(average_score) FILTER (WHERE favorite_subject = 'English') AS english_avg
FROM student_records
GROUP BY grade_level
ORDER BY grade_level;

-- 83. Distribution of letter grades per grade_level.
SELECT grade_level,
       COUNT(*) FILTER (WHERE average_score >= 90) AS A,
       COUNT(*) FILTER (WHERE average_score BETWEEN 80 AND 89) AS B,
       COUNT(*) FILTER (WHERE average_score BETWEEN 70 AND 79) AS C,
       COUNT(*) FILTER (WHERE average_score BETWEEN 60 AND 69) AS D,
       COUNT(*) FILTER (WHERE average_score < 60) AS F
FROM student_records
GROUP BY grade_level
ORDER BY grade_level;

-- 84. Percentage of students scoring above 80 per grade.
SELECT grade_level,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE average_score > 80) AS above_80,
       ROUND(100.0 * COUNT(*) FILTER (WHERE average_score > 80) / COUNT(*), 2) AS percent_above_80
FROM student_records
GROUP BY grade_level;

-- 85. Compare each student's score to the average score of their homeroom_teacher.
SELECT s.first_name, s.last_name, s.homeroom_teacher, s.average_score,
       t.teacher_avg_score,
       s.average_score - t.teacher_avg_score AS diff_from_teacher_avg
FROM student_records s
JOIN (SELECT homeroom_teacher, AVG(average_score) AS teacher_avg_score
      FROM student_records
      GROUP BY homeroom_teacher) t
ON s.homeroom_teacher = t.homeroom_teacher;

-- 86. Students who share the same birth year but are in different grades.
SELECT s1.first_name, s1.last_name, s1.grade_level, s2.first_name, s2.last_name, s2.grade_level
FROM student_records s1
JOIN student_records s2 
  ON EXTRACT(YEAR FROM s1.date_of_birth) = EXTRACT(YEAR FROM s2.date_of_birth)
 AND s1.grade_level <> s2.grade_level
 AND s1.student_id < s2.student_id;

-- 87. Teacher with the most consistent scores (smallest standard deviation).
SELECT homeroom_teacher, STDDEV(average_score) AS score_stddev
FROM student_records
GROUP BY homeroom_teacher
ORDER BY score_stddev ASC
LIMIT 1;

-- 88. Approximate correlation between attendance and score (using aggregate functions).
SELECT 
    (AVG(attendance_days * average_score) - AVG(attendance_days) * AVG(average_score)) /
    (STDDEV(attendance_days) * STDDEV(average_score)) AS correlation_coeff
FROM student_records;

-- 89. Students whose score is above the grade average by more than 10 points.
SELECT s1.*
FROM student_records s1
WHERE s1.average_score - (SELECT AVG(average_score) FROM student_records s2 WHERE s2.grade_level = s1.grade_level) > 10;

-- 90. 2nd highest score in each grade (using OFFSET within a subquery).
SELECT grade_level, average_score AS second_highest_score
FROM student_records s1
WHERE 1 = (SELECT COUNT(*) FROM student_records s2 
           WHERE s2.grade_level = s1.grade_level AND s2.average_score > s1.average_score)
ORDER BY grade_level;

-- 91. Student with the longest enrollment period (oldest enrollment date).
SELECT * FROM student_records 
WHERE enrollment_date = (SELECT MIN(enrollment_date) FROM student_records);

-- 92. Student with the shortest enrollment period (most recent enrollment).
SELECT * FROM student_records 
WHERE enrollment_date = (SELECT MAX(enrollment_date) FROM student_records);

-- 93. Number of students per birth month.
SELECT EXTRACT(MONTH FROM date_of_birth) AS birth_month, COUNT(*) AS count
FROM student_records
GROUP BY birth_month
ORDER BY birth_month;

-- 94. Most popular birth year.
SELECT EXTRACT(YEAR FROM date_of_birth) AS birth_year, COUNT(*) AS count
FROM student_records
GROUP BY birth_year
ORDER BY count DESC
LIMIT 1;

-- 95. Students with score above the median of their grade.
WITH grade_medians AS (
    SELECT grade_level, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_score) AS median
    FROM student_records
    GROUP BY grade_level
)
SELECT s.first_name, s.last_name, s.grade_level, s.average_score, gm.median
FROM student_records s
JOIN grade_medians gm ON s.grade_level = gm.grade_level
WHERE s.average_score > gm.median;

-- 96. Gap between each student's score and the next higher score in their grade.
SELECT first_name, last_name, grade_level, average_score,
       LEAD(average_score) OVER (PARTITION BY grade_level ORDER BY average_score) - average_score AS gap_to_next
FROM student_records;

-- 97. Cumulative percentage of students by score (distribution).
SELECT average_score,
       COUNT(*) AS freq,
       SUM(COUNT(*)) OVER (ORDER BY average_score) AS cumulative_freq,
       100.0 * SUM(COUNT(*)) OVER (ORDER BY average_score) / (SELECT COUNT(*) FROM student_records) AS cumulative_percent
FROM student_records
GROUP BY average_score
ORDER BY average_score;

-- 98. Ratio of male to female students per grade.
SELECT grade_level,
       COUNT(*) FILTER (WHERE gender = 'M') / NULLIF(COUNT(*) FILTER (WHERE gender = 'F'), 0) AS male_female_ratio
FROM student_records
GROUP BY grade_level
ORDER BY grade_level;

-- 99. Teacher with the widest spread of scores (max - min).
SELECT homeroom_teacher, MAX(average_score) - MIN(average_score) AS score_spread
FROM student_records
GROUP BY homeroom_teacher
ORDER BY score_spread DESC
LIMIT 1;

-- 100. Students who scored exactly the average score of their grade.
SELECT s1.*
FROM student_records s1
WHERE s1.average_score = (SELECT AVG(average_score) FROM student_records s2 WHERE s2.grade_level = s1.grade_level);