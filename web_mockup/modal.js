// Most of the javascript for the modals used for checking in and viewing
// tutors/classes'

// INITIAL SETUP ---------------------------------------------------------------

// Sets up the onclick functions for all of the buttons
function fnInitialSetup() {
    $("#m_info_exit").click(function() {
        clearInfoModal(true);
    });

    $("#m_login_exit").click(function() {
        clearloginModal(true);
    });

    $("#tutor").click(function() {
        // console.log(STUDENT_ID);
        chooseTableLayout();
    });

    $("#tutee").click(function() {
        chooseTutorLayout();
    });

    $('#btn_select').click(fnSetTutor);
}

// INITIAL SETUP ---------------------------------------------------------------


// INFO MODAL SETUP ------------------------------------------------------------

// Resets the InfoModal to its default view
function clearInfoModal(hide) {
    // Hides the modal
    if(hide) $("#m_info").hide();

    // resets text content
    $("#m_info-title").text("");
    $("#m_info-title-left").text("");
    $("#m_info-title-right").text("");

    // Resets inner html
    $("#m_info-content-left").html("");
    $("#m_info-content-right").html("");
}

// END INFO --------------------------------------------------------------------


// LOGIN MODAL SETUP -----------------------------------------------------------

// Resets the login modal to its default view
function clearloginModal(hide) {
    // Hides the infomodal
    if(hide) $("#m_login").hide();

    // Hide
    $('#choose_tutor').hide();
    $('#btn_select').hide();
    $('#tutor-login').hide();
    $('#choose-table').hide();

    // Show
    $('#num_pad').show();

    // Reset Text content
    $("#m_login-title").text("");
    $("#m_info-content").text("");

    // Resets the variables
    // ToDo: Need to remove these global constants
    STUDENT_ID = null;
    SELECTED_TUTOR_ID = null;
}

// Set up the modal to begin the login process
function fnStartLogin() {
    fnCreateLoadingScreen('m_info-content', 'Finding Tutors');

    // Show
    $("#m_login").show();

    // Set inner html
    $('#m_login-title')[0].innerHTML = "Tutors In"

    // View all of the tutors who are currently in
    fnRunQuery(SP_GET_TUTORS_IN, fnFillData, fnSelectTutor, 'm_info-content');
}

// Sets up the layout for choosing a tutor
function chooseTutorLayout() {
    // Hide
    $('#tutor-login').hide();
    $('#choose-table').hide();
    $('#num_pad').hide();

    // Show
    $('#choose_tutor').show();
    $('#btn_select').show();

    // Set the header text
    $("#m_login-title").text("Chose a tutor");
}

// Set the layout for tutor check-in
function tutorCheckinLayout() {
    // Hide
    $('#num_pad').hide();
    $('#choose_tutor').hide();
    $('#btn_select').hide();

    // Show
    $('#tutor-login').show();
    $('#choose-table').hide();
}

// END LOGIN SETUP -------------------------------------------------------------


// CHOOSING A TABLE ------------------------------------------------------------

// Switches the login modal to table-selecting mode
function chooseTableLayout() {
    $('#choose_tutor').hide();
    $('#tutor-login').hide();
    $('#num_pad').hide();
    $('#btn_select').hide();
    $('#choose-table').show();
    $('#table-select').show();

    console.log(STUDENT_ID);

    // Populate the list of tables
    // We'll want to update this to something prettier eventually
    fnRunQuery(SP_FIND_OPEN_TABLES, fnFillData, fnChooseTable, "open-tables");
}

// Selects the current table
function fnChooseTable(e) {
    console.log(STUDENT_ID);
    // Checks to make sure that the row is selected
    if(e.hasClass("selected")) {
        // Set the onclick function to
        $('#table-select').click(function() {
            // Get the current date in mysql format
            var d = getDateTime();

            // Creates the query
            // ToDo: Escape query
            var query = mysql.format(SP_TUTOR_IN, [d, STUDENT_ID, e[0].innerText]);
            // Check the tutor in
            fnRunQuery(query, function(...rest){
                clearloginModal(true);
                // alert("You are checked in to tutor");
                fnShowSnackbar("You are checked in to tutor", true);
            });
        });
    } else {
        // Set the onclick function to alert them
        // ToDo: make this prettier
        $('#table-select').click(function() {
                fnShowSnackbar("You need to select a table", false);
                // alert("You need to select a table");
            });
    }
}

// Gets the current date-time in mysql format
function getDateTime() {
    return new Date().toISOString().slice(0, 19).replace('T', ' ');
}

// END OF TABLE ----------------------------------------------------------------


// SELECT A TUTOR --------------------------------------------------------------

// This is the function that's called when a tutor is selected
// function fnSelectTutor() {
//     console.log("lala", STUDENT_ID);
//     // Checks to make sure that a tutor is selected
//     if (SELECTED_TUTOR_ID != null) {
//         // Creates query
//         var query = mysql.format(SP_CHECK_IN_STUDENT, [SELECTED_TUTOR_ID, STUDENT_ID]);
//
//         // Runs the query
//         fnRunQuery(query, fnStudentLogInConfirmation);
//     } else fnShowSnackbar('You need to select a tutor', false);
    // } else alert('You need to select a tutor');
// }

