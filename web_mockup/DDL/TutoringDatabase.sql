create table Class
(
  Name       varchar(10)  not null
    primary key,
  Full_Name  varchar(100) null,
  Is_deleted datetime     null
);

create table Student
(
  ID         int auto_increment
    primary key,
  FName      varchar(20) not null,
  MName      varchar(20) null,
  LName      varchar(20) not null,
  Is_deleted datetime    null
);

create table Table_Numbers
(
  t_no int not null,
  constraint Table_Numbers_t_no_uindex
    unique (t_no)
);

alter table Table_Numbers
  add primary key (t_no);

create table Tutors
(
  Tutor_ID   int      not null
    primary key,
  Is_deleted datetime null,
  constraint Tutors_ibfk_1
    foreign key (Tutor_ID) references Student (ID)
);

create table TimeSheet
(
  Time_In    datetime not null,
  Time_out   datetime null,
  Total_time time     null,
  Tutor_ID   int      not null,
  `Table`    int      null,
  Is_deleted datetime null,
  primary key (Time_In, Tutor_ID),
  constraint TimeSheet_Table_Numbers_t_no_fk
    foreign key (`Table`) references Table_Numbers (t_no),
  constraint TimeSheet_ibfk_1
    foreign key (Tutor_ID) references Tutors (Tutor_ID)
);

create index Tutor_ID
  on TimeSheet (Tutor_ID);

create table TimeVisited
(
  Time_In    datetime not null,
  Time_out   datetime null,
  Student_ID int      not null,
  Tutor_ID   int      not null,
  Is_deleted datetime null,
  primary key (Time_In, Student_ID),
  constraint TimeVisited_ibfk_1
    foreign key (Student_ID) references Student (ID),
  constraint TimeVisited_ibfk_2
    foreign key (Tutor_ID) references Tutors (Tutor_ID)
);

create index Student_ID
  on TimeVisited (Student_ID);

create index Tutor_ID
  on TimeVisited (Tutor_ID);

create table TutorTimes
(
  Day        int      not null,
  Time_in    time     not null,
  Time_out   time     null,
  Is_deleted datetime null,
  Tutor_ID   int      not null,
  primary key (Day, Time_in, Tutor_ID),
  constraint TutorTimes_ibfk_1
    foreign key (Tutor_ID) references Tutors (Tutor_ID)
);

create index Tutor_ID
  on TutorTimes (Tutor_ID);

create index tutor_id_search
  on Tutors (Tutor_ID);

create table TutorsClass
(
  Student_ID int         not null,
  Class_ID   varchar(10) not null,
  Is_deleted datetime    null,
  primary key (Student_ID, Class_ID),
  constraint TutorsClass_ibfk_3
    foreign key (Student_ID) references Tutors (Tutor_ID),
  constraint TutorsClass_ibfk_4
    foreign key (Class_ID) references Class (Name)
);

create index Class_ID
  on TutorsClass (Class_ID);

create
  definer = root@`%` procedure sp_add_class(IN className varchar(10), IN fName varchar(100))
BEGIN
  INSERT INTO Class VALUES (className, fName);
end;

create
  definer = root@`%` procedure sp_add_student(IN sid int, IN fn varchar(20), IN mn varchar(20), IN ln varchar(20))
BEGIN
  DECLARE id_exists TINYINT(1);

  DECLARE exit handler for SQLEXCEPTION
    BEGIN
      rollback;
    END;

  start transaction
    ;

    SELECT COUNT(ID) INTO id_exists FROM Student WHERE sid = ID;

    SET mn = IF(mn = '!', NULL, mn);
    INSERT INTO Student(ID, FName, MName, LName) VALUES (sid, fn, mn, ln);

    SELECT COUNT(ID) INTO id_exists FROM Student WHERE sid = ID;
    IF NOT (id_exists = 0) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student record with given ID already exists';
    END IF;

  commit;


  #     DECLARE id_exists TINYINT(1);
  #     SELECT COUNT(ID) INTO id_exists FROM Student WHERE sid = ID;
  #     IF NOT(id_exists=0) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student record with given ID already exists';
  #     END IF;
  #     SET mn = IF( mn = '!', NULL, mn);
  #     INSERT INTO Student(ID, FName, MName, LName) VALUES(sid,fn,mn,ln);

