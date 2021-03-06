﻿Function Get-UsnJournal {
    [OutputType('System.Journal.UsnJournal')]
    [cmdletbinding(
        DefaultParameterSetName = '__DefaultParameterSet'
    )]
    Param (
        [parameter(ParameterSetName='DriveLetter')]
        [string]$DriveLetter = 'C:',
        [parameter(ParameterSetName='Handle')]
        [intptr]$VolumeHandle
    )
    $JournalData = New-Object USN_JOURNAL_DATA
    [long]$dwBytes=0
    If ($PSBoundParameters.ContainsKey('DriveLetter')) {
        $VolumeHandle = OpenUSNJournal -DriveLetter $DriveLetter
    }
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