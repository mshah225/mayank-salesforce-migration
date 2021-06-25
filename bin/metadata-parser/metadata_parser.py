import csv
import json
import time
import os

class metadataItem:
    def __init__(self, metadataName, profiles, permissionSets, permissionSetGroups):
        self.metadataName = metadataName
        self.profiles = profiles
        self.permissionSets = permissionSets
        self.permissionSetGroups = permissionSetGroups

filePathToRead = './queries/'
fileToRead = ''
filePathToWrite = './results/output/'
fileToWrite = ''
headersToWrite = ['Old Nomenclature', 'New Nomenclature', 'Profiles', 'Permission Sets', 'Permission Set Groups']
rowsToWrite = []

metadataType = ''
metadataInfo = {}
metadataOutput = []

apexClassLastModified = os.path.getmtime(filePathToRead + "query_ApexClass.csv")
apexPageLastModified = os.path.getmtime(filePathToRead + "query_ApexPage.csv")

if apexClassLastModified > apexPageLastModified:
    metadataType = 'ApexClass'
    fileToRead = 'query_' + metadataType + '.csv'
    fileToWrite = "metadata_output_" + metadataType + "--" + time.strftime("%Y%m%d-%H%M%S") + ".csv"
elif apexClassLastModified < apexPageLastModified:
    metadataType = 'ApexPage'
    fileToRead = 'query_' + metadataType + '.csv'
    fileToWrite = "metadata_output_" + metadataType + "--" + time.strftime("%Y%m%d-%H%M%S") + ".csv"

with open(filePathToRead + fileToRead) as csvFile:
    reader = csv.reader(csvFile, delimiter=',')
    for index, row in enumerate(reader):
        if index > 0:
            metadataInfo[row[1]] = row[2]

    for metadataItemName, securityDataRaw in metadataInfo.items():
        profileList = []
        permissionSetList = []
        permissionSetGroupList = []

        securityData = json.loads(securityDataRaw)
        for i in range(len(securityData)):
            if securityData[i]["Parent"]["Type"] == "Group":
                permissionSetGroupList.append(securityData[i]["Parent"]["Label"])
            elif securityData[i]["Parent"]["Type"] == "Regular":
                permissionSetList.append(securityData[i]["Parent"]["Label"])
            elif securityData[i]["Parent"]["Type"] == "Profile":
                profileList.append(securityData[i]["Parent"]["Profile"]["Name"])
        metadataOutput.append(metadataItem(metadataItemName, profileList, permissionSetList, permissionSetGroupList))

    for metadataItemInstance in metadataOutput:
        rowsToWrite.append([metadataItemInstance.metadataName, '', metadataItemInstance.profiles, metadataItemInstance.permissionSets, metadataItemInstance.permissionSetGroups])

with open(filePathToWrite + fileToWrite, 'w') as csvFile:
    writer = csv.writer(csvFile)
    writer.writerow(headersToWrite)
    writer.writerows(rowsToWrite)
