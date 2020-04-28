create table TimeSheet
(
	Time_In datetime not null,
	Time_out datetime null,
	Total_time time null,
	Tutor_ID int not null,
	`Table` int null,
	primary key (Time_In, Tutor_ID),
	constraint TimeSheet_ibfk_1
		foreign key (Tutor_ID) references Tutors (Tutor_ID)
);

create index Tutor_ID
	on TimeSheet (Tutor_ID);