END;

create
  definer = root@`%` procedure sp_add_tutor(IN tid int)
BEGIN
  DECLARE deleted TINYINT(1);
  SELECT COUNT(Tutor_ID) INTO deleted FROM Tutors WHERE Tutor_id = tid AND Is_deleted IS NOT NULL;
  IF deleted > 0 THEN
    CALL sp_restore_tutor(tid);
  ELSE
    INSERT INTO Tutors(Tutor_ID) VALUES (tid);
  END IF;
end;

create
  definer = root@`%` procedure sp_add_tutor_class(IN tutor_id int, IN class varchar(10))
BEGIN
  INSERT INTO TutorsClass VALUES (tutor_id, class);
end;

create
  definer = root@`%` procedure sp_add_tutor_time(IN t_in varchar(100), IN t_out varchar(100), IN tid int)
BEGIN
  DECLARE d INT(11);
  DECLARE tid_exists TINYINT(1);

  DECLARE exit handler for SQLEXCEPTION
    BEGIN
      rollback;
    END;

  start transaction
    ;

    SET t_in = CAST(t_in AS DATETIME);
    SET t_out = CAST(t_out AS DATETIME);
    SET d = DAYOFWEEK(t_in);
    SELECT COUNT(Tutor_id) INTO tid_exists FROM Tutors WHERE Tutor_id = tid;
    #     IF tid_exists = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not in Tutors table';
    #     ELSE
    #         SET t_in = TIME(t_in);
    #         SET t_out = TIME(t_out);
    #         INSERT INTO TutorTimes(Day, Time_in, Tutor_ID, Time_out) VALUES(d,t_in,tid,t_out);
    #     END IF;

    SET t_in = TIME(t_in);
    SET t_out = TIME(t_out);
    INSERT INTO TutorTimes(Day, Time_in, Tutor_ID, Time_out) VALUES (d, t_in, tid, t_out);
    IF tid_exists = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not in Tutors table'; end if;

  commit;
end;

create
  definer = root@`%` procedure sp_add_tutor_time_from_timesheet(IN t_in varchar(100), IN t_out varchar(100), IN tid int)
BEGIN
  DECLARE d INT(11);
  DECLARE tid_exists TINYINT(1);
  DECLARE check_repeats TINYINT(1);
  SET t_in = CAST(t_in AS DATETIME);
  SET t_out = CAST(t_out AS DATETIME);
  SET d = DAYOFWEEK(t_in);
  SELECT COUNT(Tutor_id) INTO tid_exists FROM Tutors WHERE Tutor_id = tid;
  IF tid_exists = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not in Tutors table';
  ELSE
    SET t_in = SEC_TO_TIME(FLOOR((TIME_TO_SEC(TIME(t_in)) + 450) / 900) * 900);
    SET t_out = SEC_TO_TIME(FLOOR((TIME_TO_SEC(TIME(t_out)) + 450) / 900) * 900);
    SELECT COUNT(Tutor_ID) INTO check_repeats FROM TutorTimes WHERE Day = d AND Time_in = t_in AND Tutor_ID = tid;
    IF check_repeats = 0 THEN
      INSERT INTO TutorTimes(Day, Time_in, Tutor_ID, Time_out) VALUES (d, t_in, tid, t_out);
    END IF;
  END IF;
end;

create
  definer = root@`%` procedure sp_classes_by_tutor(IN tutor_id varchar(9))
