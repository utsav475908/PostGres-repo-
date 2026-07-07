-- 31. Find last_names containing 'son'.
SELECT * FROM student_records WHERE last_name LIKE '%son%';

-- 32. Find students in grades 1, 3, or 5 using IN.
SELECT * FROM student_records WHERE grade_level IN (1, 3, 5);

-- 33. Find students born between 2005-01-01 and 2008-12-31.
SELECT * FROM student_records WHERE date_of_birth BETWEEN '2005-01-01' AND '2008-12-31';

-- 34. Show full_name as concatenation of first and last name.
SELECT CONCAT(first_name, ' ', last_name) AS full_name, grade_level FROM student_records;

-- 35. Extract the year from enrollment_date.
SELECT first_name, last_name, EXTRACT(YEAR FROM enrollment_date) AS enrollment_year FROM student_records;

-- 36. Calculate the age of each student (as of 2026-07-07).
SELECT first_name, last_name, 
       EXTRACT(YEAR FROM AGE('2026-07-07', date_of_birth)) AS age 
FROM student_records;

-- 37. Categorize average_score into letter grades using CASE.
SELECT first_name, last_name, average_score,
       CASE 
           WHEN average_score >= 90 THEN 'A'
           WHEN average_score >= 80 THEN 'B'
           WHEN average_score >= 70 THEN 'C'
           WHEN average_score >= 60 THEN 'D'
           ELSE 'F'
       END AS letter_grade
FROM student_records;

-- 38. Count how many students fall into each letter grade category.
SELECT 
    CASE 
        WHEN average_score >= 90 THEN 'A'
        WHEN average_score >= 80 THEN 'B'
        WHEN average_score >= 70 THEN 'C'
        WHEN average_score >= 60 THEN 'D'
        ELSE 'F'
    END AS letter_grade,
    COUNT(*) AS count
FROM student_records
GROUP BY letter_grade
ORDER BY letter_grade;

-- 39. Grade levels with an average score greater than 75 (HAVING).
SELECT grade_level, AVG(average_score) AS avg_grade_score
FROM student_records
GROUP BY grade_level
HAVING AVG(average_score) > 75;

-- 40. Teachers with more than 15 students.
SELECT homeroom_teacher, COUNT(*) AS student_count
FROM student_records
GROUP BY homeroom_teacher
HAVING COUNT(*) > 15;

-- 41. Students with attendance_days below the average attendance of their grade (subquery).
SELECT first_name, last_name, grade_level, attendance_days
FROM student_records s1
WHERE attendance_days < (SELECT AVG(attendance_days) FROM student_records s2 WHERE s2.grade_level = s1.grade_level);

-- 42. Students with average_score above the overall school average.
SELECT * FROM student_records 
WHERE average_score > (SELECT AVG(average_score) FROM student_records);

-- 43. Find the oldest student (minimum date_of_birth).
SELECT * FROM student_records 
WHERE date_of_birth = (SELECT MIN(date_of_birth) FROM student_records);

-- 44. Find the youngest student (maximum date_of_birth).
SELECT * FROM student_records 
WHERE date_of_birth = (SELECT MAX(date_of_birth) FROM student_records);

-- 45. Students whose score is higher than the average score of their grade (correlated subquery).
SELECT first_name, last_name, grade_level, average_score
FROM student_records s1
WHERE average_score > (SELECT AVG(average_score) FROM student_records s2 WHERE s2.grade_level = s1.grade_level);

-- 46. Count students per teacher, ordered from most to least.
SELECT homeroom_teacher, COUNT(*) AS student_count
FROM student_records
GROUP BY homeroom_teacher
ORDER BY student_count DESC;

-- 47. Students enrolled before 2020.
SELECT * FROM student_records WHERE enrollment_date < '2020-01-01';

-- 48. (No NULLs in our data, but find students where parent_contact is NULL – just for demo).
SELECT * FROM student_records WHERE parent_contact IS NULL;

-- 49. Top 5 most popular favorite_subject.
SELECT favorite_subject, COUNT(*) AS count
FROM student_records
GROUP BY favorite_subject
ORDER BY count DESC
LIMIT 5;

-- 50. Bottom 5 least popular favorite_subject.
SELECT favorite_subject, COUNT(*) AS count
FROM student_records
GROUP BY favorite_subject
ORDER BY count ASC
LIMIT 5;

-- 51. Students with exactly 180 attendance_days.
SELECT * FROM student_records WHERE attendance_days = 180;

-- 52. High-achieving and highly attending students (score > 90, attendance > 160).
SELECT * FROM student_records WHERE average_score > 90 AND attendance_days > 160;

-- 53. Students with a failing score (below 50).
SELECT * FROM student_records WHERE average_score < 50;

-- 54. Average score for each homeroom_teacher, rounded to 2 decimals.
SELECT homeroom_teacher, ROUND(AVG(average_score), 2) AS avg_score
FROM student_records
GROUP BY homeroom_teacher;

-- 55. Average attendance for each favorite_subject.
SELECT favorite_subject, AVG(attendance_days) AS avg_attendance
FROM student_records
GROUP BY favorite_subject;

-- 56. Grade levels with more than 15 students.
SELECT grade_level, COUNT(*) AS count
FROM student_records
GROUP BY grade_level
HAVING COUNT(*) > 15;

-- 57. Rank students within each grade by score (using RANK – basic window intro).
SELECT first_name, last_name, grade_level, average_score,
       RANK() OVER (PARTITION BY grade_level ORDER BY average_score DESC) AS grade_rank
FROM student_records;

-- 58. Difference between each student's score and the minimum score in their grade.
SELECT first_name, last_name, grade_level, average_score,
       average_score - MIN(average_score) OVER (PARTITION BY grade_level) AS diff_from_grade_min
FROM student_records;

-- 59. Find students who share the same last_name (basic self-join).
SELECT s1.first_name, s1.last_name, s2.first_name AS other_first_name
FROM student_records s1
JOIN student_records s2 ON s1.last_name = s2.last_name AND s1.student_id < s2.student_id;

-- 60. Pairs of students in the same grade (self-join).
SELECT s1.first_name || ' & ' || s2.first_name AS pair, s1.grade_level
FROM student_records s1
JOIN student_records s2 ON s1.grade_level = s2.grade_level AND s1.student_id < s2.student_id;