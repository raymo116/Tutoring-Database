// This is the javascript for the database_test.html file

// INITIAL SETUP ---------------------------------------------------------------

// Create all of the onclick events
function fnSetupNavigationButtons() {
    // Get the list of tutors in
    $('#tutor_list').click(function() {
        fnCreateLoadingScreen('info-grid', 'Loading Tutor Data');
        fnRunQuery(SP_GET_ALL_TUTORS_INFO, fnFillData, fnTutorList, 'info-grid');
        $('#table-header')[0].innerHTML = "Tutors"
    });

    // Get the list of classes we have tutors for
    // ToDo: May want to sort based on who's here and who's out
    $('#class_list').click(function() {
        fnCreateLoadingScreen('info-grid', 'Loading Class Data');
        fnRunQuery(SP_GET_CLASSES_TUTORED, fnFillData, fnClassClicked, 'info-grid');
        $('#table-header')[0].innerHTML = "Classes"
    });

    // Start the check in process
    $('#check_in_list').click(function() {
        fnCreateLoadingScreen('m_info-content', 'Finding Tutors');
        fnStartLogin();
    });

    $('#managment_menu').click(function(){
        //show administrative modal via function in modal.js
        fnChooseManagmentOption();
    });
}

// END INITIAL SETUP -----------------------------------------------------------
