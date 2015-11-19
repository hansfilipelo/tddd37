#!/usr/bin/env python3

import sys,os

hashMap = dict()

for line in sys.stdin:

    data = line.split("\t")
    tableName = data[0]
    columnName = data[1].rstrip('\n')

    if tableName == "TABLE_NAME":
        continue

    if tableName in hashMap:
        hashMap[tableName] = hashMap[tableName] + [columnName]
    else:
        hashMap[tableName] = [columnName]

for key in hashMap.keys():
    printString = ""
    currList = hashMap[key]

    for index,colName in enumerate(currList):
        printString += colName
        if index < len(currList)-1:
            printString += ", "

    print(key + "(" + printString + ")")
    print("")
    print("")
