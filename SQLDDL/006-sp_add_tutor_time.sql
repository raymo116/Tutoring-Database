create definer = root@`%` procedure sp_add_tutor_time(IN t_in varchar(100), IN t_out varchar(100), IN tid int)
BEGIN
  DECLARE d INT(11);
  DECLARE tid_exists TINYINT(1);
  SET t_in = CAST(t_in AS DATETIME);
  SET t_out = CAST(t_out AS DATETIME);
  SET d = DAYOFWEEK(t_in);
  SELECT COUNT(Tutor_id) INTO tid_exists FROM Tutors WHERE Tutor_id = tid;
  IF tid_exists = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not in Tutors table';
  ELSE
    SET t_in = TIME(t_in);
    SET t_out = TIME(t_out);
    INSERT INTO TutorTimes(Day, Time_in, Tutor_ID, Time_out) VALUES(d,t_in,tid,t_out);
  END IF;
end;

