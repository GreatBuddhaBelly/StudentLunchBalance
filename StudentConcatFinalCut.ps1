<###################################################################################
# Student Balance Concatenate Script
# Takes a modified .csv pulled from the district
# 6 column format in .csv to be imported: StudentID, First Name, Last Name, Address,
# Phone Number, and Balance
#
# Ouputs a new .csv of just the students' last name, address, phone number, and balance
#
# Author: Peter Bitante
# Year: 2016-2017
###################################################################################>


Clear-Host
<#
  Parameters:
  $inFile : imports the .csv of the specified path and sorts them according to address in descending order
  $addressHash, $noDataHash, $finalStudentBalanceHash : 3 hashtables to hold the data according to their names
  $hashCount, $noDataCount : counters that are kept for debugging purposes
#>
##################################################
$addressHash = @{}
$noDataHash = @{}
$finalStudentBalanceHash = @{}
$hashCount =0
$noDataCount =0
##################################################



<#
  Function: fileImport
  Takes the .csv specified at head of script and parses out addresses that have adequate data and adds them to a hashtable.
  This function also parses out data with a lack of address and adds them to a seperate hashtable
#>
function fileImport{

Param(
  [String]$filePath = $args
)
    $filePath = Read-Host -Prompt "Please enter the file path including the file"

    if ($filePath.Equals("")){
      Write-Host "  You did not enter a file path. Please run the script again."

    }
    else {
      exportHashtableToCSV
#    $inFile = Import-Csv "D:\StudentLunchBalance\massagedStudentBalance.csv" -Header StudentID, FirstName, LastName, Address, PhoneNumber, Balance | sort Address -Descending
    $inFile = Import-Csv $filePath  -Header StudentID, FirstName, LastName, Address, PhoneNumber, Balance | sort Address -Descending

foreach ($studentLine in $inFile){


if ($studentLine.Balance -ne ""){
  # converts balance from pennies to dollars
  $studentLine.Balance = $studentLine.Balance/100

  #  sorts out null values of addresses
  if ($($studentLine).Address -ne ""){

      $addressHash[$studentLine.Address] += @($studentLine)
      $hashCount++
  }
}        else{
            $noDataHash[$studentLine.StudentID] += @($studentLine)
            $noDataCount++

        }

    }
    foreach ($addressKey in $addressHash){
      $addressHash.Get_Item($($addressKey))
    }
  }
}

<#
  Function: createKeyArray
  Creates an array of all addresses with sufficient data, returns the array to be used as keys
#>
function createKeyArray{

    $keysArray = @($addressHash.Keys)
    return $keysArray
}

<#
  Function: calculateBalance
  Calculates the final balance for the given address, returns the final balance
#>
function calculateBalance{
    param( [String]$addressIn )

    $hashKey = $addressHash.Get_Item($addressIn)

    $finalBalance = 0

    foreach ($studentObject in $hashKey){

        $finalBalance += $studentObject.Balance
    }

    return $finalBalance
}

<#
  Function: getStudentIDs
  Creates an array of student IDs with the given key
#>
function getStudentIDs{
    param( [String]$addressIn )

    $students = $addressHash.Get_Item($addressIn)

    $studentIDs = @()

    foreach ($studentObject in $students){

        $studentIDs += $studentObject.StudentID

    }
    return $studentIDs
}
<#
  Function: getPhoneNumbers
  Creates an array of phone numbers with the given key
#>
function getPhoneNumbers{
    param( [String]$addressIn )

    $students = $addressHash.Get_Item($addressIn)

    $phoneNumbers = @()

    foreach ($studentObject in $students){

        $phoneNumbers += $studentObject.PhoneNumber

    }
    return $phoneNumbers
}

<#
  Function: hashSearch
  Uses createKeyArray to create an array of all addresses that have sufficient data. Then
  iterates through the array and uses the calculateBalance function with given the parameter
  of the address. This then adds the given key and the calculated final balance to a hashtable, which is written to a .csv
#>

function hashSearch{

    $keys = createKeyArray
        foreach ($keyValue in $keys){
          Write-Host "`n `n`  $keyValue"
        $finalBalance = calculateBalance $keyValue
        $studentIDs = getStudentIDs $keyValue
        $studentPhoneNumbers = getPhoneNumbers $keyValue
        $finalStudentBalanceHash.Add($keyValue, $studentObject)
   }
   return $finalStudentBalanceHash
}

<#
  Function: exportCSV
  Gets the values of the data received and exports them column-based into a .csv
#>
function exportHashtableToCSV{

    hashSearch

    [array]$keys = createKeyArray

    for ($iter = 0; $iter -lt $keys.Count; $iter++){

        [String]$searchKey = $keys[$iter]

        $finalStudentBalanceHash.Get_Item($searchKey)

    }
    return $finalStudentBalanceHash
}


fileImport
<#  Console output for debugging
Write-Host "############ FULL DATA HASH START ############"
$addressHash
Write-Host "############# FULL DATA HASH END #############"
"`n`n"
Write-Host "############ NULL DATA HASH START ############"
$noDataHash
Write-Host "############# NULL DATA HASH END #############"
Write-Host "  Full Data count: " $hashCount
Write-Host "  Incomplete Data count: " $noDataCount
#>
