Function Get-UsnJournal {
﻿        <#
        .SYNOPSIS
            Used to pull the USN Journal information
 
        .DESCRIPTION
            Used to pull the USN Journal information
 
        .PARAMETER DriveLetter
            Drive to look at USNJournal. Must be used with colon (:).
            ex. C:
 
        .NOTES
            Name: Get-UsnJournal
            Author: Boe Prox
 
        .EXAMPLE
            Get-UsnJournal -DriveLetter C:
 
            UsnJournalID       FirstUsn            NextUsn             MaximumSize
            ------------       --------            -------             -----------
            130765388729068777 914358272           951411872           33554432
 
            Description
            -----------
            Retrieves the USN Journal information on the C: drive.
 
    #>
    [OutputType('System.Journal.UsnJournal')]
    Param ($DriveLetter = 'C:')
    $JournalData = New-Object USN_JOURNAL_DATA
    [long]$dwBytes=0
    $VolumeHandle = OpenUSNJournal -DriveLetter $DriveLetter
    If ($VolumeHandle -AND $VolumeHandle -ne -1) {
        $return = [PoshChJournal]::DeviceIoControl(
            $VolumeHandle,
            [EIOControlCode]::FSCTL_QUERY_USN_JOURNAL,
            [ref]$Null,
            0,
            [ref]$JournalData,
            [System.Runtime.InteropServices.Marshal]::SizeOf([type][USN_JOURNAL_DATA]),
            [ref]$dwBytes,
            [intptr]::Zero
        )
        If ($Return) {
            $JournalData.pstypenames.insert(0,'System.Journal.UsnJournal')
            $JournalData
        }
    } Else {
        Write-Warning "Unable to get handle of volume <$($DriveLetter)>!"
    }
}
