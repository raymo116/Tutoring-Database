function fnInitialSetup() {
    $("#m_info_exit").click(function() {
        clearInfoModal(true);
    });

    $("#m_login_exit").click(function() {
        clearloginModal(true);
    });

    $("#tutor").click(function() {
        alert("Logging in as a tutor");
        chooseTableLayout();
    });

    $("#tutee").click(function() {
        alert("Logging in as a tutee");
        chooseTutorLayout();
    });

    $('#btn_select').click(fnSelectTutor);
}

function clearInfoModal(hide) {
    if(hide) $("#m_info").hide();
    $("#m_info-title").text("");
    $("#m_info-title-left").text("");
    $("#m_info-title-right").text("");
    $("#m_info-content-left").html("");
    $("#m_info-content-right").html("");
}

function chooseTableLayout() {
    $('#choose_tutor').hide();
    $('#tutor-login').hide();
    $('#num_pad').hide();
    $('#btn_select').hide();
    $('#choose-table').show();
    $('#table-select').show();

    fnRunQuery(SP_FIND_OPEN_TABLES, fnFillData, fnChooseTable, "open-tables");
}

function fnChooseTable(e) {
    if(e.hasClass("selected")) {
        $('#table-select').click(function() {
                var table = e[0].innerText;
                var d = getDateTime();

                var query = mysql.format(SP_TUTOR_IN, [d, STUDENT_ID, table]);
                fnRunQuery(TUTOR_IN, function(...rest){
                    clearloginModal(true);
                    console.log(rest);
                    alert("You are checked in to tutor");
                });
            });
    } else {
        $('#table-select').click(function() {
                alert("You need to select a table");
            });
    }
}

function getDateTime() {
    return new Date().toISOString().slice(0, 19).replace('T', ' ');
}

function clearloginModal(hide) {
    if(hide) $("#m_login").hide();

    $('#num_pad').show();
    $('#choose_tutor').hide();
    $('#btn_select').hide();
    $('#tutor-login').hide();
    $('#choose-table').hide();

    $("#m_login-title").text("");
    $("#m_info-content").text("");

    STUDENT_ID = null;
    SELECTED_TUTOR_ID = null;
}

function chooseTutorLayout() {
    $('#num_pad').hide();
    $('#choose_tutor').show();
    $('#btn_select').show();
    $('#tutor-login').hide();
    $('#choose-table').hide();

    $("#m_login-title").text("Chose a tutor");
}

function tutorCheckinLayout() {
    $('#num_pad').hide();
    $('#choose_tutor').hide();
    $('#btn_select').hide();
    $('#tutor-login').show();
    $('#choose-table').hide();
}

function fnSelectTutor() {
    if (SELECTED_TUTOR_ID != null) {
        var query = mysql.format(SP_CHECK_IN_STUDENT, [SELECTED_TUTOR_ID, STUDENT_ID]);
        fnRunQuery(query, function(...rest){
            if(rest[0][0]['Output'] === -1) {
                alert("error");
                console.log(rest);
            } else {
                alert(`You have successfully logged in with ID# ${STUDENT_ID}.\nThis needs to be updated and replaced with something that's not ugly asf.`)
                clearloginModal(true);
            }
        });
    } else alert('You need to select a tutor');
}
