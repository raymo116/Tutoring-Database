create definer = root@`%` procedure sp_add_tutor_class(IN tutor_id int, IN class varchar(10))
BEGIN
  INSERT INTO TutorsClass VALUES(tutor_id,class);
end;

