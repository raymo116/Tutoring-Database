create table TutorsClass
(
	Student_ID int not null,
	Class_ID varchar(10) not null,
	primary key (Student_ID, Class_ID),
	constraint TutorsClass_ibfk_3
		foreign key (Student_ID) references Tutors (Tutor_ID),
	constraint TutorsClass_ibfk_4
		foreign key (Class_ID) references Class (Name)
);

create index Class_ID
	on TutorsClass (Class_ID);

