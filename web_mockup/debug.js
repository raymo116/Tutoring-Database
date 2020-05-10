function fnLog() {
    if(typeof(console) !== 'undefined') {
        console.log.apply(console, arguments);
    }
}
