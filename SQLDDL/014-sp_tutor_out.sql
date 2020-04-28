create definer = root@`%` procedure sp_tutor_out(IN t_out varchar(100), IN tid int)
BEGIN
  DECLARE tid_exists TINYINT(1);
  SELECT COUNT(Tutor_ID) INTO tid_exists FROM Tutors WHERE Tutor_ID = tid; 
  IF tid_exists = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tutor id not in Tutors Table';
  ELSE
    SET t_out = IF(t_out IS NULL, CURRENT_TIMESTAMP, CAST(t_out AS DATETIME));
    UPDATE TimeSheet
    SET Time_out = t_out
    WHERE Tutor_ID = tid AND Time_out IS NULL
    ORDER BY Time_In desc
    LIMIT 1;
    UPDATE TimeSheet
    SET Total_time = SEC_TO_TIME((TIMESTAMPDIFF(SECOND,Time_In,Time_out)))
    WHERE Tutor_ID = tid AND Time_out = t_out;
  END IF;
END;

