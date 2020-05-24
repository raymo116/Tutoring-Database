const fastcsv = require("fast-csv");

function fnTableExport(tblName, fileLabel) {
    //prepare sql statement
    sqlstm = mysql.format("SELECT * FROM ?? WHERE Is_deleted IS NULL;",tblName);
    fnRunQuery(sqlstm, fnWriteToCSV, fileLabel,tblName);
}

function fnWriteToCSV(rows, fields, ...rest) {
    //put data in JSON format
    const data_json = JSON.parse(JSON.stringify(rows));
    //remove Is_deleted field
    for(i=0; i<data_json.length; ++i) {
        delete data_json[i]['Is_deleted'];
    }

    //prepare output file
    const ws = fs.createWriteStream("./Data_Exports/"+rest[0][0]+"_"+rest[0][1]+".csv");
    //wite to output file
    fastcsv.write(data_json,{headers:true}).pipe(ws);
}