BEGIN
  select C.Name as `Name`, C.Full_Name as `Description`
  from Class C
         inner join (
    select TC.Class_ID
    from TutorsClass TC
    where TC.Student_ID like `tutor_id`
      AND TC.Is_deleted IS NULL
  ) I
                    on I.Class_ID = C.Name
  where C.Is_deleted is null
  order by `Name` asc;
END;

create
  definer = root@`%` procedure sp_delete_class(IN cid varchar(10))
BEGIN
  DECLARE isClass TINYINT(1);
  DECLARE deletedAt DATETIME;
  -- Exit handler in case rollback is necessary
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      ROLLBACK;
    END;
  SET deletedAt = NOW();
  -- Check if class to delete exists as an undeleted class in table
  SELECT COUNT(Name) INTO isClass FROM Class WHERE Name = cid AND Is_deleted IS NULL;
  IF isClass = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Class Name does not match any registered classes';
  ELSE
    START TRANSACTION
      ;
      -- Do soft delete on class and delete relevant records from TutorsClass
      UPDATE Class SET Class.Is_deleted = deletedAt WHERE Name = cid AND Class.Is_deleted IS NULL;
      UPDATE TutorsClass SET TutorsClass.Is_deleted = deletedAt WHERE Class_ID = cid AND TutorsClass.Is_deleted IS NULL;
    COMMIT;
  END IF;
END;

create
  definer = root@`%` procedure sp_delete_shift(IN day_of_week int, IN t_in time, IN tid int)
BEGIN
  DECLARE isRecord TINYINT(1);
  SELECT COUNT(`Day`) INTO isRecord
  FROM TutorTimes
  WHERE `Day` = day_of_week
    AND Time_in = t_in
    AND Tutor_ID = tid
    AND TutorTimes.Is_deleted IS NULL;
  IF isRecord = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '(Day, Time In, Tutor ID) triple does not match any scheduled shifts';
  ELSE
    UPDATE TutorTimes
    SET TutorTimes.Is_deleted = NOW()
    WHERE `Day` = day_of_week
      AND Time_in = t_in
      AND Tutor_ID = tid
      AND TutorTimes.Is_deleted IS NULL;
  END IF;
END;

create
  definer = root@`%` procedure sp_delete_student(IN sid int)
BEGIN
  DECLARE isStudent TINYINT(1);
  DECLARE deletedAt DATETIME;
  -- Exit handler in case Rollback is necessary
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      ROLLBACK;
    END;

  -- set time records were deleted
  SET deletedAt = NOW();
  -- check that student exists
  SELECT COUNT(ID) INTO isStudent FROM Student WHERE ID = sid AND Is_deleted IS NULL;
  -- if student does not exist signal error
  IF isStudent = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student ID not registered to any student';
  ELSE
    START TRANSACTION
      ;
      -- delete student
      UPDATE Student SET Is_deleted = deletedAt WHERE ID = sid;
      -- if student is also a tutor, remove the tutor from the TLT database (only students can be TLT tutors)
      UPDATE Tutors SET Is_deleted = deletedAt WHERE Tutor_ID = sid AND Is_deleted IS NULL;
      UPDATE TutorTimes SET Is_deleted = deletedAt WHERE Tutor_ID = sid AND Is_deleted IS NULL;
      UPDATE TutorsClass SET Is_deleted = deletedAt WHERE Student_ID = sid AND Is_deleted IS NULL;
    COMMIT;
  END IF;
END;

create
  definer = root@`%` procedure sp_delete_student_visit(IN tin datetime, IN sid int)
BEGIN
  DECLARE isVisit TINYINT(1);
  SELECT COUNT(Time_In)
  FROM TimeVisited
  WHERE Time_in = tin
    AND Student_ID = sid
    AND Is_deleted IS NULL;
  IF isVisit = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
        '(Time In, Student ID) pair does not match any student visits to the TLT';
  ELSE
    UPDATE TimeVisited
    SET TimeVisited.Is_deleted = NULL
    WHERE Time_in = tin
      AND Student_ID = sid
      AND Is_deleted IS NULL;
  END IF;
