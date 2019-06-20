copy /v /y ".\scripting\1.10\kigen-ac_redux\" ".\scripting\1.8\kigen-ac_redux\"
copy /v /y ".\scripting\1.10\kigen-ac_redux.sp" ".\scripting\1.8\kigen-ac_redux.sp"

cd ./scripting/1.8
spcomp.exe kigen-ac_redux.sp -o../../plugins/kigen-ac_redux_legacy.smx

cd ../1.10
spcomp.exe kigen-ac_redux.sp -o../../plugins/kigen-ac_redux.smx
pause