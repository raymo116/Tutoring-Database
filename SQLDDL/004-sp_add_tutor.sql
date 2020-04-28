create definer = root@`%` procedure sp_add_tutor(IN tid int)
BEGIN
  INSERT INTO Tutors VALUES (tid);
end;

