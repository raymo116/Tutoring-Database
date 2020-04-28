from DataExtractor import Data_Extractor
import mysql.connector 
from mysql.connector import MySQLConnection, Error


try:
    conn = mysql.connector.connect(host = '35.236.254.178',user = "root", passwd = "thisisdanielspassword", database = 'TutoringDatabase')
    cursor = conn.cursor()
except mysql.connector.Error as err:
    print(err)


def populate_students(students:list):
    i=0
    for student in students:
        try:
            cursor.callproc('sp_add_student', student)
            conn.commit()
        except Error as e:
            print("When trying to add",student,"to student table, the following error occured:")
            print(e)

def populate_tutors(tutors_classes:list):
    tutors = []
    for tutors_c in tutors_classes:
        if not tutors_c[0] in tutors:
            tutors.append(tutors_c[0])
    print(len(tutors))
    for tutor in tutors:
        try:
            cursor.callproc('sp_add_tutor',[tutor])
            conn.commit()
        except Error as e:
            print("When trying to add", tutor, "to tutors table, the following error occured:")
            print(e)

def populate_time_visited(student_tmsht:list):
    for session in student_tmsht:
        args = [session[3],session[1],session[0]]
        try:
            cursor.callproc('sp_student_in',args)
            conn.commit()
        except Error as e:
            print("When checking in session", args,"the following error occured")
            print(e)
        args = [session[3],session[1], session[2]]
        try:
            cursor.callproc('sp_student_out',args)
            conn.commit()
        except Error as e:
            print("When checking out session", args,"the following error occured")
            print(e)

def populate_tutor_timesheet(tutor_tmsht:list):
    for shift in tutor_tmsht:
        args = [shift[0],shift[1],shift[3]]
        try:
            cursor.callproc('sp_tutor_in',args)
            conn.commit()
        except Error as e:
            print("When checking in tutor shift", args,"the following error occured")
            print(e)
        args = [shift[2],shift[1]]
        try:
            print("foo")
            cursor.callproc('sp_tutor_out',args)
            conn.commit()
        except Error as e:
            print("When checking out shift", args,"the following error occured")
            print(e)

def populate_tutor_times(tutor_tmsht:list):
    for shift in tutor_tmsht:
        args = [shift[0],shift[2],shift[1]]
        try:
            cursor.callproc('sp_add_tutor_time_from_timesheet',args)
            conn.commit()
        except Error as e:
            print("When adding scheduled shift", args,"the following error occured")
            print(e)

def close_conn():
    cursor.close()
    conn.close()

#def populate_tutors(tutors:list):



extractor = Data_Extractor()
#begin populating db table by table
#populate_students(extractor.students)
#populate_tutors(extractor.tutor_classes)
populate_time_visited(extractor.student_tmsht)
#populate_tutor_timesheet(extractor.tutor_tmsht)
#populate_tutor_times(extractor.tutor_tmsht)
close_conn()







