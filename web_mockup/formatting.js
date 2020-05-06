function fnFillData(lstData, lstColNames, ...rest) {
    if(lstData.length == 0) return;

    var fnPopupScript;
    for (var i = 0; i < rest[0].length; i++) {
        if({}.toString.call(rest[0][i]) === '[object Function]') {
            fnPopupScript = rest[0].splice(i, 1)[0];
        }
    }

    var targetID = rest[0];

    var lstColNames = []
    for (var key in lstData[0]) {
        if (lstData[0].hasOwnProperty(key)) {
            lstColNames.push(key);
        }
    }

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
        if({}.toString.call(fnPopupScript) === '[object Function]') {
            row.onclick = function() {
                fnDisplayInformation($(this));
                fnPopupScript($(this));
            }
        }
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

function fnCreateLoadingScreen(target, text) {
    $("#"+target)[0].innerHTML = "<div class='loader'></div>";
    $("#"+target)[0].innerHTML += `<p id='loaderText'>${text}</p>`;
}

function fnDisplayInformation(e) {
    e.toggleClass('selected').siblings().removeClass('selected');
}

function fnTutorList(e) {
    clearModal(false);
    fnCreateLoadingScreen('m_info-content-left', `Loading...'`);
    $("#m_info").show();
    var tutorInfo = fnGetTextFromRow(e);
    var studentID = tutorInfo[0];
    // console.log(tutorInfo)

    var sp_single_tutor_info = `call sp_classes_by_tutor(${studentID});`;
    fnRunQuery(sp_single_tutor_info, fnPopulateTutorClasses, tutorInfo);


    var sp_get_single_tutor_schedule = `call sp_get_single_tutor_schedule(${studentID});`;
    fnRunQuery(sp_get_single_tutor_schedule, fnPopulateTutorSchedule);
}

function fnClassList(e) {
    fnGetTextFromRow(e);
    $("#m_info").show();
    var classID = e[0].innerText.match(/^[a-zA-Z]+\s[0-9]+L?/g)[0];

    $("#m_info-content-left").html(`<p>${classID}</p>`);
    fnClassClicked(e);
}

function fnGetTextFromRow(e) {
    var res = e.find("th");
    var info = []
    for (var i = 0; i < res.length; i++) {
        info.push(res[i].innerText);
    }
    return info;
}

function fnPopulateTutorClasses(lstData, lstColNames, lstName) {
    var id = lstName[0][0];
    var fn = lstName[0][1];
    var ln = lstName[0][2];
    var status = lstName[0][3];

    // Create a stored procedure to get the tutor's current table
    // sp_get_tutor_table

    $('#m_info-title').text(`${fn} ${ln} - ${status}`);
    $('#m_info-title-left').text('Classes');
    fnFillData(lstData, lstColNames, ['m_info-content-left', fnClassClicked]);
}


function fnPopulateTutorSchedule(lstData, lstColNames) {
    $('#m_info-title-right').text('Schedule');
    fnFillData(lstData, lstColNames, 'm_info-content-right');

    var weekday = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
                   "Friday", "Saturday"]

    var dotw = weekday[(new Date()).getDay()];

    var day_result = $('*:contains("' + dotw + '")');

    if(day_result.length > 0) {
        var target = day_result[day_result.length-2];

        if($('#m_info-title').text().includes("In"))
            $(target).addClass('selected');
        else
            $(target).addClass('missing');
    }
}
