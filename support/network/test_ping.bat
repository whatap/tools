@ECHO OFF
:LOOPSTART
>>ping_test.log.txt (
echo %DATE% %TIME%
ping 210.122.10.232 -n 4
)
sleep 3
GOTO LOOPSTART