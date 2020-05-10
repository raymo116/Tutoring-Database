// This file is to store functions that only exist for debugging purposes

// Allows you to pass console.log by reference.
function fnLog() {
    if(typeof(console) !== 'undefined') {
        console.log.apply(console, arguments);
    }
}
