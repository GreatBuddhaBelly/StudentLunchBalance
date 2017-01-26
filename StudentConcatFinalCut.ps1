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
$studentsArray = @()
$hashCount =0
$noDataCount =0
$outputFilePath = Read-Host -Prompt "Please enter the output file path"
##################################################
Clear-Host



<#
Function: fileImport
Takes the .csv specified at head of script and parses out addresses that have adequate data and adds them to a hashtable.
This function also parses out data with a lack of address and adds them to a seperate hashtable
#>
function fileImport{
Param(
  [String]$inFilePath = $args
)

    # Checks file path
    if ($inFilePath.Equals("")){
        $inFilePath = Read-Host -Prompt "Please enter the file path including the file"

            if ($inFilePath.Equals("")){
            Write-Host "  You did not enter a file path. Please run the script again."
        }
    }


    $inFile = Import-Csv $inFilePath -Header StudentID, FirstName, LastName, Address, PhoneNumber, Balance | sort Address -Descending

    foreach ($studentLine in $inFile){

        if ($studentLine.Balance -ne ""){
            # converts balance from pennies to dollars
            $studentLine.Balance = $studentLine.Balance/100

            #  sorts out null values of addresses
            if ($studentLine.Address -ne ""){
                $addressHash[$studentLine.Address] += @($studentLine)
                $hashCount++
            }
        }
        else{
            $noDataHash[$studentLine.StudentID] += @($studentLine)
            $noDataCount++
        }
    }
}

<#
Function: createKeyArray
Creates an array of all addresses with sufficient data, returns the array to be used as keys
#>
function createKeyArray{
    $keysArray = @()

    foreach ($address in $addressHash.Keys){
        $keysArray += $address
    }
    return $keysArray
}


<#
Function: hashSearch
Uses createKeyArray to create an array of all addresses that have sufficient data. Then
iterates through the array and uses the calculateBalance function with given the parameter
of the address. This then adds the given key and the calculated final balance to a hashtable, which is written to a .csv
#>

function hashSearch{

    $keys = createKeyArray

    foreach ($key in $keys){
        $addressTotalBalance = @()
        $studentPerKeyCount = 0
        $finalBalancePerAddress = 0

        foreach ($student in $addressHash.Get_Item($key)){
            $studentObj = New-Object PSObject
            $studentPerKeyCount++
            $studentAddress = $($student).Address
            $finalBalancePerAddress += $($student).Balance
            <#  Used for debugging student information to ensure proper data output
            #          Write-Host "  Student object:" $student.FirstName " " $student.LastName
            #          Write-Host "  Student Address:" $studentAddress `n
            #>
        }

        # declaring the headers and data for each line in the output .csv
        $studentObj | add-member -membertype NoteProperty -name Address -value $key

        $studentObj | add-member -membertype NoteProperty -name "Number of Students" -value $studentPerKeyCount

        $studentObj | add-member -membertype NoteProperty -name "Final Balance" -value $finalBalancePerAddress

        $studentObj | Export-CSV $outputFilePath -Append -NoTypeInformation

        $studentObj = $null
        #        Write-Host "  Students per address with balance at: "$key "  Number of kids: "$studentPerKeyCount "  Total Balance: "$finalBalancePerAddress

    }
}


##################################################### FileImport works as a function, must get individual student objects out of hashtable to
##################################################### write to output .csv file


fileImport
hashSearch

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
