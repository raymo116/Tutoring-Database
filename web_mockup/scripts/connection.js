// This class handles the database connections

// Loads required modules
const fs = require('fs');

// Global Variables
// ToDo: Need to remove this
var DATA;

// Reads data from a config file and creates a database connection
function fnCreateConnection() {
    // Read data from file
    var connData = fs.readFileSync('./con.data', 'utf8').split(/\r?\n/);

    // Add the credentials to access your database
    var connection = mysql.createConnection({
        host     : connData[0],
        user     : connData[1],
        password : connData[2],
        database : connData[3]
    });

    // connect
    connection.connect();

    return connection;
}

// Runs a given  query and performs an operation once complete

// strQuery is the query you want to be executed

// fncallback is the function that you want to be executed on completion
// The callback fucntion will be passed the rows and fields returned from the
// query

// ...rest allows you to pass more arguments than specified, but you have to
//  manually handle them in the function passed to fncallback (this is a
// similar to argc/argv in c/c++)
function fnRunQuery(strQuery, fncallback, ...rest) {
    // Creates a connection
    var connection = fnCreateConnection();

    // Queries the database
    connection.query(strQuery, function(err, rows, fields) {
        if (err) throw err;

        // If it's a stored procedure, it has to act slightly differently
        if(/^call [A-Za-z_0-9]+\(.*\);$/.test(strQuery))
            rows = rows[0];

        // Run the callback

        fncallback(rows, fields, rest);
    });

    // Close the connection
    connection.end();
}
