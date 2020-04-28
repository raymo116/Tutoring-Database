create definer = root@`%` procedure sp_student_in(IN tid int, IN sid int, IN t_in varchar(100))
BEGIN

    set t_in = IF(t_in is NULL, CURRENT_TIMESTAMP, cast(t_in as datetime));

    insert into TimeVisited(Time_In, Student_ID, Tutor_ID)
    values(t_in, sid, tid);

END;

