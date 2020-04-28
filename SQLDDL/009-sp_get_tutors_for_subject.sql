create definer = root@`%` procedure sp_get_tutors_for_subject(IN cid int)
BEGIN
  SELECT Student_ID 
  FROM TutorsClass
  WHERE Class_ID = cid;
END;

