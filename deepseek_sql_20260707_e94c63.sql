-- 1. Select all columns for all students.
SELECT * FROM student_records;

-- 2. Select first and last name, and grade level only.
SELECT first_name, last_name, grade_level FROM student_records;

-- 3. Select students in grade 5.
SELECT * FROM student_records WHERE grade_level = 5;

-- 4. Select students born after January 1, 2010.
SELECT * FROM student_records WHERE date_of_birth > '2010-01-01';

-- 5. Select students with an average_score of 80 or higher.
SELECT * FROM student_records WHERE average_score >= 80;

-- 6. Select students with attendance_days less than 150.
SELECT * FROM student_records WHERE attendance_days < 150;

-- 7. Select all students ordered by last_name alphabetically.
SELECT * FROM student_records ORDER BY last_name;

-- 8. Select all students ordered by average_score descending.
SELECT * FROM student_records ORDER BY average_score DESC;

-- 9. Select distinct gender values.
SELECT DISTINCT gender FROM student_records;

-- 10. Select distinct homeroom_teacher values.
SELECT DISTINCT homeroom_teacher FROM student_records;

-- 11. Select the first 10 students only.
SELECT * FROM student_records LIMIT 10;

-- 12. Select students whose favorite_subject is 'Math'.
SELECT * FROM student_records WHERE favorite_subject = 'Math';

-- 13. Select female students in grade 10.
SELECT * FROM student_records WHERE gender = 'F' AND grade_level = 10;

-- 14. Select students whose last_name starts with 'S'.
SELECT * FROM student_records WHERE last_name LIKE 'S%';

-- 15. Select students with average_score between 70 and 90 inclusive.
SELECT * FROM student_records WHERE average_score BETWEEN 70 AND 90;

-- 16. Count the total number of students.
SELECT COUNT(*) AS total_students FROM student_records;

-- 17. Count the number of students per grade_level.
SELECT grade_level, COUNT(*) AS students_per_grade FROM student_records GROUP BY grade_level;

-- 18. Calculate the overall average score of all students.
SELECT AVG(average_score) AS school_avg_score FROM student_records;

-- 19. Find the maximum average_score among all students.
SELECT MAX(average_score) AS highest_score FROM student_records;

-- 20. Find the minimum attendance_days.
SELECT MIN(attendance_days) AS min_attendance FROM student_records;

-- 21. Sum of attendance_days per grade.
SELECT grade_level, SUM(attendance_days) AS total_attendance FROM student_records GROUP BY grade_level;

-- 22. Count students by gender.
SELECT gender, COUNT(*) AS count FROM student_records GROUP BY gender;

-- 23. Average score per homeroom_teacher.
SELECT homeroom_teacher, AVG(average_score) AS avg_teacher_score FROM student_records GROUP BY homeroom_teacher;

-- 24. Count students per favorite_subject.
SELECT favorite_subject, COUNT(*) AS count FROM student_records GROUP BY favorite_subject;

-- 25. Average attendance per grade.
SELECT grade_level, AVG(attendance_days) AS avg_attendance FROM student_records GROUP BY grade_level;

-- 26. Select students enrolled in the year 2023.
SELECT * FROM student_records WHERE EXTRACT(YEAR FROM enrollment_date) = 2023;

-- 27. Select students born in the year 2005.
SELECT * FROM student_records WHERE EXTRACT(YEAR FROM date_of_birth) = 2005;

-- 28. Select students whose parent_contact contains '@' (likely email).
SELECT * FROM student_records WHERE parent_contact LIKE '%@%';

-- 29. Select students who attended more than 170 days.
SELECT * FROM student_records WHERE attendance_days > 170;

-- 30. Select the top 5 students with the highest average_score.
SELECT * FROM student_records ORDER BY average_score DESC LIMIT 5;