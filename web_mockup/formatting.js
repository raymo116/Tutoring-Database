function fnFillData(lstData, lstHeader, lstFields, targetID) {
    if (arguments.length == 2) {
        targetID = arguments[1][2];
        lstFields = arguments[1][1];
        lstHeader = arguments[1][0];
    } else if (arguments.length != 4) throw "Wrong number of arguments";

    // Find the source
    var grid = $('#'+targetID)[0];

    var table = document.createElement('table');

    // Create the header
    var header = document.createElement('tr');
    header.classList.add('header');

    for (var i = 0; i < lstHeader.length; i++) {
        var cell = document.createElement('th');
        cell.classList.add('header');
        cell.innerHTML = lstHeader[i];
        header.appendChild(cell);
    }
    table.appendChild(header);



    for (var i = 0; i < lstData.length; i++) {
        var row = document.createElement('tr');
        row.classList.add('row'+(i%2+1));

        for (var k = 0; k < lstFields.length; k++) {
            var cell = document.createElement('th');
            if (lstData[i][lstFields[k]] == null)
                lstData[i][lstFields[k]] = '-';
            cell.innerHTML = lstData[i][lstFields[k]];
            row.appendChild(cell);
        }

        table.appendChild(row);
    }

    grid.appendChild(table);
}
