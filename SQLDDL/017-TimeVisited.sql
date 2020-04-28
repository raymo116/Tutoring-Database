create table TimeVisited
(
	Time_In datetime not null,
	Time_out datetime null,
	Student_ID int not null,
	Tutor_ID int not null,
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

