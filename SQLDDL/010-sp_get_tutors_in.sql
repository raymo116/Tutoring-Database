create definer = root@`%` procedure sp_get_tutors_in(IN `current_time` varchar(100))
BEGIN
  SET `current_time` = IF(`current_time` IS NULL, NULL, CAST(`current_time` AS DATETIME));
  IF `current_time` IS NULL THEN
    SELECT Tutor_ID FROM TimeSheet WHERE Time_out IS NULL;
  ELSE
    SELECT Tutor_ID 
    FROM TimeSheet 
    WHERE (`current_time` BETWEEN Time_In AND Time_out) OR (`current_time` <= Time_In AND Time_out IS NULL);
  END IF;
END;

