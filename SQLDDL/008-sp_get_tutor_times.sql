create definer = root@`%` procedure sp_get_tutor_times(IN tid int)
BEGIN
  DECLARE tid_exists TINYINT(1);
  SELECT COUNT(Tutor_ID) INTO tid_exists FROM TutorTimes WHERE tid = Tutor_ID;
  IF tid_exists = 0 THEN SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = 'tutor_id not in Tutors table';
  ELSE
    SELECT Time_in, Time_out
    FROM TutorTimes
    WHERE Tutor_ID = tid;
  END IF;
END;