END;

create
  definer = root@`%` procedure sp_delete_tutor(IN tid int)
BEGIN
  DECLARE isTutor TINYINT(1);
  DECLARE deletedAt DATETIME;

  -- Set up handler in case rollback is necessary
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      ROLLBACK;
    END;
  -- Set time records were deleted
  SET deletedAt = NOW();
  -- check that tutor exists
  SELECT COUNT(Tutor_ID) INTO isTutor FROM Tutors WHERE Tutor_ID = tid AND Is_deleted IS NULL;
  -- if student does not exist signal error
  IF isTutor = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student ID not registered to any Tutor';
  ELSE
    -- Soft delete on tutor and all relevant scheduling information for that tutor
    START TRANSACTION
      ;
      UPDATE Tutors SET Is_deleted = deletedAt WHERE Tutor_ID = tid AND Is_deleted IS NULL;
      UPDATE TutorTimes SET Is_deleted = deletedAt WHERE Tutor_ID = tid AND Is_deleted IS NULL;
      UPDATE TutorsClass SET Is_deleted = deletedAt WHERE Student_ID = tid AND Is_deleted IS NULL;
    COMMIT;
  END IF;
END;

create
  definer = root@`%` procedure sp_delete_tutor_visit(IN t_in datetime, IN tid int)
BEGIN
  DECLARE isShift TINYINT(1);
  SELECT COUNT(Tutor_ID) INTO isShift
  FROM TimeSheet
  WHERE Time_in = t_in
    AND Tutor_ID = tid
    AND Is_deleted IS NULL;
  IF isShift = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '(Time In, Tutor ID) pair does not match any tutor check-ins to the TLT';
  ELSE
    UPDATE TimeSheet
    SET TimeSheet.Is_deleted = NOW()
    WHERE Time_In = t_in
      AND Tutor_ID = tid
      AND TimeSheet.Is_deleted IS NULL;
  END IF;
END;

create
  definer = root@`%` procedure sp_delete_tutors_class(IN sid int, IN cid varchar(10))
begin
  declare isRecord tinyint(1);
  declare deletedAt datetime;
  set deletedAt = now();
  -- check if (sid,cid) matches any undeleted record in table
  select count(Student_ID) into isRecord
  from TutorsClass
  where Student_ID = sid
    AND Class_ID = cid
    AND Is_deleted IS NULL;
  -- if (sid,cid) does not match any undeleted record, signal error
  if deletedAt = 0 then
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '(Tutor_ID, Class_ID) pair does not match any record.';
  else
    -- execute soft delete
    update TutorsClass
    set TutorsClass.Is_deleted = deletedAt
    where Student_ID = sid and Class_ID = cid and Is_deleted is NULL;
  end if;
end;

create
  definer = root@`%` procedure sp_get_classes_tutored()
BEGIN
  select distinct C.Name as `Class`, C.Full_Name as `Description`
  from Class C,
       TutorsClass T,
       Student S
  where C.Name = T.Class_ID
    and T.Student_ID = S.ID
    and C.Is_deleted is null
    and T.Is_deleted is null
    and S.Is_deleted is null;
END;

create
  definer = root@`%` procedure sp_get_open_tables()
begin
  select T.t_no as `Table Number`
  from Table_Numbers T
  where T.t_no not in (
    select `Table`
    from TimeSheet
    where Time_out is null
      and Is_deleted is null
  );
end;

create
  definer = root@`%` procedure sp_get_single_tutor_schedule(IN id varchar(9))
