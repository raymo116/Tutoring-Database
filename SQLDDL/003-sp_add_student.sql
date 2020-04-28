create definer = root@`%` procedure sp_add_student(IN sid int, IN fn varchar(20), IN mn varchar(20), IN ln varchar(20))
BEGIN
  DECLARE id_exists TINYINT(1);
  SELECT COUNT(ID) INTO id_exists FROM Student WHERE sid = ID;
  IF NOT(id_exists=0) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student record with given ID already exists';
  END IF;
  SET mn = IF( mn = '!', NULL, mn);
  INSERT INTO Student(ID, FName, MName, LName) VALUES(sid,fn,mn,ln);
END;

