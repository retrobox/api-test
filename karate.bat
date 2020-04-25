@echo off
color 2
cls
java -cp karate.jar;. com.intuit.karate.Main %* test
pause