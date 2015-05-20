Function New-UsnJournal {
    [cmdletbinding(
        SupportShouldProcess = $True
    )]
    Param (
        [parameter()]
        [ValidateScript({
            If ($_ -notmatch '^\w:$') {
                Throw "$($_) must match this format: C:"
            } Else {$True}
        })]
        [string]$DriveLetter = 'C:',
        [parameter()]
        [int64]$Size = 30MB,
        [parameter()]
        [int64]$Allocation = 4MB
    )
    [uint32]$AvailableBytes = 0
    #Create structure
    $CREATE_USN_JOURNAL_DATA = New-Object CREATE_USN_JOURNAL_DATA
    $CREATE_USN_JOURNAL_DATA.MaximumSize = $Size
    $CREATE_USN_JOURNAL_DATA.AllocationData = $Allocation

    #Allocate buffers
    $CUJD_Size = [System.Runtime.InteropServices.Marshal]::SizeOf($CREATE_USN_JOURNAL_DATA)
    $CUJD_Buffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($CUJD_Size)
    [PoshChJournal]::ZeroMemory($CUJD_Buffer, $CUJD_Size)
    [void][System.Runtime.InteropServices.Marshal]::StructureToPtr($CREATE_USN_JOURNAL_DATA, $CUJD_Buffer, $True)

    If ($PSCmdlet.ShouldProcess($Drive, 'Create Usn Journal')) {
        $VolumeHandle = OpenUSNJournal -DriveLetter $DriveLetter
        $Return = [PoshChJournal]::DeviceIoControl(
            $VolumeHandle,
            [EIOControlCode]::FSCTL_CREATE_USN_JOURNAL,
            $CUJD_Buffer,
            $CUJD_Size,
            [intptr]::Zero,
            0,
            [ref]$AvailableBytes,
            [intptr]::Zero
        )
        If (-Not $Return) {
            Write-Warning "Could not create Usn Journal on $($DriveLetter)"
        }        
    }
    #Cleanup
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($CUJD_Buffer)
    Get-UsnJournal
}