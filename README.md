Postgress problems 120 in increasing order of complexity for practise.



-- Create the school database (if not exists)
-- CREATE DATABASE IF NOT EXISTS school;
-- \c school_demo;  -- Connect to it (psql specific)

-- Drop table if it already exists (for re-runs)
DROP TABLE IF EXISTS student_records;

-- Create the main table with 12 parameters (columns)
CREATE TABLE student_records (
    student_id       SERIAL PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    date_of_birth    DATE NOT NULL,
    gender           CHAR(1) CHECK (gender IN ('M', 'F')),
    grade_level      INTEGER CHECK (grade_level BETWEEN 1 AND 12),
    homeroom_teacher VARCHAR(100),
    favorite_subject VARCHAR(50),
    average_score    DECIMAL(5,2) CHECK (average_score BETWEEN 0 AND 100),
    attendance_days  INTEGER CHECK (attendance_days >= 0),
    parent_contact   VARCHAR(100),
    enrollment_date  DATE NOT NULL
);

-- Insert 150 rows of dummy data using generate_series and random functions
INSERT INTO student_records (
    first_name,
    last_name,
    date_of_birth,
    gender,
    grade_level,
    homeroom_teacher,
    favorite_subject,
    average_score,
    attendance_days,
    parent_contact,
    enrollment_date
)
SELECT
    -- Random first name from a list of 20 common names
    (ARRAY['Emma','Liam','Olivia','Noah','Ava','Ethan','Sophia','Mason','Isabella','Logan',
            'Mia','Lucas','Amelia','Benjamin','Harper','Elijah','Evelyn','Oliver','Abigail','Jacob'])[floor(random()*20)+1] AS first_name,

    -- Random last name from a list of 15 surnames
    (ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez',
            'Hernandez','Lopez','Wilson','Anderson','Thomas'])[floor(random()*15)+1] AS last_name,

    -- Random date of birth: between 2000-01-01 and 2015-12-31
    DATE '2000-01-01' + (random() * (DATE '2015-12-31' - DATE '2000-01-01'))::INTEGER AS date_of_birth,

    -- Gender: M or F (roughly 50/50)
    CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END AS gender,

    -- Grade level: 1 through 12
    floor(random() * 12 + 1)::INTEGER AS grade_level,

    -- Random homeroom teacher from a list
    (ARRAY['Ms. Smith','Mr. Johnson','Mrs. Williams','Dr. Brown','Ms. Jones','Mr. Garcia',
            'Mrs. Miller','Dr. Davis','Ms. Rodriguez','Mr. Martinez'])[floor(random()*10)+1] AS homeroom_teacher,

    -- Random favorite subject
    (ARRAY['Math','Science','History','English','Art','Music','Physical Education','Computer Science',
            'Foreign Language','Geography'])[floor(random()*10)+1] AS favorite_subject,

    -- Average score: between 40 and 100, with one decimal
    round((random() * 60 + 40)::NUMERIC, 1) AS average_score,

    -- Attendance days: between 120 and 200 (typical school year ~180 days)
    floor(random() * 81 + 120)::INTEGER AS attendance_days,

    -- Parent contact: random phone number (formatted) or email
    CASE WHEN random() < 0.7 THEN
        -- Phone: (XXX) XXX-XXXX
        '(' || (floor(random()*900+100)::INTEGER) || ') ' ||
        (floor(random()*900+100)::INTEGER) || '-' ||
        (floor(random()*9000+1000)::INTEGER)
    ELSE
        -- Email: firstname.lastname@example.com (lowercase)
        lower(
            (ARRAY['Emma','Liam','Olivia','Noah','Ava','Ethan','Sophia','Mason','Isabella','Logan',
                   'Mia','Lucas','Amelia','Benjamin','Harper','Elijah','Evelyn','Oliver','Abigail','Jacob'])[floor(random()*20)+1]
        ) || '.' ||
        lower(
            (ARRAY['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez',
                   'Hernandez','Lopez','Wilson','Anderson','Thomas'])[floor(random()*15)+1]
        ) || '@example.com'
    END AS parent_contact,

    -- Enrollment date: within the last 5 years (2019-01-01 to 2024-12-31)
    DATE '2019-01-01' + (random() * (DATE '2024-12-31' - DATE '2019-01-01'))::INTEGER AS enrollment_date

FROM generate_series(1, 150) AS g;


