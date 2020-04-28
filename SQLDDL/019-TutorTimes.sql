create table TutorTimes
(
	Day int not null,
	Time_in time not null,
	Time_out time null,
	Tutor_ID int not null,
	primary key (Day, Time_in, Tutor_ID),
	constraint TutorTimes_ibfk_1
		foreign key (Tutor_ID) references Tutors (Tutor_ID)
);

create index Tutor_ID
	on TutorTimes (Tutor_ID);

