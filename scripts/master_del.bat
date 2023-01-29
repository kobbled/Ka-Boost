set ip=%1

call master_tp_interface_del.bat %ip%
call master_test_del.bat %ip%
call master_del1.bat %ip%