function fnFillData(lstData, lstColNames, ...rest) {
    if(lstData.lenght == 0) return;

    var lstColNames = []
    for (var key in lstData[0]) {
        if (lstData[0].hasOwnProperty(key)) {
            lstColNames.push(key);
        }
    }

    var targetID = rest[0];

    // Find the source
    var grid = $('#'+targetID)[0];
    grid.innerHTML = '';

    var table = document.createElement('table');

    // Create the header
    var header = document.createElement('tr');
    header.classList.add('header');

    for (var i = 0; i < lstColNames.length; i++) {
        var cell = document.createElement('th');
        cell.classList.add('header');
        cell.innerHTML = lstColNames[i];
        header.appendChild(cell);
    }
    table.appendChild(header);

    for (var i = 0; i < lstData.length; i++) {
        var row = document.createElement('tr');
        row.classList.add('row'+(i%2+1));

        for (var k = 0; k < lstColNames.length; k++) {
            var cell = document.createElement('th');
            if (lstData[i][lstColNames[k]] == null)
                lstData[i][lstColNames[k]] = '-';
            cell.innerHTML = lstData[i][lstColNames[k]];
            row.appendChild(cell);
        }

        table.appendChild(row);
    }

    grid.appendChild(table);
}
