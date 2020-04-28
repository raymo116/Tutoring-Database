# Assignment 3: Faker Data Generation and DB Populating using Stored Procedures
#Authors: Daniel Briseno and Matthew Raymond
- To Run Faker: `$ python driver.py <output_file> <num tuples>`
- To populate DB:
  - Preffered: Define file DBPopulator.py in same directory as DBPopulator.py with constants:
    - host= ipaddr, user = username, passwd = db password = wrd, database = db name
    - Then run `$python DBPopulator.py`
  -  Else:
  -  `$ python DBPopulater.py <host ip> <user> <password> <database name>`
- All DDL Statments in SQLDDL folder 