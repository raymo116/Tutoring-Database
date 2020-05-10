const fs = require('fs');

// Constants
var DATA;

function fnCreateConnection() {
    var connData = fs.readFileSync('./con.data', 'utf8').split(/\r?\n/);

    // Add the credentials to access your database
    var connection = mysql.createConnection({
        host     : connData[0],
        user     : connData[1],
        password : connData[2],
        database : connData[3]
    });

    connection.connect();
    return connection;
}

function fnRunQuery(strQuery, fncallback, ...rest) {
    var connection = fnCreateConnection();

    connection.query(strQuery, function(err, rows, fields) {
        if (err) throw err;

        // If it's a stored procedure, it has to act slightly differently
        if(/^call [A-Za-z_0-9]+\(.*\);$/.test(strQuery))
            rows = rows[0];

        fncallback(rows, fields, rest);
    });

    connection.end();
}
