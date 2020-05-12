
function fnSetupNavigationButtons() {
    $('#tutor_list').click(function() {
        fnCreateLoadingScreen('info-grid', 'Loading Tutor Data');
        fnRunQuery(SP_GET_ALL_TUTORS_INFO, fnFillData, fnTutorList, 'info-grid');
        $('#table-header')[0].innerHTML = "Tutors"
    });

    $('#class_list').click(function() {
        fnCreateLoadingScreen('info-grid', 'Loading Class Data');
        fnRunQuery(SP_GET_CLASSES_TUTORED, fnFillData, fnClassClicked, 'info-grid');
        $('#table-header')[0].innerHTML = "Classes"
    });

    $('#check_in_list').click(function() {
        $("#m_login").show();
        fnCreateLoadingScreen('m_info-content', 'Finding Tutors');
        fnRunQuery(SP_GET_TUTORS_IN, fnFillData, fnSelectTutor, 'm_info-content');
        $('#m_login-title')[0].innerHTML = "Tutors In"
    });
}

function fnEnterNum(item) {
    if(item.name == "clear") $("#id_login")[0].value = "";
    else if(item.name == "enter") {
        if($("#id_login")[0].value.length == 0) {
            fnFlash();
            return;
        }
        var temp = $("#id_login")[0].value;
        $("#id_login")[0].value = "";

        // This is bad and needs to be fixed eventually;
        STUDENT_ID = temp;

        var query = mysql.format(SP_VALID_STUDENT, [temp]);

        fnRunQuery(query, fnProcessLogin);
    }
    else if ($("#id_login")[0].value.length < 9){
        $("#id_login")[0].value += item.innerHTML;
    }
    else {
        fnFlash();
    }
}

function fnProcessLogin(...rest){
    console.log(rest[0][0]['Output']);
    switch (rest[0][0]['Output']) {
        case 'TOUT':
            clearloginModal(true);
            alert("You have ended your shift as a tutor");
            STUDENT_ID = null;
            break;
        case 'SOUT':
            clearloginModal(true);
            alert("You have successfully been checked out of your tutoring session");
            STUDENT_ID = null;
            break;
        case 'STDT':
            chooseTutorLayout();
            break;
        case 'BADD':
            fnFlash();
            STUDENT_ID = null;
            break;
        case 'TUTR':
            fnTutorLogin();
            break;
        default:
            fnFlash();
            console.log(rest[0][0]['Output']);
            STUDENT_ID = null;
    }
}

function fnClassClicked(e) {
    clearInfoModal(false);
    fnCreateLoadingScreen('m_info-content-right', 'Loading Class Data');
    $("#m_info").show();
    var classID = e[0].innerText.match(/^[a-zA-Z]+\s[0-9]+L?/g)[0];

    // Need to figure out how to escape characters
    var query = mysql.format(SP_GET_TUTORS_FOR_SUBJECT, [classID]);
    $('#m_info-title').text(`Tutors for ${classID}`);
    fnRunQuery(query, fnFillData, fnTutorList, 'm_info-content-right');
}

function fnFlash() {
    $("#id_login").addClass('warning');
    setTimeout(function() {
        $("#id_login").removeClass("warning");
    }, 250);
    // alert("That was an invalid id number.\nPlease try again");
}

// This is likely to be more complicated in the future
function fnTutorLogin() {
    tutorCheckinLayout();
}

// This should be cleaned up so it doesn't use global constants
function fnSelectTutor(e) {
     if(SELECTED_TUTOR_ID != fnGetTextFromRow(e)[0])
         SELECTED_TUTOR_ID = fnGetTextFromRow(e)[0];
     else
         SELECTED_TUTOR_ID = null;
}
