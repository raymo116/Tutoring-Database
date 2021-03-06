#Authors: Daniel Briseno, Matthew Raymond

from DataExtractor import Data_Extractor
import mysql.connector 
from mysql.connector import MySQLConnection, Error
from sys import argv
import os

#import db connection details if DbConfig.py file is found in directory
conn_config = True
try:
    import DbConfig
except ImportError:
    conn_config = False

#place conn and cursor variables in global namespace
conn = None
cursor = None

#initiate connection
if conn_config: #if DbConfig.py found in directory
    try:
        conn = mysql.connector.connect(host=DbConfig.host, user=DbConfig.user, passwd=DbConfig.passwd, database=DbConfig.database)
        cursor = conn.cursor()
    except mysql.connector.Error as err:
        print(err)
        exit(0)
elif len(argv)>1: #if database connection details given via command-line argument
        try:
            conn = mysql.connector.connect(host = argv[1],user = argv[2], passwd = argv[3], database = argv[4])
            cursor = conn.cursor()
        except mysql.connector.Error as err:
            print(err)
            exit(0)
else:
    print("Database Connection Details not specified\nApplication closing")
    exit(0)




#begin table populating function definitions

def populate_students(students:list):
    '''
    DESC: Populates Student table
    INPUT: students: list
        - A list of form [(first name:str, middle name:str, last name:str,sid:int)]
    OUTPUT: None                                         
    '''
    for student in students:
        try:
            cursor.callproc('sp_add_student', student)
            conn.commit()
        except Error as e:
            print("When trying to add",student,"to student table, the following error occured:")
            print(e)

def populate_tutors(tutors_classes:list):
    '''
    DESC: Populates Tutor table
    INPUT: tutors_classes: list
        - A list of form [(tutor_id:int, class_id:str)]
    OUTPUT: None
    '''
    tutors = [] #tutors will be list of tutor ids without repeats
    #construct tutors list
    for tutors_c in tutors_classes:
        if not tutors_c[0] in tutors:
            tutors.append(tutors_c[0])
    #add each tutor to the Tutors table
    for tutor in tutors:
        try:
            cursor.callproc('sp_add_tutor',[tutor])
            conn.commit()
        except Error as e:
            print("When trying to add", tutor, "to tutors table, the following error occured:")
            print(e)


def populate_time_visited(student_tmsht:list):
    '''
    DESC: Populates time_visited table
    INPUT: student_tmsht:list
        - A list of the form [(student id:int, time in student:str, time out student:str, tutor id:int)]
    OUTPUT: None
    '''
    for session in student_tmsht:
        #construct parameter for checking student in
        args = [session[3],session[1],session[0]]
        try:
            #check student in
            cursor.callproc('sp_student_in',args)
            conn.commit()
        except Error as e:
            print("When checking in session", args,"the following error occured")
            print(e)
        #construct parameter for checking student out
        args = [session[3],session[1], session[2]]
        try:
            #check student out
            cursor.callproc('sp_student_out',args)
            conn.commit()
        except Error as e:
            print("When checking out session", args,"the following error occured")
            print(e)


def populate_tutor_timesheet(tutor_tmsht:list):
    '''
    DESC: Populates TimeSheet table
    INPUT: tutor_tmsht:list
        - A list of the form [(time in tutor:str, tutor id:int, time out tutor:str, table:int)]
    OUTPUT: None
    '''
    for shift in tutor_tmsht:
        #collect data for tutor_check_in table insertion
        args = [shift[0],shift[1],shift[3]]
        #check tutor in via stored procedure
        try:
            cursor.callproc('sp_tutor_in',args)
            conn.commit()
        except Error as e:
            print("When checking in tutor shift", args,"the following error occured")
            print(e)
        #collect data for tutor_check_out table insertion
        args = [shift[2],shift[1]]
        #check tutor out via stored procedure
        try:
            cursor.callproc('sp_tutor_out',args)
            conn.commit()
        except Error as e:
            print("When checking out shift", args,"the following error occured")
            print(e)

def populate_tutor_times(tutor_tmsht:list):
    '''
    DESC: Populates TimeSheet table
    INPUT: tutor_tmsht:list
        - A list of the form [(time in tutor:str, tutor id:int, time out tutor:str, table:int)]
    OUTPUT: None
    '''
    for shift in tutor_tmsht:
        args = [shift[0],shift[2],shift[1]]
        try:
            cursor.callproc('sp_add_tutor_time_from_timesheet',args)
            conn.commit()
        except Error as e:
            print("When adding scheduled shift", args,"the following error occured")
            print(e)

def populate_class(classes:list):
    '''
    DESC: Populates Class table
    INPUT: classes:list
        - A list of the form [(Class_id:str, Class_name:str)]
    OUTPUT: None
    '''
    for c in classes:
        try:
            cursor.callproc('sp_add_class',c)
            conn.commit()
        except Error as e:
            print("When adding class",c,"the following error occured:")
            print(e)

def populate_tutors_class(tutor_classes:list):
    '''
    DESC: Populates Tutors table
    INPUT: tutor_classes:list
        - List of the form [(tutor_id:int, class_id:str)]
    OUTPUT: None
    '''
    for tc in tutor_classes:
        try:
            cursor.callproc('sp_add_tutor_class',tc)
            conn.commit()
        except Error as e:
            print("When adding (tutor,class) combination",tc,"the following error occured:")
            print(e)

def close_conn():
    cursor.close()
    conn.close()



if __name__ == '__main__':
    #extract and parse data from flat csv file
    extractor = None
    if conn_config:
        extractor = Data_Extractor(DbConfig.csv_path)
    else:
        extractor = Data_Extractor(argv[5])
    #begin populating db table by table
    print("Populating Student table")
    populate_students(extractor.students)
    print("Populating Tutors table")
    populate_tutors(extractor.tutor_classes)
    print("Populating TimeVisited table")
    populate_time_visited(extractor.student_tmsht)
    print("Populating TimeSheet table")
    populate_tutor_timesheet(extractor.tutor_tmsht)
    print("Populating TutorTimes table")
    populate_tutor_times(extractor.tutor_tmsht)
    print("Populating Class table")
    populate_class(extractor.classes)
    print("Populating TutorsClass table")
    populate_tutors_class(extractor.tutor_classes)
    close_conn()