BEGIN
  select (
           select case
                    when Day = 0 then 'Monday'
                    when Day = 1 then 'Tuesday'
                    when Day = 2 then 'Wednesday'
                    when Day = 3 then 'Thursday'
                    when Day = 4 then 'Friday'
                    when Day = 5 then 'Saturday'
                    when Day = 6 then 'Sunday'
                    else 'Error'
                    end
         )                                        as Day,
         lower(date_format(Time_in, '%h:%i %p'))  as `Time In`,
         lower(date_format(Time_out, '%h:%i %p')) as `Time Out`
  from TutorTimes
  where tutor_ID like id
    and id in (
    select Tutor_ID
    from Tutors
    where Tutors.Is_deleted is null
  )
    and Is_deleted is null;
END;

create
  definer = root@`%` procedure sp_get_tutors_for_subject(IN cid varchar(16))
BEGIN
  select ID,
         FName as `First Name`,
         LName as `Last Name`,
         (
           case
             when ID in (
               select Tutor_ID FROM TimeSheet WHERE Time_out IS NULL AND TimeSheet.Is_deleted IS NULL
             )
               then 'In'
             else
               'Out'
             end
           )   as Status
  from Student
  where ID in (
    SELECT Student_ID
    FROM TutorsClass
    WHERE Class_ID like cid
      AND TutorsClass.Is_deleted IS NULL
  )
    and Student.Is_deleted is null;
END;

create
  definer = root@`%` procedure sp_get_tutors_in(IN `current_time` varchar(100))
BEGIN
  SET `current_time` = IF(`current_time` IS NULL, NULL, CAST(`current_time` AS DATETIME));

  select S.ID as `ID`, S.FName `First Name`, S.LName `Last Name`, P.`Table` as `Table`
  from Student S
         inner join (
    select Tutor_ID, `Table`
    FROM TimeSheet
    WHERE case
            when `current_time` IS NULL
              then Time_out IS NULL
            else
                (`current_time` BETWEEN Time_In AND Time_out) OR
                (`current_time` <= Time_In AND Time_out IS NULL)
      END
      AND TimeSheet.Is_deleted IS NULL
  ) P on S.ID = P.Tutor_ID
  WHERE S.Is_deleted IS NULL;
END;

create
  definer = root@`%` procedure sp_get_tutors_in_info(IN `current_time` varchar(100))
BEGIN
  SET `current_time` = IF(`current_time` IS NULL, NULL, CAST(`current_time` AS DATETIME));

  select distinct ID,
                  FName  `First Name`,
                  LName  `Last Name`,
                  (
                    case
                      when Time_out is null and Time_In is not null then 'In'
                      else 'Out'
                      end
                    ) as `Status`
  from Tutors T
         inner join Student S
                    on T.Tutor_ID = S.ID AND S.Is_deleted IS NULL
         left outer join TimeSheet TS on TS.Tutor_ID = T.Tutor_ID AND TS.Is_deleted IS NULL
  where T.Is_deleted is null
  order by Status asc, `Last Name` asc, `First Name` asc;

  #     select ID, FName `First Name`, LName `Last Name`, (
  #         case
  #             when S.ID in (
  #                     select Tutor_ID FROM TimeSheet WHERE
  #                     case
  #                         when `current_time` IS NULL
  #                             then Time_out IS NULL
  #                         else
  #                             (`current_time` BETWEEN Time_In AND Time_out) OR (`current_time` <= Time_In AND Time_out IS NULL)
  #                     END
  #                             )
  #                 then 'In'
  #             else
  #                 'Out'
  #             end
  #                ) as Status
  #         from Student S
  #         where S.ID in (select Tutor_ID from Tutors) and (
  #             class_id is null or S.ID in (
  #                 select T.Student_ID from TutorsClass T where T.Class_ID like class_id
  #                 )
  #             )
  #         order by Status asc, `Last Name` asc, `First Name` asc;
END;

