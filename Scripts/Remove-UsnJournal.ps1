Function Remove-UsnJournal {
    [cmdletbinding(
        SupportsShouldProcess = $True
    )]
    Param (
        [parameter()]
        [ValidateScript({
            If ($_ -notmatch '^\w:$') {
                Throw "$($_) must match this format: C:"
            } Else {$True}
        })]
        [string]$DriveLetter = 'C:'
    )
    [uint32]$AvailableBytes = 0
    $JournalID = Get-UsnJournal | Select -ExpandProperty UsnJournalID

    #Create Structure    
    $DELETE_USN_JOURNAL_DATA = New-Object DELETE_USN_JOURNAL_DATA
    $DELETE_USN_JOURNAL_DATA.UsnJournalID = $JournalID
    $DELETE_USN_JOURNAL_DATA.DeleteFlags = [UsnJournalDeleteFlags]::'USN_DELETE_FLAG_DELETE'

    #Allocate buffers
    $DUJD_Size = [System.Runtime.InteropServices.Marshal]::SizeOf($DELETE_USN_JOURNAL_DATA)
    $DUJD_Buffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($DUJD_Size)
    [PoshChJournal]::ZeroMemory($DUJD_Buffer, $DUJD_Size)
    [void][System.Runtime.InteropServices.Marshal]::StructureToPtr($DELETE_USN_JOURNAL_DATA, $DUJD_Buffer, $True)

    If ($PSCmdlet.ShouldProcess($JournalID, 'Remove Usn Journal')) {
        $VolumeHandle = OpenUSNJournal -DriveLetter $DriveLetter
        $Return = [PoshChJournal]::DeviceIoControl(
            $VolumeHandle,
            [EIOControlCode]::FSCTL_DELETE_USN_JOURNAL,
            $DUJD_Buffer,
            $DUJD_Size,
            [intptr]::Zero,
            0,
            [ref]$AvailableBytes,
            [intptr]::Zero
        )
        If (-Not $Return) {
            Write-Warning "Could not remove Usn Journal on $($DriveLetter)"
        }        
    }
    #Cleanup
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($DUJD_Buffer)
}