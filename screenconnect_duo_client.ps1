#!ps
#timeout=9000000
#maxlength=9000000
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; curl https://dl.duosecurity.com/duo-win-login-latest.exe -o C:\Users\Administrator\Downloads\duo-win-login-latest.exe ; C:\Users\Administrator\Downloads\duo-win-login-latest.exe /S /V" /qn IKEY="XXXXXXXXXXXXXXXXXXx" SKEY="XXXXXXXXXXXXXXXXXXXXXXXX" HOST="XXXXXXXXXXXXXXXXXXX" AUTOPUSH="#1" FAILOPEN="#0""
