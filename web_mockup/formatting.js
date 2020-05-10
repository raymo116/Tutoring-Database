// Formats a grid based on query data
// Might want to remove lstColNames because it appers to not be in use
function fnFillData(lstData, lstColNames, ...rest) {
    // If there's no data, there's no point in filling anything out
    if(lstData.length == 0) return;

    // Find the script for clicking on things
    var fnPopupScript;
    for (var i = 0; i < rest[0].length; i++) {
        if({}.toString.call(rest[0][i]) === '[object Function]') {
            fnPopupScript = rest[0].splice(i, 1)[0];
        }
    }

    // find the id of the table being saved to
    var targetID = rest[0];

    // pulls out all of the column names from the query
    var lstColNames = []
    for (var key in lstData[0]) {
        if (lstData[0].hasOwnProperty(key)) {
            lstColNames.push(key);
        }
    }

    // Find the grid target
    var grid = $('#'+targetID)[0];
    grid.innerHTML = '';

    // Create a table
    var table = document.createElement('table');

    // Create the header
    var header = document.createElement('tr');
    header.classList.add('header');

    // Populate the header
    for (var i = 0; i < lstColNames.length; i++) {
        var cell = document.createElement('th');
        cell.classList.add('header');
        cell.innerHTML = lstColNames[i];
        header.appendChild(cell);
    }

    // Add the header to the table
    table.appendChild(header);

    // populate the table
    for (var i = 0; i < lstData.length; i++) {
        // crete row
        var row = document.createElement('tr');

        // Add an onclick function if there is one
        if({}.toString.call(fnPopupScript) === '[object Function]') {
            row.onclick = function() {
                // Indicate that the row has been selected
                fnSelect($(this));

                // Execute the function passed
                fnPopupScript($(this));
            }
        }
        // Alternate row colors to help seperate the rows visually
        row.classList.add('row'+(i%2+1));

        // Populate the row with cells
        for (var k = 0; k < lstColNames.length; k++) {
            var cell = document.createElement('th');

            // If there's no data, default to '-'
            if (lstData[i][lstColNames[k]] == null)
                lstData[i][lstColNames[k]] = '-';

            // Set the inner html
            cell.innerHTML = lstData[i][lstColNames[k]];

            // Add to the row
            row.appendChild(cell);
        }

        // Add cell to row
        table.appendChild(row);
    }

    // Add row to grid
    grid.appendChild(table);
}

// Creates a loding screen
// target is the element whose children will be replaced with a loading screen
// text is the message that will be displayed
// ToDo: Maybe formalize this, as strings are bad practive
function fnCreateLoadingScreen(target, text) {
    $("#"+target)[0].innerHTML = "<div class='loader'></div>";
    $("#"+target)[0].innerHTML += `<p id='loaderText'>${text}</p>`;
}

// Manages the selection/deselection of rows
function fnSelect(e) {
    e.toggleClass('selected').siblings().removeClass('selected');
}

// Give all of the information about a specific tutor
function fnTutorList(e) {
    // Clear the modal
    clearInfoModal(false);
    // Create a loading screen
    fnCreateLoadingScreen('m_info-content-left', `Loading...'`);
    // Show the modal
    // ToDo: May be able to remove this since the modal is never hidden?
    $("#m_info").show();

    // Scrape the tutor's information
    var tutorInfo = fnGetTextFromRow(e);
    var tutor_id = tutorInfo[0];

    // Find the classes they tutor
    var query1 = mysql.format(SP_CLASSES_BY_TUTOR,[tutor_id]);
    fnRunQuery(query1, fnPopulateTutorClasses, tutorInfo);

    // find their schedule
    var query2 = mysql.format(SP_GET_SINGLE_TUTOR_SCHEDULE,[tutor_id]);
    fnRunQuery(query2, fnPopulateTutorSchedule);
}

// List the classes that a tutor teaches
function fnClassList(e) {
    // Get the text from the clicked row
    // ToDo: This seems like it should be returning to something
    fnGetTextFromRow(e);

    // Show the info modal
    $("#m_info").show();

    // Grab the class id
    var classID = e[0].innerText.match(/^[a-zA-Z]+\s[0-9]+L?/g)[0];
    // Set the title
    $("#m_info-content-left").html(`<p>${classID}</p>`);
    fnClassClicked(e);
}

// Get the text from a given row in a table
function fnGetTextFromRow(e) {
    // find all of the cells in the row
    var res = e.find("th");
    var info = []
    // Get the information from the rows
    for (var i = 0; i < res.length; i++) {
        info.push(res[i].innerText);
    }
    return info;
}

// This displays all of the classes a tutor teaches in the info modal
function fnPopulateTutorClasses(lstData, lstColNames, lstName) {
    // Pull out information
    var id = lstName[0][0];
    var fn = lstName[0][1];
    var ln = lstName[0][2];
    var status = lstName[0][3];

    // Creates title
    // ToDo: Might want to make this look prettier
    $('#m_info-title').text(`${fn} ${ln} - ${status}`);

    // Creates title
    $('#m_info-title-left').text('Classes');
    // Fill out the data
    fnFillData(lstData, lstColNames, ['m_info-content-left', fnClassClicked]);
}

// This displays a tutor's schedule in the info modal
function fnPopulateTutorSchedule(lstData, lstColNames) {
    // Create the title
    $('#m_info-title-right').text('Schedule');

    // Fill out the schedule
    fnFillData(lstData, lstColNames, 'm_info-content-right');

    var weekday = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
                   "Friday", "Saturday"]
    // Find the current day of the week
    var dotw = weekday[(new Date()).getDay()];

    // Find all of the results that contain the current day
    var day_result = $('*:contains("' + dotw + '")');

    // Highlight that day
    if(day_result.length > 0) {
        var target = day_result[day_result.length-2];

        // If they're there, it highlights good
        if($('#m_info-title').text().includes("In"))
            $(target).addClass('selected');
        // If not, it highlights bad
        else
            $(target).addClass('missing');
    }
}

// Sets up the modal for logging in
function fnLogin() {
    // Hide
    $('#choose_tutor').hide();
    $('#btn_select').hide();

    // Show
    $('#num_pad').show();
}
