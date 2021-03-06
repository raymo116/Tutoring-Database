#Authors: Daniel Briseno, Matthew Raymond
import csv
from os import path
#helper methods
def extractNames(rawName:str):
        name_lst = rawName.split(" ")
        if len(name_lst)==2:
            name_lst.insert(1,'!')
        return name_lst
    
def extractClass(rawClass:str):
    class_lst = rawClass.split(" ")
    class_dict = {}
    class_dict["Class_ID"] = " ".join(class_lst[:2])
    class_dict["Class_Name"] = " ".join(class_lst[2:])
    return class_dict

#these constants make list indexing simpler when
#dealing with faker data
s_name = 0
sid = 1
t_ins = 2
t_outs = 3
t_name = 4
tid = 5
t_intu = 6
t_outtu = 7
class_name = 8
table = 9


class Data_Extractor:
    '''The purpose of this class is to create lists from output.csv that can be easily 
    inputted to the database.
    It creates lists of the form:
        tutor_class := [(tutor_id:int, class_id:str)]
        classes :=[(class_id:str, class_name:str)]
        student_tmsht := [(student_id:int, time_in_student:str, time_out_student:str, tutor_id:int)]
        tutor_tmsht := [(time_in_tutor:str, tutor_id:int, time_out_tutor:str, table:int)]
        students := [(first_name:str, middle_name:str, last_name:str, student_id:int)]
    '''
   
    def __init__(self,csv_path = "output.csv"):
        '''
        DESC: Class constructor
        INPUT: File path to csv faker file, defaults to ./output.csv
        '''
        if not path.exists(csv_path):
            print("csv file", csv_path, "not found, application exiting")
            exit(0)
        self.classes = []
        self.student_tmsht = []
        self.tutor_tmsht = []
        self.students = []
        self.tutor_classes = []
        self.extract(csv_path)
    
    def extract(self, csv_path):
        '''
        DESC: This method iterates through each line of the file at csv_path and calls various
        functions which build the 5 lists mentioned in the class description

        INPUT: csv_path:str
            - A path to a csv file containing faker data with columns (from left to right):
                Student Name: string (fname [mname] lname)
                Student ID: int
                Time in: string (DATETIME)
                Time Out: string (DATETIME)
                Tutor Name: string (fname [mname] lname)
                Tutor ID: int
                Tutor time out: string (DATETIME)
                Tutor time out: string (DATETIME)
                Class: str (class_subject class_number class_full_name)
                Table: int
        OUTPUT: None
        '''
        with open(csv_path) as f:
            for row in f:
                row = row.split(", ")
                #skip first row
                if not row[sid].isnumeric():
                    continue
                #populate lists
                self.add_to_classes(row)
                self.add_to_students(row)
                self.add_to_student_tmsht(row)
                self.add_to_tutor_tmsht(row)
                self.add_to_tutor_class(row)
    
    def add_to_tutor_class(self,row):
        '''
        DESC: Adds relevant row items as a tuple to tutors_class list

        INPUT: row:list
            - A list of items as described in extract() docstrings
        
        OUTPUT: None
        '''
        tutor_id = row[tid]
        class_id = extractClass(row[class_name])['Class_ID']
        item = (tutor_id,class_id)
        #ensure list items are unique
        if not item in self.tutor_classes:
            self.tutor_classes.append(item)

    def add_to_student_tmsht(self, row):
        '''
        DESC: Adds relevant row items as a tuple to student_tmsht list

        INPUT: row:list
            - A list of items as described in extract() docstrings
        
        OUTPUT: None
        '''
        student_id = int(row[sid])
        t_in = row[t_ins]
        t_out = row[t_outs]
        tutor_id = int(row[tid])
        session = (t_in,student_id,t_out,tutor_id)
        #ensure list items are unique
        if not session in self.student_tmsht:
            self.student_tmsht.append(session)

    def add_to_tutor_tmsht(self, row):
        '''
        DESC: Adds relevant row items as a tuple to tutor_tmsht list

        INPUT: row:list
            - A list of items as described in extract() docstrings
        
        OUTPUT: None
        '''
        tutor_id = int(row[tid])
        time_in = row[t_intu]
        time_out = row[t_outtu]
        tbl = int(row[table][:-1])
        class_id = extractClass(row[class_name])["Class_ID"]
        shift = (time_in,tutor_id,time_out,tbl)
        #ensure list items are unique
        if not shift in self.tutor_tmsht:
            self.tutor_tmsht.append(shift)


        
    def add_to_classes(self,row):
        '''
        DESC: Adds relevant row items as a tuple to classes list

        INPUT: row:list
            - A list of items as described in extract() docstrings
        
        OUTPUT: None
        '''
        class_dict = extractClass(row[class_name])
        class_ident =(class_dict['Class_ID'],class_dict['Class_Name'])
        #ensure list items are unique
        if not class_ident in self.classes:
            self.classes.append(class_ident)

    def add_to_students(self, row):
        '''
        DESC: Adds relevant row items as a tuple to students list

        INPUT: row:list
            - A list of items as described in extract() docstrings

        OUTPUT: None
        '''
        #create (id,fname, mname, lname) tuple for student entry
        name1 = extractNames(row[s_name])
        id1 = int(row[sid])
        ident1 = ([id1]+name1)
        #create (id,fname,mname,lname) tuple for tutor entry, who is a student as well
        #and should be added to the student list
        name2 = extractNames(row[t_name])
        id2 = int(row[tid])
        ident2 = ([id2]+name2)
        #enter tuples into list if not already there
        if not ident1 in self.students:
            self.students.append(ident1)
        if not ident2 in self.students:
            self.students.append(ident2)

if __name__ == '__main__':
    extractor = Data_Extractor()
    print(extractor.classes)
    print('\n\n\n')
    print(extractor.tutor_classes)
    print('\n\n\n')
    print(extractor.tutor_tmsht)
    print('\n\n\n')
    print(extractor.student_tmsht)
    print('\n\n\n')
    print(extractor.students)
    print(len(extractor.students))