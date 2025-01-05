copy /v /y ".\scripting\latest\kigen-ac_redux\" ".\scripting\1.8\kigen-ac_redux\"
copy /v /y ".\scripting\latest\kigen-ac_redux.sp" ".\scripting\1.8\kigen-ac_redux.sp"

cd ./scripting/1.8
spcomp.exe kigen-ac_redux.sp -o../../plugins/kigen-ac_redux_legacy.smx

cd ../latest
spcomp.exe kigen-ac_redux.sp -o../../plugins/kigen-ac_redux.smx
pause