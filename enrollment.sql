DROP DATABASE IF EXISTS enrollment;
CREATE DATABASE enrollment;
USE enrollment;

-- 1. Create Tables
CREATE TABLE student (
    regno VARCHAR(15) PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    major VARCHAR(25) NOT NULL,
    bdate DATE NOT NULL
);

CREATE TABLE course (
    course INT PRIMARY KEY,
    cname VARCHAR(30) NOT NULL,
    dept VARCHAR(25) NOT NULL
);

CREATE TABLE enroll (
    regno VARCHAR(15),
    course INT,
    sem INT NOT NULL,
    marks INT NOT NULL,
    PRIMARY KEY (regno, course),
    FOREIGN KEY (regno) REFERENCES student(regno) 
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (course) REFERENCES course(course) 
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE textbook (
    book_isbn INT PRIMARY KEY,
    book_title VARCHAR(40) NOT NULL,
    publisher VARCHAR(25) NOT NULL,
    author VARCHAR(25) NOT NULL
);

CREATE TABLE book_adoption (
    course INT,
    sem INT NOT NULL,
    book_isbn INT,
    PRIMARY KEY (course, sem, book_isbn),
    FOREIGN KEY (book_isbn) REFERENCES textbook(book_isbn) 
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (course) REFERENCES course(course) 
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 2. Insert Sample Data
INSERT INTO student VALUES
('01HF235', 'Student-1', 'CSE', '2001-05-15'),
('01HF354', 'Student-2', 'Literature', '2002-06-10'),
('01HF254', 'Student-3', 'History', '2000-04-04'),
('01HF653', 'Student-4', 'Philosophy', '2003-10-12'),
('01HF234', 'Student-5', 'Computer Science', '2001-10-10');

INSERT INTO course VALUES
(1, 'DBMS', 'CS'),
(2, 'Literature', 'English'),
(3, 'Philosophy', 'Philosophy'),
(4, 'History', 'Social Science'),
(5, 'Computer Science', 'CS');

INSERT INTO enroll VALUES
('01HF235', 1, 5, 85),
('01HF354', 2, 6, 87),
('01HF254', 3, 3, 95),
('01HF653', 4, 4, 80),
('01HF234', 5, 5, 75);

INSERT INTO textbook VALUES
(241563, 'Operating System', 'Pearson', 'Silberschatz'),
(532678, 'Complete Works of Shakespeare', 'Oxford', 'Shakespeare'),
(453723, 'Immanuel Kant', 'Delhi Classics', 'Immanuel Kant'),
(278345, 'History of the World', 'The Times', 'Richard Overy'),
(426784, 'Behavioural Economics', 'Pearson', 'David Orrell');

INSERT INTO book_adoption VALUES
(1, 5, 241563),
(2, 6, 532678),
(3, 3, 453723),
(4, 3, 278345),
(1, 6, 426784);

-- 3. Queries

-- Q1: Add a new textbook to the database and make it adopted by a department
INSERT INTO textbook VALUES 
(123476, 'Wings of Fire', 'Pearson', 'Dr APJ Abdul Kalam');

INSERT INTO book_adoption VALUES 
(1, 5, 123476);

-- Q2: List textbooks (Course#, Book_isbn, Book_title) in alphabetical order for CS courses using > 2 books
SELECT c.course, t.book_isbn, t.book_title
FROM course c
JOIN book_adoption ba ON c.course = ba.course
JOIN textbook t ON ba.book_isbn = t.book_isbn
WHERE c.dept = 'CS' 
  AND 2 < (
      SELECT COUNT(book_isbn)
      FROM book_adoption b
      WHERE c.course = b.course
  )
ORDER BY t.book_title ASC;

-- Q3: List any department that has all its adopted books published by a specific publisher ('Pearson')
SELECT DISTINCT c.dept
FROM course c
WHERE c.dept IN (
    SELECT c1.dept
    FROM course c1
    JOIN book_adoption b1 ON c1.course = b1.course
    JOIN textbook t1 ON t1.book_isbn = b1.book_isbn
    WHERE t1.publisher = 'Pearson'
)
AND c.dept NOT IN (
    SELECT c2.dept
    FROM course c2
    JOIN book_adoption b2 ON c2.course = b2.course
    JOIN textbook t2 ON t2.book_isbn = b2.book_isbn
    WHERE t2.publisher <> 'Pearson'
);

-- Q4: List the students who have scored max marks in 'DBMS' course
SELECT s.name
FROM student s
JOIN enroll e ON s.regno = e.regno
JOIN course c ON c.course = e.course
WHERE c.cname = 'DBMS'
  AND e.marks = (
      SELECT MAX(e1.marks)
      FROM enroll e1
      JOIN course c1 ON c1.course = e1.course
      WHERE c1.cname = 'DBMS'
  );

-- Q5: Create a view to display all courses opted by a student along with marks obtained
CREATE OR REPLACE VIEW CoursesOptedByStudent AS
SELECT c.cname, e.marks
FROM course c
JOIN enroll e ON c.course = e.course
WHERE e.regno = '01HF235';

SELECT * FROM CoursesOptedByStudent;