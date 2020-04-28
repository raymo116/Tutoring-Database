create definer = root@`%` procedure sp_add_class(IN className varchar(10), IN fName varchar(100))
BEGIN
  INSERT INTO Class VALUES (className, fName);
end;

