// All of the stored procedures from the TutoringDatabase that we use 

var SP_GET_ALL_TUTORS_INFO = `call sp_get_tutors_in_info(null, null);`;
var SP_GET_CLASSES_TUTORED = `call sp_get_tutors_in_info(null, '?');`;
var SP_GET_CLASSES_TUTORED = `call sp_get_classes_tutored();`;
var SP_GET_TUTORS_FOR_SUBJECT = `call sp_get_tutors_for_subject(?);`;
var SP_GET_TUTORS_IN = `call sp_get_tutors_in(null);`;
var SP_VALID_STUDENT = `call sp_valid_stud_and_check_io(?);`;
var SP_FIND_OPEN_TABLES = `call sp_get_open_tables();`;
var SP_TUTOR_IN = `call sp_tutor_in(?, ?, ?);`;
var SP_CHECK_IN_STUDENT = `call sp_student_in(?, ?, null);`;
var SP_CLASSES_BY_TUTOR = `call sp_classes_by_tutor(?);`;
var SP_GET_SINGLE_TUTOR_SCHEDULE = `call sp_get_single_tutor_schedule(?);`;
