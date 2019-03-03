-- Query 1
select distinct student.s_id, student.name
from teaches, student, takes, instructor
where student.s_id = takes.s_id AND takes.course_id = teaches.course_id AND teaches.i_id = instructor.i_id AND instructor.name = 'Katz' AND teaches.semester = takes.semester AND teaches.year = takes.year AND teaches.sec_id = takes.sec_id
order by student.name DESC;
-- Query 2
select student.s_id, round((sum(course.credits * Grade_points.points) / sum(course.credits)), 2)
from student, course, grade_points, takes 
where student.s_id = takes.s_id AND course.course_id = takes.course_id AND takes.grade = grade_points.grade 
group by student.s_id
order by round((sum(course.credits * Grade_points.points) / sum(course.credits)), 2) DESC;
-- Query 3
select takes.course_id, takes.sec_id, count(s_id)
from takes, section
where takes.course_id = section.course_id AND takes.sec_id = section.sec_id AND takes.year = '2009' AND section.year = takes.year AND takes.semester = 'Fall' AND section.semester = takes.semester 
group by takes.course_id, takes.sec_id
order by count(s_id) DESC;  
-- Query 4
select takes.course_id, takes.sec_id
from takes, section
where takes.course_id = section.course_id AND takes.sec_id = section.sec_id AND takes.year = '2009' AND section.year = takes.year AND takes.semester = 'Fall' AND section.semester = takes.semester 
group by takes.course_id, takes.sec_id
order by takes.course_id ASC 
fetch first 1 rows only;
-- Query 5
select instructor.name, count(distinct teaches.course_id)
from teaches, instructor
where instructor.i_id = teaches.i_id 
group by instructor.name
order by count(distinct teaches.course_id) DESC 
fetch first 4 rows only;
-- Query 6
select teaches.semester, teaches.year, count(teaches.course_id)
from teaches
group by teaches.semester, teaches.year
order by count(teaches.course_id) DESC, teaches.semester DESC
fetch first 3 rows only;
-- Query 7 
select takes.s_id, student.name, count(takes.course_id)
from takes, student
where takes.s_id = student.s_id
group by takes.s_id, student.name
order by count(takes.course_id) DESC
fetch first 2 rows only;
-- Query 8
select instructor.name, count(instructor.i_id)
from instructor, teaches, takes
where takes.course_id = teaches.course_id AND teaches.i_id = instructor.i_id AND teaches.semester = takes.semester AND teaches.year = takes.year AND teaches.sec_id = takes.sec_id
group by instructor.name
order by count(instructor.i_id) DESC
fetch first 4 rows only;
-- Query 9
select distinct course.dept_name, course.course_id 
from course
where course.dept_name = 'Comp. Sci.' OR course.dept_name = 'History'
order by  course.course_id ASC;
-- Query 10
select prereq.course_id, course.dept_name, prereq.prereq_id, instructor.dept_name
from course, prereq, takes, teaches, instructor
where prereq.course_id = course.course_id AND prereq.prereq_id = takes.course_id AND takes.course_id = teaches.course_id AND teaches.i_id = instructor.i_id AND course.dept_name != instructor.dept_name
order by course.course_id ASC;
