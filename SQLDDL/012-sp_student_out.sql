create definer = root@`%` procedure sp_student_out(IN tid int, IN sid int, IN t_out varchar(100))
BEGIN

    set t_out = IF(t_out is NULL, CURRENT_TIMESTAMP, cast(t_out as datetime));

    update TimeVisited
    set Time_Out = t_out
    where Student_ID = sid AND Tutor_ID = tid AND Time_out IS NULL
    order by Time_In desc
    limit 1;

    IF ROW_COUNT() = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student Checkout failed, no recent check-in with matching Student_ID, Tutor_ID';
    END IF;

END;

