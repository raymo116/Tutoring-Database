create definer = root@`%` procedure sp_add_tutor_time_from_timesheet(IN t_in varchar(100), IN t_out varchar(100), IN tid int)
BEGIN
  DECLARE d INT(11);
  DECLARE tid_exists TINYINT(1);
  DECLARE check_repeats TINYINT(1);
  SET t_in = CAST(t_in AS DATETIME);
  SET t_out = CAST(t_out AS DATETIME);
  SET d = DAYOFWEEK(t_in);
  SELECT COUNT(Tutor_id) INTO tid_exists FROM Tutors WHERE Tutor_id = tid;
  IF tid_exists = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not in Tutors table';
  ELSE
    SET t_in = SEC_TO_TIME(FLOOR((TIME_TO_SEC(TIME(t_in))+450)/900)*900);
    SET t_out = SEC_TO_TIME(FLOOR((TIME_TO_SEC(TIME(t_out))+450)/900)*900);
    SELECT COUNT(Tutor_ID) INTO check_repeats FROM TutorTimes WHERE Day = d AND Time_in = t_in AND Tutor_ID = tid;
    IF check_repeats = 0 THEN INSERT INTO TutorTimes(Day, Time_in, Tutor_ID, Time_out) VALUES(d,t_in,tid,t_out);
    END IF;
  END IF;
end;

