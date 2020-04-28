create definer = root@`%` procedure sp_tutor_in(IN t_in varchar(100), IN tid int, IN table_num int)
BEGIN
  DECLARE tid_count INT(11);
  SET tid_count = (SELECT COUNT(Tutor_ID) FROM Tutors WHERE Tutor_ID = tid);
  IF tid_count = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not found in Tutors Table';
  ELSE
    SET t_in = IF(t_in IS NULL, CURRENT_TIMESTAMP, cast(t_in AS DATETIME));
    INSERT INTO TimeSheet(Time_In, Tutor_ID, `Table`) VALUES (t_in, tid, table_num);
  END IF;
END;

