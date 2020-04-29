# Assignment 3: Faker Data Generation and DB Populating using Stored Procedures
## Authors: Daniel Briseno and Matthew Raymond
- Dependencies:
  - Python mysql driver (mysql-connector-python)
    - run `$pip install mysql-connector-python`
  - Python os module
  - Python sys module
- Relevant Files and Directories:
  - driver.py (runs faker app)
  - DataExtractor.py (parses faker data)
  - DBPopulator.py (populates data using output from DataExtractor)
  - SQLDDL (Directory containing DDL statements in .sql files for database schema)
  - classes.txt (used by faker)
- To Run Faker: `$ python driver.py <output_file> <num tuples>`
- To populate DB:
  - Preffered: Define file DBPopulator.py in same directory as DBPopulator.py with constants:
    - host= ipaddr, user = username, passwd = db password = wrd, database = db name, csv_path = path to faker csv file
    - Then run `$python DBPopulator.py`
  -  Else:
  -  `$ python DBPopulater.py <host ip> <user> <password> <database name> <csv_path>`