create
  definer = root@`%` procedure sp_restore_tutor(IN tid int)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      ROLLBACK;
    END;
  START TRANSACTION
    ;
    UPDATE Tutors SET Is_deleted = NULL WHERE Tutor_ID = tid;
    UPDATE TutorTimes SET Is_deleted = NULL WHERE Tutor_ID = tid;
    UPDATE TutorsClass SET Is_deleted = NULL WHERE Student_ID = tid;
  COMMIT;
end;

create
  definer = root@`%` procedure sp_student_in(IN tutor_id int, IN student_id int, IN time_in varchar(100))
BEGIN

  if (
       select count(*)
       from Student S
       where S.ID like student_id
     ) > 0
  then
    set time_in = IF(time_in is NULL, CURRENT_TIMESTAMP, cast(time_in as datetime));

    insert into TimeVisited(Time_In, Student_ID, Tutor_ID)
    values (time_in, student_id, tutor_id);

    select ROW_COUNT() as `Output`;
  else
    select -1 as `Output`;
  end if;
END;

create
  definer = root@`%` procedure sp_student_out(IN tid int, IN sid int, IN t_out varchar(100))
BEGIN

  set t_out = IF(t_out is NULL, CURRENT_TIMESTAMP, cast(t_out as datetime));

  update TimeVisited
  set Time_Out = t_out
  where Student_ID = sid
    AND Tutor_ID = tid
    AND Time_out IS NULL
  order by Time_In desc
  limit 1;

  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
        'Student Checkout failed, no recent check-in with matching Student_ID, Tutor_ID';
  END IF;

END;

create
  definer = root@`%` procedure sp_tutor_in(IN t_in varchar(100), IN tid int, IN table_num int)
BEGIN
  DECLARE tid_count INT(11);
  SET tid_count = (SELECT COUNT(Tutor_ID) FROM Tutors WHERE Tutor_ID = tid);
  IF tid_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor id not found in Tutors Table';
  ELSE
    SET t_in = IF(t_in IS NULL, CURRENT_TIMESTAMP, cast(t_in AS DATETIME));
    INSERT INTO TimeSheet(Time_In, Tutor_ID, `Table`) VALUES (t_in, tid, table_num);
  END IF;
END;

create
  definer = root@`%` procedure sp_tutor_is_in(IN tid int)
BEGIN
  DECLARE isin TINYINT(1);
  SELECT COUNT(Tutor_ID) INTO isin
  FROM TimeSheet
  WHERE Is_deleted IS NULL
    AND Tutor_ID = tid
    AND Time_out IS NULL
  ORDER BY Time_In DESC
  LIMIT 1;
  IF isin = 1 THEN
    SELECT 'In';
  ELSE
    SELECT 'Out';
  END IF;
end;

create
  definer = root@`%` procedure sp_tutor_out(IN t_out varchar(100), IN tid int)
BEGIN
  DECLARE tid_exists TINYINT(1);
  SELECT COUNT(Tutor_ID) INTO tid_exists FROM Tutors WHERE Tutor_ID = tid;
  IF tid_exists = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'tutor id not in Tutors Table';
  ELSE
    SET t_out = IF(t_out IS NULL, CURRENT_TIMESTAMP, CAST(t_out AS DATETIME));
    UPDATE TimeSheet
    SET Time_out = t_out
    WHERE Tutor_ID = tid
      AND Time_out IS NULL
    ORDER BY Time_In desc
    LIMIT 1;
    UPDATE TimeSheet
    SET Total_time = SEC_TO_TIME((TIMESTAMPDIFF(SECOND, Time_In, Time_out)))
    WHERE Tutor_ID = tid
      AND Time_out = t_out;
  END IF;
END;

create
  definer = root@`%` procedure sp_valid_stud_and_check_io(IN student_id int)
