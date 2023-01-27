set ip=192.168.1.154

call master_del1.bat %ip%
call master_test_del.bat %ip%
call master_tp_interface_del.bat %ip%