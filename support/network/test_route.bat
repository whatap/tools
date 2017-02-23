@ECHO OFF
:LOOPSTART
>>route_test.log.txt (
echo %DATE% %TIME%
tracert -d 210.122.10.232
)
sleep 3
GOTO LOOPSTART