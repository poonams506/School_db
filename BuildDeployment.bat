@echo off

rem Set variables (replace with your actual values)
set "SERVER_NAME=4.240.106.163"
set "DATABASE_USER=sa"
set "DATABASE_PASSWORD=Logicalhunt2024$$"
set "SOLUTION_FILE=SchoolDatabase.sln"
set "PROJECT_NAME=SchoolDatabase"
set "CONFIGURATION=Release"

set "DATABASE_NAMES=LogicalhuntDemoSchool LogicalhuntUATSchool demo1 demo2 santoshtestingdb deepaklocaldb"

setlocal EnableDelayedExpansion
rem Build the project (optional, if you want to generate a new dacpac)
msbuild "%SOLUTION_FILE%" /p:Configuration=%CONFIGURATION%

for %%a in (!DATABASE_NAMES!) do (

rem Publish the project changes to the database
sqlpackage.exe /Action:Publish /SourceFile:"%PROJECT_NAME%\bin\Release\%PROJECT_NAME%.dacpac" /TargetDatabaseName:"%%a" /TargetServerName:"%SERVER_NAME%" /TargetUser:"%DATABASE_USER%" /TargetPassword:"%DATABASE_PASSWORD%"  /TargetTrustServerCertificate:True /p:BlockOnPossibleDataLoss=False


)

echo Script execution complete.
set /p userInput="Press any key to continue..."