// Lets the student know they have successfully logged in
function fnStudentLogInConfirmation(...rest){
    if(rest[0][0]['Output'] === -1) {
        // ToDo: Need to make this error handling more bulletproof
        fnShowSnackbar("There was an error. Please try again.", false);
        // alert("There was an error. Please try again.");
        console.log(rest);
    } else {
        // Lets the student know they have successfully logged in
        // ToDo: Need to make this less ugly
        fnShowSnackbar(`You have successfully logged in with ID# ${STUDENT_ID}.\n
            This needs to be updated and replaced with something that's
            not ugly asf.`, true)

        // Reset the modal and hide it
        clearloginModal(true);
    }
}

// END OF TUTOR SELECTION ------------------------------------------------------


// LOGIN KEYPAD ----------------------------------------------------------------

// The onclick function for each keypad element
// Makes it so we can assign the same function to every key
function fnEnterNum(item) {
    // Clear the login bar
    if (item.name == "clear")
        $("#id_login")[0].value = "";
    // Enter the result
    else if(item.name == "enter")
        fnSubmitID();
    // Insert number
    else if ($("#id_login")[0].value.length < 9)
        $("#id_login")[0].value += item.innerHTML;
    // Give a warning message
    else
        fnFlash();
}

// Submit the user ID and see what happens
function fnSubmitID() {
    // Checks to make sure that the input isn't empty
    if($("#id_login")[0].value.length == 0) {
        fnFlash();
        return;
    }

    // Gets the student ID
    // Need to replace this eventually
    STUDENT_ID = $("#id_login")[0].value;
    console.log(STUDENT_ID);

    // Clear the input
    $("#id_login")[0].value = "";

    // Checks to see if the name is valid
    var query = mysql.format(SP_VALID_STUDENT, [STUDENT_ID]);
    fnRunQuery(query, fnProcessLogin);
}

// Handles the result of query the student id
function fnProcessLogin(...rest){
    switch (rest[0][0]['Output']) {
        // [T]utor checking [OUT]
        case 'TOUT':
            // Hide the modal
            clearloginModal(true);
            // Lets them know they've checked out
            // ToDo: Need to make this prettier
            fnShowSnackbar("You have ended your shift as a tutor", true);
            // alert("You have ended your shift as a tutor");
            break;

        // [S]tudent checking [OUT]
        case 'SOUT':
            // Hide the modal
            clearloginModal(true);
            // Lets them know they've checked out
            // ToDo: Need to make this prettier
            fnShowSnackbar("You have successfully been checked out of your tutoring session", true);
            // alert("You have successfully been checked out of your tutoring session");
            break;

        // They are a [ST]u[D]en[T]
        case 'STDT':
            // STUDENT_ID = temp;
            chooseTutorLayout();
            break;

        // They are a [TUT]e[R]
        case 'TUTR':
            // STUDENT_ID = temp;
            fnTutorLogin();
            break;

        // They aren't in the database (idk, I guess it was a [BADD] query)
        case 'BADD':
            fnFlash();
            break;

        // If there was an unexpected output
        default:
            fnFlash();
            console.log(rest[0][0]['Output']);
    }
}

// Flashes the text input section
function fnFlash() {
    // Add class with animation
    $("#id_login").addClass('warning');

    // Set a timeout to remove the class after a certain ammount of time
    setTimeout(function() {
        $("#id_login").removeClass("warning");
    }, 250);
}

// END LOGIN KEYPAD ------------------------------------------------------------


// SELECT A CLASS --------------------------------------------------------------

// Pulls  up data on the class
function fnClassClicked(e) {
    // reset the modal
    clearInfoModal(false);

    fnCreateLoadingScreen('m_info-content-right', 'Loading Class Data');
    $("#m_info").show();

    // Grab the class id
    var classID = e[0].innerText.match(/^[a-zA-Z]+\s[0-9]+L?/g)[0];

    // ToDo: Need to figure out how to escape characters

    // Set the header text
    $('#m_info-title').text(`Tutors for ${classID}`);

    // Finds all of the tutors for that class
    var query = mysql.format(SP_GET_TUTORS_FOR_SUBJECT, [classID]);
    fnRunQuery(query, fnFillData, fnTutorList, 'm_info-content-right');
}

// END OF CLASS SELECTION ------------------------------------------------------


// TUTOR LOGIN -----------------------------------------------------------------

// This is likely to be more complicated in the future
function fnTutorLogin() {
    tutorCheckinLayout();
}

// END TUTOR LOGIN -------------------------------------------------------------


// SELECT TUTOR ----------------------------------------------------------------

// Selects the current tutor ID
// ToDo: This is insecure and uses global constants, so we need to remove it
function fnSelectTutor(e) {
    if(SELECTED_TUTOR_ID != fnGetTextFromRow(e)[0])
        SELECTED_TUTOR_ID = fnGetTextFromRow(e)[0];
    else
        SELECTED_TUTOR_ID = null;
}

function fnSetTutor() {
    if (SELECTED_TUTOR_ID != null) {
        var query = mysql.format(SP_CHECK_IN_STUDENT, [SELECTED_TUTOR_ID, STUDENT_ID]);
        fnRunQuery(query, function(...rest){
            if(rest[0][0]['Output'] === -1) {
                // alert("error");
                fnShowSnackbar("error", false);
                console.log(rest);
            } else {
                // alert(`You have successfully logged in with ID# ${STUDENT_ID}.`)
                fnShowSnackbar(`You have successfully logged in with ID# ${STUDENT_ID}.`, true)
                clearloginModal(true);
            }
        });
    // } else alert('You need to select a tutor');
    } else fnShowSnackbar('You need to select a tutor', false);
}

// END TUTOR SELECTION ---------------------------------------------------------
