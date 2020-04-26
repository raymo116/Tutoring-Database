from faker import Faker
from random import randrange
from datetime import datetime, time, timedelta
from sys import argv

'''
A class to control data generation per tutor, as one tutor will have many
students throughout a week
'''
class Tutor:
    '''
    Static variables
    '''
    # The maximum number of days a tutor can work a week
    _max_days_ = 5
    # The amount a tutor/tutee might be early or late
    _time_range_ = 10
    # A list of classes to tutor for
    _classes_ = None
    # The filepath the results will be saved to
    _output_fp_ = None
    # The header for the CSV
    _header_ = "Student Name, Student ID, Time In, Time Out, Tutor Name, Tutor ID, Tutor Time In, Tutor Time Out, Class, Table\n"
    # The number of lines that have been generated so far
    _lines_ = 0
    # The number of lines that we want to generate
    _target_ = None
    # The faker instance
    _faker_ = None

    '''
    DESC:   Constructor

    INPUT:  fp:str = None
                - The output filepath
            tuples:int=100
                - The number of tuples that will be generated
            seed: int = 0
                - The random seed to make sure that we can reproduce our results
                  during testing

    OUTPUT: None
    '''
    def __init__(self, fp:str = None, tuples:int=100, seed: int = 0):
        # Initializes the faker instance
        if Tutor._faker_ is None:
            Tutor._faker_ = Faker()
            Faker.seed(seed)

        # Initializes all of the instance variables
        self.name = '{} {}'.format(Tutor._faker_.first_name(), Tutor._faker_.last_name())
        self.id = Tutor._faker_.bothify(text="00#######")

        # Initializes the filepath and clears the file
        if Tutor._output_fp_ is None:
            Tutor._output_fp_ = fp
            with open(Tutor._output_fp_, "w") as myfile:
                myfile.write(Tutor._header_)

        # Sets the target if it hasn't been set already
        if Tutor._target_ is None: Tutor._target_ = tuples

        # Reads the classes in from a file
        if Tutor._classes_ is None:
            with open('classes.txt') as f:
                Tutor._classes_ = f.read().splitlines()


    '''
    DESC:   Generates all of the students for each tutor and appends it to the
            specified file

    INPUT:  None

    OUTPUT: None
    '''
    def generate_students(self):
        # A random number of days a week
        for d in range(randrange(1, Tutor._max_days_)):
            # Finds a start time within the tutoring center hours and on the
            # correct day of the week
            _time_in = Tutor._faker_.date_time_between(start_date='-30d', end_date='now')
            while not self._is_between_(time(10,00), time(15,00), _time_in.time()) or _time_in.weekday()>4:
                _time_in = Tutor._faker_.date_time_between(start_date='-30d', end_date='now')

            # Generates an amount of time they're going to stay
            _time_delt = timedelta(hours = randrange(1,4), minutes = randrange(0,59))

            # Finds the time they leave
            _time_out = _time_in + _time_delt

            # Chooses a table to sit at
            _table = randrange(1, 15)

            # Gets a random number of students
            for s in range(0, randrange(0, 10)):
                # Makes sure that we don't go over lines
                if Tutor._lines_ >= Tutor._target_: return

                # Creates a tutee ID
                _id = Tutor._faker_.bothify(text="00#######")

                # Determines how long it takes for the tutee to arive after the
                # tutor does
                _start_delt=timedelta(seconds=randrange(0,_time_delt.total_seconds()))

                # Falculates how much time they spend getting help
                _end_delt=timedelta(seconds=randrange(0,_time_delt.total_seconds()-_start_delt.total_seconds()))


                # Create a student name
                _s_name = '{} {}'.format(Tutor._faker_.first_name(), Tutor._faker_.last_name())
                # Find a class for them to be getting help on
                _class = Tutor._classes_[randrange(0, len(Tutor._classes_))]
                # The time the student arrives
                _s_in = _time_in + _start_delt
                # The time the student leaves
                _s_out = _s_in + _end_delt

                # Collecting all of the information to save
                result = "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}\n".format(_s_name, _id, _s_in, _s_out, self.name, self.id, _time_in, _time_out, _class, _table)

                # Save to file
                with open(Tutor._output_fp_, "a") as myfile:
                    myfile.write(result)

                Tutor._lines_+=1


    '''
    DESC:   Determines if a date is between two other dates

    INPUT:  begin_time
                - The initial datetime
            end_time
                - The end datetime
            check_time
                - The datetime you're checking

    OUTPUT: Bool
    '''
    def _is_between_(self, begin_time, end_time, check_time):
        return check_time >= begin_time and check_time <= end_time


    '''
    DESC:   Determines if the Tutor class has reached its target

    INPUT:  None

    OUTPUT: Bool
    '''
    @staticmethod
    def is_finished():
        if Tutor._target_ is None: return False
        else: return (Tutor._lines_ >= Tutor._target_)


'''
DESC:   Runs the data generation

INPUT:  output_fp: str
            - A filename that you want to save to
        tuples: int = 100
            - The number of tuples you want to create

OUTPUT: None
'''
def run_sim(output_fp: str, tuples: int = 100):
    print("Begining")
    while not Tutor.is_finished():
        t = Tutor('output.csv', tuples)
        t.generate_students()
    print("Completed")


'''
DESC:   If this is __main__, it runs the data generation based off of command-
        line parameters. Usage is as follows:
            python3 driver.py <output_file> <num_tuples>

INPUT:  argv[1]
            - A filepath to save to
        int(argv[2])
            - The numbe of tuples to generate

OUTPUT: None
'''
if __name__ == '__main__':
    run_sim(argv[1], int(argv[2]))