begin
  # checks to see if the student is in the database at all
  if 0 not in (select count(*) from Student S where S.ID like student_id and Is_deleted is null)
    # Is valid Student
  then
    # checks to see if they're a tutor
    if 0 not in (select count(*) from Tutors T where T.Tutor_ID like student_id and Is_deleted is null)
      # they're a tutor
    then
      # check to see if they're logged in as a tutor
      if 0 not in (select count(*)
                   from TimeSheet TS
                   where TS.Tutor_ID like student_id and TS.Time_out is null and Is_deleted is null)
        # If they are logged in as a tutor
      then
        # ToDo: Replace this later with a shift-editing function
        call sp_tutor_out(NOW(), student_id);
        # Say that the tutor is checking out
        select 'TOUT' as `Output`;
        # If they are not logged in as a tutor
      else
        # check to see if they're logged in as a student
        if 0 not in (
          select count(*)
          from TimeVisited TV
          where TV.Student_ID like student_id
            and TV.Time_out is null
            and TV.Is_deleted is null
        )
          # if they're logged in as a student
        then
          # Checks to see if the student has been there for more than 5 hours
          if 0 not in (
            select UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(TV.Time_In) > 18000 as forgot
            from TimeVisited TV
            where TV.Student_ID like student_id
              and TV.Time_out is null
              and TV.Is_deleted is null
          )
          then
            # If they have, it assumes that they left half an hour after arriving
            # Todo: make it so they can't check out after the tutor they signed up for
            update TimeVisited TV
            set TV.Time_Out = DATE_ADD(TV.Time_In, INTERVAL 30 MINUTE)
            where TV.Student_ID like student_id
              and TV.Time_out is null
              and TV.Is_deleted is null;

            # Since they checked out so long ago, they're likely checking in again,
            # so we return the identifier for student
            select 'TUTR' as `Output`;
            # If they checked in recently
          else
            update TimeVisited TV
            set TV.Time_Out = NOW()
            where TV.Student_ID like student_id
              and TV.Time_out is null
              and TV.Is_deleted is null;

            # Let the client know that the student has checked out
            select 'SOUT' as `Output`;
          end if;
          # If they're not logged in as a student
        else
          select 'TUTR' as `Output`;
        end if;
      end if;
      # they're just a student
    else
      # checks to see if the student is already checked in
      if 0 not in (
        select count(*)
        from TimeVisited TV
        where TV.Student_ID like student_id
          and TV.Time_out is null
          and TV.Is_deleted is null
      )
        # If the student is already checked in
      then
        # Checks to see if the student has been there for more than 5 hours
        if 0 not in (
          select UNIX_TIMESTAMP(NOW()) - UNIX_TIMESTAMP(TV.Time_In) > 18000 as forgot
          from TimeVisited TV
          where TV.Student_ID like student_id
            and TV.Time_out is null
            and TV.Is_deleted is null
        )
        then
          # If they have, it assumes that they left half an hour after arriving
          # Todo: make it so they can't check out after the tutor they signed up for
          update TimeVisited TV
          set TV.Time_Out = DATE_ADD(TV.Time_In, INTERVAL 30 MINUTE)
          where TV.Student_ID like student_id
            and TV.Time_out is null
            and TV.Is_deleted is null;

          # Since they checked out so long ago, they're likely checking in again,
          # so we return the identifier for student
          select 'STDT' as `Output`;
          # If they checked in recently
        else
          update TimeVisited TV
          set TV.Time_Out = NOW()
          where TV.Student_ID like student_id
            and TV.Time_out is null
            and TV.Is_deleted is null;

          # Let the client know that the student has checked out
          select 'SOUT' as `Output`;
        end if;
      else
        # Says that the student is a valid student
        select 'STDT' as `Output`;
      end if;
    end if;
    # Is not a valid Student
  else
    select 'BADD' as `Output`;
  end if;
end;

create
  definer = root@`%` procedure sp_valid_student(IN student_id int)
BEGIN

  select case
           when (
                  select count(*) from Student S where S.ID like student_id and S.Is_deleted is null
                ) > 0
             then TRUE
           else FALSE
           end
           as `Output`;
END;


