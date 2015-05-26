Function Get-UsnJournalEntry {
    <#
        .SYNOPSIS
            Views the entries of the Usn Journal. Also allows the use of -Wait to 
            watch incoming entries.

        .DESCRIPTION
            Views the entries of the Usn Journal. Includes full file path and also allows 
            the use of -Wait to watch incoming entries.

        .PARAMETER DriveLetter
            Drive that will used to look at journal entries
        
        .PARAMETER ReasonMask
            Possble values to use to look at various journal entries. Possible
            values are:

            USN_REASON_DATA_OVERWRITE
            USN_REASON_DATA_EXTEND
            USN_REASON_DATA_TRUNCATION
            USN_REASON_NAMED_DATA_OVERWRITE
            USN_REASON_NAMED_DATA_EXTEND
            USN_REASON_NAMED_DATA_TRUNCATION
            USN_REASON_FILE_CREATE
            USN_REASON_FILE_DELETE
            USN_REASON_EA_CHANGE
            USN_REASON_SECURITY_CHANGE
            USN_REASON_RENAME_OLD_NAME
            USN_REASON_RENAME_NEW_NAME
            USN_REASON_INDEXABLE_CHANGE
            USN_REASON_BASIC_INFO_CHANGE
            USN_REASON_HARD_LINK_CHANGE
            USN_REASON_COMPRESSION_CHANGE
            USN_REASON_ENCRYPTION_CHANGE
            USN_REASON_OBJECT_ID_CHANGE
            USN_REASON_REPARSE_POINT_CHANGE
            USN_REASON_STREAM_CHANGE
            USN_REASON_CLOSE

        .PARAMETER StartUsn
            The starting USN number to begin walking the journal. If this isn't an exact match,
            an error will occur. It is recommended to either set this to 0 or look at the 
            NextUSN from Get-UsnJournal to use.

        .PARAMETER Tail
            Starts watching the journal at the NextUsn number. It is best to use this
            in conjunction with -Wait.

        .PARAMETER Wait
            This will watch for new entries in the Usn Journal once it has reached the end of the current
            journal entries. This can be used with -Tail to begin tracking the current entries being
            updated in the journal.

        .PARAMETER Paging
            This allows for paging of the journal entries based on the available bytes in the buffer and 
            is not related to the available console space.

        .NOTES
            Name: Get-UsnJournalEntry
            Author: Boe Prox
            Version History
                1.0 //Boe Prox
                    -Initial Version

        .OUTPUT
            System.Journal.UsnEntry

        .EXAMPLE
            Get-UsnJournalEntry

            Description
            -----------
            Displays all journal entries starting from the beginning of the journal.

        .EXAMPLE
            Get-UsnJournalEntry -ReasonMask USN_REASON_RENAME_OLD_NAME, USN_REASON_RENAME_NEW_NAME, USN_REASON_FILE_DELETE | 
            Select-Object -First 5 -Property Timestamp, USN, FileName, FullName, Reason

            Description
            -----------
            Displays all journal entries starting from the beginning of the journal that have had some sort of deletion. This highlights
            the fullname of each file that has been updated.

        .EXAMPLE
            Get-UsnJournalEntry -Tail -Wait

            Description
            -----------
            Starts watching the journal at the very end of the last entry and updates
            with new entries as the journal is updated.
    #>
    [OutputType('System.Journal.UsnEntry')]
    [cmdletbinding(
        DefaultParameterSetName = '__DefaultSetName'
    )]
    Param (
        [parameter()]
        [string]$DriveLetter = 'C:',
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [USN_REASON]$ReasonMask,
        [parameter()]
        [int64]$StartUsn,
        [parameter(ParameterSetName='TailWait')]
        [switch]$Tail,
        [parameter(ParameterSetName='TailWait')]
        [switch]$Wait,
        [parameter(ParameterSetName='Paging')]
        [switch]$Paging
    )
    If ($PSBoundParameters.ContainsKey('Debug')){
        $DebugPreference = 'Continue'
    }
    $PSBoundParameters.GetEnumerator() | ForEach {
        Write-Verbose $_
    }
    If (-NOT $PSBoundParameters.ContainsKey('ReasonMask')) {
        $ReasonMask = [USN_REASON]([USN_REASON].GetEnumNames())
    }
    $VolumeHandle = OpenUSNJournal -DriveLetter $DriveLetter
    If ($VolumeHandle) {
        $JournalData = Get-USNJournal -VolumeHandle $VolumeHandle
    }
    If ($JournalData) {
        Write-Verbose 'Creating buffer'
        $DataSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][uint64]) * 0x4000
        $DataBuffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($DataSize)
        [void][PoshChJournal]::ZeroMemory($DataBuffer, $DataSize)
        $AvailableBytes = 0

        $ReadData = New-Object READ_USN_JOURNAL_DATA
        If ($PSBoundParameters.ContainsKey('StartUsn')) {
            $ReadData.StartUsn = $StartUsn
        } ElseIf ($PSBoundParameters.ContainsKey('Tail')) {
            $ReadData.StartUsn = $JournalData.NextUsn
        } Else {
            $ReadData.StartUsn = $JournalData.FirstUsn
        }
        Write-Debug "Starting USN: $($ReadData.StartUsn)"
        $ReadData.ReasonMask = $ReasonMask
        $ReadData.UsnJournalID = $JournalData.UsnJournalID
        $ReadDataSize = [System.Runtime.InteropServices.Marshal]::SizeOf($ReadData)
        $ReadBuffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($ReadDataSize)
        [void][PoshChJournal]::ZeroMemory($ReadBuffer, $ReadDataSize)

        [System.Runtime.InteropServices.Marshal]::StructureToPtr($ReadData, $ReadBuffer, $True)
        $ReadMore = $True
        $Page = 0
        While ($ReadMore) {       
            $Page++
            $return = [PoshChJournal]::DeviceIoControl(
                $VolumeHandle,
                [EIOControlCode]::FSCTL_READ_USN_JOURNAL,
                $ReadBuffer,
                $ReadDataSize,
                $DataBuffer,
                $DataSize,
                [ref]$AvailableBytes,
                [intptr]::Zero
            )
            If ($return) {
                Write-Verbose "Processing USN entries"
                $Uint64Size = [System.Runtime.InteropServices.Marshal]::SizeOf([type][uint64])
                $UsnRecord =  New-Object intptr -ArgumentList ($DataBuffer.ToInt64() + $Uint64Size)
                Write-Debug "Initial Bytes: $($AvailableBytes)"
                While ($AvailableBytes -gt 60) {
                    $UsnEntry = NewUsnEntry -UsnRecord $UsnRecord -DriveLetter $DriveLetter -VolumeHandle $VolumeHandle
                    $UsnEntry.pstypenames.insert(0,'System.Journal.UsnEntry')
                    $UsnEntry
                    $UsnRecord =  New-Object IntPtr -ArgumentList ($UsnRecord.ToInt64() + $UsnEntry.RecordLength)
                    $AvailableBytes = $AvailableBytes - $UsnEntry.RecordLength
                    Write-Debug "Available Bytes: $($AvailableBytes)"
                }           
            } Else {
                Write-Warning 'Issue occurred reading Usn entries!'
                Break
            }            

            $NextUSN = [System.Runtime.InteropServices.Marshal]::ReadInt64($DataBuffer,0)
            Write-Debug "Next USN: $($NextUSN) - Journal Next USN: $($JournalData.NextUsn)"
            $NoMoreData = $NextUsn -ge $JournalData.NextUsn
            If (-NOT $NoMoreData -OR $PSBoundParameters.ContainsKey('Wait')) {
                If ($NoMoreData) {
                    Write-Verbose 'Checking for more data'
                    While ($NextUsn -ge $JournalData.NextUsn) {
                        Start-Sleep -Milliseconds 500
                        $JournalData = Get-USNJournal -VolumeHandle $VolumeHandle                    
                    }
                }
                If ($PSBoundParameters.ContainsKey('Paging')) {
                    While ($Choice -notmatch 'c|q') {
                        $Choice = Read-Host "Page: $($Page) - Press C to display next page or Q to Quit"
                    }
                }
                If ($Choice -eq 'c' -OR (-NOT $PSBoundParameters.ContainsKey('Paging'))) {
                    Write-Verbose "Using next Starting USN: $($NextUSN)"
                    [System.Runtime.InteropServices.Marshal]::WriteInt64($ReadBuffer, $NextUSN)
                    Remove-Variable Choice -ErrorAction SilentlyContinue
                } Else {
                    Write-Verbose "Halting operation"
                    $ReadMore = $False
                    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ReadBuffer)
                    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($DataBuffer)                
                }
            } Else {
                $ReadMore = $False
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ReadBuffer)
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($DataBuffer)
            }
        }
    }
}