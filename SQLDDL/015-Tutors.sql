create table Tutors
(
	Tutor_ID int not null
		primary key,
	constraint Tutors_ibfk_1
		foreign key (Tutor_ID) references Student (ID)
);

