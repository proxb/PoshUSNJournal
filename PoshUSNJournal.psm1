<#

    TODO:
        - New-UsnJournal
        - Remove-UsnJournal
        - Get-UsnJournalData
        - 
#>

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

 Try {
    [void][PoshChJournal]
 } 
 Catch {
    #region Module Builder
    $Domain = [AppDomain]::CurrentDomain
    $DynAssembly = New-Object System.Reflection.AssemblyName('ChJournalAssembly')
    $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run) # Only run in memory
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('ChJournal', $False)
    #endregion Module Builder

    #region Enums    
    #region GetLastErrorEnum Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('GetLastErrorEnum', 'Public', [int32])
    [void]$EnumBuilder.DefineLiteral('INVALID_HANDLE_VALUE', [int32] -1)
    [void]$EnumBuilder.DefineLiteral('ERROR_SUCCESS', [int32] 0x0)
    [void]$EnumBuilder.DefineLiteral('ERROR_INVALID_FUNCTION', [int32] 0x1)
    [void]$EnumBuilder.DefineLiteral('ERROR_FILE_NOT_FOUND', [int32] 0x2)
    [void]$EnumBuilder.DefineLiteral('ERROR_PATH_NOT_FOUND', [int32] 0x3)
    [void]$EnumBuilder.DefineLiteral('ERROR_TOO_MANY_OPEN_FILES', [int32] 0x4)
    [void]$EnumBuilder.DefineLiteral('ERROR_ACCESS_DENIED', [int32] 0x5)
    [void]$EnumBuilder.DefineLiteral('ERROR_INVALID_HANDLE', [int32] 0x6)
    [void]$EnumBuilder.DefineLiteral('ERROR_INVALID_DATA', [int32] 0xd)
    [void]$EnumBuilder.DefineLiteral('ERROR_HANDLE_EOF', [int32] 0x26)
    [void]$EnumBuilder.DefineLiteral('ERROR_NOT_SUPPORTED', [int32] 0x32)
    [void]$EnumBuilder.DefineLiteral('ERROR_INVALID_PARAMETER', [int32] 0x57)
    [void]$EnumBuilder.DefineLiteral('ERROR_JOURNAL_DELETE_IN_PROGRESS', [int32] 0x49a)
    [void]$EnumBuilder.DefineLiteral('ERROR_JOURNAL_NOT_ACTIVE', [int32] 0x49a)
    [void]$EnumBuilder.DefineLiteral('ERROR_JOURNAL_ENTRY_DELETED', [int32] 0x49d)
    [void]$EnumBuilder.DefineLiteral('ERROR_INVALID_USER_BUFFER', [int32] 0x6f8)
    [void]$EnumBuilder.CreateType()
    #endregion GetLastErrorEnum Enum
    #region USN_REASON Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('USN_REASON', 'Public', [int32])
    [void]$EnumBuilder.DefineLiteral('USN_REASON_DATA_OVERWRITE', [int32] 0x00000001)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_DATA_EXTEND', [int32] 0x00000002)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_DATA_TRUNCATION', [int32] 0x00000004)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_NAMED_DATA_OVERWRITE', [int32] 0x00000010)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_NAMED_DATA_EXTEND', [int32] 0x00000020)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_NAMED_DATA_TRUNCATION', [int32] 0x00000040)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_FILE_CREATE', [int32] 0x00000100)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_FILE_DELETE', [int32] 0x00000200)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_EA_CHANGE', [int32] 0x00000400)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_SECURITY_CHANGE', [int32] 0x00000800)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_RENAME_OLD_NAME', [int32] 0x00001000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_RENAME_NEW_NAME', [int32] 0x00002000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_INDEXABLE_CHANGE', [int32] 0x00004000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_BASIC_INFO_CHANGE', [int32] 0x00008000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_HARD_LINK_CHANGE', [int32] 0x00010000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_COMPRESSION_CHANGE', [int32] 0x00020000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_ENCRYPTION_CHANGE', [int32] 0x00040000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_OBJECT_ID_CHANGE', [int32] 0x00080000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_REPARSE_POINT_CHANGE', [int32] 0x00100000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_STREAM_CHANGE', [int32] 0x00200000)  
    [void]$EnumBuilder.DefineLiteral('USN_REASON_CLOSE', [int32] 0x80000000)
    [void]$EnumBuilder.CreateType()
    #endregion USN_REASON Enum
    #region EMethod Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('EMethod', 'Public', [uint32])
    [void]$EnumBuilder.DefineLiteral('Buffered', [uint32] 0x0)
    [void]$EnumBuilder.DefineLiteral('InDirect', [uint32] 0x1)
    [void]$EnumBuilder.DefineLiteral('OutDirect', [uint32] 0x2)
    [void]$EnumBuilder.DefineLiteral('Neither', [uint32] 0x3)
    [void]$EnumBuilder.CreateType()
    #endregion EMethod Enum
    #region EFileDevice Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('EFileDevice', 'Public', [uint32])
    [void]$EnumBuilder.DefineLiteral('DiskFileSystem', [uint32] 0x8)
    [void]$EnumBuilder.DefineLiteral('FileSystem', [uint32] 0x9)
    [void]$EnumBuilder.CreateType()
    #endregion EFileDevice Enum
    #region EIOControlCode Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('EIOControlCode', 'Public', [uint32])
    [void]$EnumBuilder.DefineLiteral('FSCTL_QUERY_USN_JOURNAL', [uint32] 0x900f4)
    [void]$EnumBuilder.DefineLiteral('FSCTL_READ_USN_JOURNAL', [uint32] 0x900bb)
    [void]$EnumBuilder.DefineLiteral('FSCTL_ENUM_USN_DATA', [uint32] 0x900f4)
    [void]$EnumBuilder.DefineLiteral('FSCTL_CREATE_USN_JOURNAL', [uint32] 0x900e7)
    [void]$EnumBuilder.DefineLiteral('FSCTL_DELETE_USN_JOURNAL', [uint32] 0x900f8)
    [void]$EnumBuilder.CreateType()
    #endregion EIOControlCode Enum
    #region FILE_INFORMATION_CLASS Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('FILE_INFORMATION_CLASS', 'Public', [int32])
    [void]$EnumBuilder.DefineLiteral('FileDirectoryInformation', [int32] 1)
    [void]$EnumBuilder.DefineLiteral('FileFullDirectoryInformation', [int32] 2)
    [void]$EnumBuilder.DefineLiteral('FileBothDirectoryInformation', [int32] 3)
    [void]$EnumBuilder.DefineLiteral('FileBasicInformation', [int32] 4)
    [void]$EnumBuilder.DefineLiteral('FileStandardInformation', [int32] 5)
    [void]$EnumBuilder.DefineLiteral('FileInternalInformation', [int32] 6)
    [void]$EnumBuilder.DefineLiteral('FileEaInformation', [int32] 7)
    [void]$EnumBuilder.DefineLiteral('FileAccessInformation', [int32] 8)
    [void]$EnumBuilder.DefineLiteral('FileNameInformation', [int32] 9)
    [void]$EnumBuilder.DefineLiteral('FileRenameInformation', [int32] 10)
    [void]$EnumBuilder.DefineLiteral('FileLinkInformation', [int32] 11)
    [void]$EnumBuilder.DefineLiteral('FileNamesInformation', [int32] 12)
    [void]$EnumBuilder.DefineLiteral('FileDispositionInformation', [int32] 13)
    [void]$EnumBuilder.DefineLiteral('FilePositionInformation', [int32] 14)
    [void]$EnumBuilder.DefineLiteral('FileFullEaInformation', [int32] 15)
    [void]$EnumBuilder.DefineLiteral('FileModeInformation', [int32] 16)
    [void]$EnumBuilder.DefineLiteral('FileAlignmentInformation', [int32] 17)
    [void]$EnumBuilder.DefineLiteral('FileAllInformation', [int32] 18)
    [void]$EnumBuilder.DefineLiteral('FileAllocationInformation', [int32] 19)
    [void]$EnumBuilder.DefineLiteral('FileEndOfFileInformation', [int32] 20)
    [void]$EnumBuilder.DefineLiteral('FileAlternateNameInformation', [int32] 21)
    [void]$EnumBuilder.DefineLiteral('FileStreamInformation', [int32] 22)
    [void]$EnumBuilder.DefineLiteral('FilePipeInformation', [int32] 23)
    [void]$EnumBuilder.DefineLiteral('FilePipeLocalInformation', [int32] 24)
    [void]$EnumBuilder.DefineLiteral('FilePipeRemoteInformation', [int32] 25)
    [void]$EnumBuilder.DefineLiteral('FileMailslotQueryInformation', [int32] 26)
    [void]$EnumBuilder.DefineLiteral('FileMailslotSetInformation', [int32] 27)
    [void]$EnumBuilder.DefineLiteral('FileCompressionInformation', [int32] 28)
    [void]$EnumBuilder.DefineLiteral('FileObjectIdInformation', [int32] 29)
    [void]$EnumBuilder.DefineLiteral('FileCompletionInformation', [int32] 30)
    [void]$EnumBuilder.DefineLiteral('FileMoveClusterInformation', [int32] 31)
    [void]$EnumBuilder.DefineLiteral('FileQuotaInformation', [int32] 32)
    [void]$EnumBuilder.DefineLiteral('FileReparsePointInformation', [int32] 33)
    [void]$EnumBuilder.DefineLiteral('FileNetworkOpenInformation', [int32] 34)
    [void]$EnumBuilder.DefineLiteral('FileAttributeTagInformation', [int32] 35)
    [void]$EnumBuilder.DefineLiteral('FileTrackingInformation', [int32] 36)
    [void]$EnumBuilder.DefineLiteral('FileIdBothDirectoryInformation', [int32] 37)
    [void]$EnumBuilder.DefineLiteral('FileIdFullDirectoryInformation', [int32] 38)
    [void]$EnumBuilder.DefineLiteral('FileValidDataLengthInformation', [int32] 39)
    [void]$EnumBuilder.DefineLiteral('FileShortNameInformation', [int32] 40)
    [void]$EnumBuilder.DefineLiteral('FileHardLinkInformation', [int32] 46)
    [void]$EnumBuilder.CreateType()
    #endregion FILE_INFORMATION_CLASS Enum
    #region UsnJournalDeleteFlags Enum
    $EnumBuilder = $ModuleBuilder.DefineEnum('UsnJournalDeleteFlags', 'Public', [uint32])
    [void]$EnumBuilder.DefineLiteral('USN_DELETE_FLAG_DELETE', [uint32] 0x1) 
    [void]$EnumBuilder.DefineLiteral('USN_DELETE_FLAG_NOTIFY', [uint32] 0x2)
    [void]$EnumBuilder.CreateType()
    #endregion UsnJournalDeleteFlags Enum
    #endregion Enums

    #region Structs
    $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
    #region USN_JOURNAL_DATA STRUCT
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('USN_JOURNAL_DATA', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('UsnJournalID', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('FirstUsn', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('NextUsn', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('LowestValidUsn', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('MaxUsn', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('MaximumSize', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('AllocationDelta', [long], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion USN_JOURNAL_DATA STRUCT
    #region READ_USN_JOURNAL_DATA STRUCT
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('READ_USN_JOURNAL_DATA', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('StartUsn', [int64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('ReasonMask', [int32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('ReturnOnlyOnClose', [int32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Timeout', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('BytesToWaitFor', [long], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('UsnJournalID', [long], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion READ_USN_JOURNAL_DATA STRUCT
    #region IO_STATUS_BLOCK STRUCT
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('IO_STATUS_BLOCK', $Attributes, [System.ValueType], 1, 0x10)
    [void]$STRUCT_TypeBuilder.DefineField('status', [UInt64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('information', [UInt64], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion IO_STATUS_BLOCK STRUCT
    #region OBJECT_ATTRIBUTES STRUCT
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('OBJECT_ATTRIBUTES', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('Length', [int32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('RootDirectory', [intptr], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('ObjectName', [intptr], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Attributes', [int32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('SecurityDescriptor', [int32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('SecurityQualityOfService', [int32], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion OBJECT_ATTRIBUTES STRUCT
    #region UNICODE_STRING STRUCT
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('UNICODE_STRING', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('Length', [int16], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('MaximumLength', [int16], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Buffer', [intptr], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion UNICODE_STRING STRUCT
    #region POINT STRUCT    
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('POINT', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('X', [int], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Y', [int], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion POINT STRUCT
    #region USN_RECORD STRUCT
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('USN_RECORD', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('RecordLength', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('MajorVersion', [uint16], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('MinorVersion', [uint16], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('FileReferenceNumber', [uint64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('ParentFileReferenceNumber', [uint64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Usn', [int64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('TimeStamp', [int64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Reason', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('SourceInfo', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('SecurityId', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('FileAttributes', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('FileNameLength', [uint16], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('FileNameOffset', [uint16], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion USN_RECORD STRUCT
    #region CREATE_USN_JOURNAL_DATA
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('CREATE_USN_JOURNAL_DATA', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('MaximumSize', [uint64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('AllocationData', [uint64], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion CREATE_USN_JOURNAL_DATA
    #region CREATE_USN_JOURNAL_DATA
    $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('DELETE_USN_JOURNAL_DATA', $Attributes, [System.ValueType], 8)
    [void]$STRUCT_TypeBuilder.DefineField('UsnJournalID', [uint64], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('DeleteFlags', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.DefineField('Reserved', [uint32], 'Public')
    [void]$STRUCT_TypeBuilder.CreateType()
    #endregion CREATE_USN_JOURNAL_DATA
    #endregion Structs

    #region Initialize Type Builder
    $TypeBuilder = $ModuleBuilder.DefineType('PoshChJournal', 'Public, Class')
    #endregion Initialize Type Builder

    #region Methods
    #region CreateFile METHOD
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'CreateFile', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [IntPtr ], #Method Return Type
        [Type[]] @(
            [string],                   # Filename
            [System.IO.FileAccess],     # Access
            [System.IO.FileShare],      # Share
            [intptr],                   # Security attributes
            [System.IO.FileMode],       # Creation Disposition
            [System.IO.FileAttributes], # Flags and Attributes
            [intptr]                    # Template File
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'CreateFile', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion CreateFile METHOD
    #region NtCreateFile METHOD
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'NtCreateFile', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [int], #Method Return Type
        [Type[]] @(
            [intptr].MakeByRefType(), # File Handle
            [System.IO.FileAccess],                       # Access
            [OBJECT_ATTRIBUTES].MakeByRefType(),          # Object Attributes
            [IO_STATUS_BLOCK].MakeByRefType(),            # IO Status
            [long].MakeByRefType(),                       # Allocation Size
            [Uint32],                                     # File Attributes
            [System.IO.FileShare],                        # Share
            [Uint32],                                     # CreateDisposition
            [Uint32],                                     # CreateOptions
            [IntPtr],                                     # EABuffer
            [Uint32]                                       # EALength
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'NtCreateFile', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('ntdll.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion NtCreateFile METHOD
    #region NtQueryInformationFile METHOD
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'NtQueryInformationFile', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [intptr], #Method Return Type
        [Type[]] @(
            [intptr],                          # File Handle
            [IO_STATUS_BLOCK].MakeByRefType(), # IO Status Block
            [intptr],                          # pInfo Block
            [Uint32],                          # Length
            [FILE_INFORMATION_CLASS]           # FileInformation
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'NtQueryInformationFile', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('ntdll.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion NtQueryInformationFile METHOD
    #region DeviceIoControl METHODs
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'DeviceIoControl', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [bool ], #Method Return Type
        [Type[]] @(
            [intptr],                           # hDevice
            [uint32],                           # IOControlCode
            [long].MakeByRefType(),             # InBuffer
            [int],                              # InBufferSize
            [USN_JOURNAL_DATA].MakeByRefType(),             # OutBuffer
            [int],                              # OutBufferSize
            [int].MakeByRefType(),              # lpBytesReturned
            [intptr] # lpOverlapped
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'DeviceIoControl', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)

    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'DeviceIoControl', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [bool ], #Method Return Type
        [Type[]] @(
            [intptr],                           # hDevice
            [uint32],                           # IOControlCode
            [intptr],                             # InBuffer
            [int],                              # InBufferSize
            [intptr],                           # OutBuffer
            [int],                              # OutBufferSize
            [int].MakeByRefType(),              # lpBytesReturned
            [intptr] # lpOverlapped
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'DeviceIoControl', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion DeviceIoControl METHODs
    #region CloseHandle METHOD
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'CloseHandle', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [bool ], #Method Return Type
        [Type[]] @(
            [intptr] # Handle
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'CloseHandle', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion CloseHandle METHOD
    #region ZeroMemory
    $PInvokeMethod = $TypeBuilder.DefineMethod(
        'ZeroMemory', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [bool ], #Method Return Type
        [Type[]] @(
            [intptr], # Destination
            [intptr]  # Size
        ) #Method Parameters
    )
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
    )

    $FieldValueArray = [Object[]] @(
        'RtlZeroMemory', #CASE SENSITIVE!!
        $True,
        $False
    )

    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
    )

    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion ZeroMemory
    #endregion Methods

    #region Create Type
    [void]$TypeBuilder.CreateType()
    #endregion Create Type
}

#region Private Helper Functions
Function ConvertToUSNReason {
    [cmdletbinding()]
    Param(
        $ReasonCode
    )
    $List = New-Object System.Collections.ArrayList
    Switch ($ReasonCode) {
        ($ReasonCode -BOR 0x00000001) {[void]$List.Add('USN_REASON_DATA_OVERWRITE')}
        ($ReasonCode -BOR 0x00000002) {[void]$List.Add('USN_REASON_DATA_EXTEND')}
        ($ReasonCode -BOR 0x00000004) {[void]$List.Add('USN_REASON_DATA_TRUNCATION')}
        ($ReasonCode -BOR 0x00000010) {[void]$List.Add('USN_REASON_NAMED_DATA_OVERWRITE')}
        ($ReasonCode -BOR 0x00000020) {[void]$List.Add('USN_REASON_NAMED_DATA_EXTEND')}
        ($ReasonCode -BOR 0x00000040) {[void]$List.Add('USN_REASON_NAMED_DATA_TRUNCATION')}
        ($ReasonCode -BOR 0x00000100) {[void]$List.Add('USN_REASON_FILE_CREATE')}
        ($ReasonCode -BOR 0x00000200) {[void]$List.Add('USN_REASON_FILE_DELETE')}
        ($ReasonCode -BOR 0x00000400) {[void]$List.Add('USN_REASON_EA_CHANGE')}
        ($ReasonCode -BOR 0x00000800) {[void]$List.Add('USN_REASON_SECURITY_CHANGE')}
        ($ReasonCode -BOR 0x00001000) {[void]$List.Add('USN_REASON_RENAME_OLD_NAME')}
        ($ReasonCode -BOR 0x00002000) {[void]$List.Add('USN_REASON_RENAME_NEW_NAME')}
        ($ReasonCode -BOR 0x00004000) {[void]$List.Add('USN_REASON_INDEXABLE_CHANGE')}
        ($ReasonCode -BOR 0x00008000) {[void]$List.Add('USN_REASON_BASIC_INFO_CHANGE')}
        ($ReasonCode -BOR 0x00010000) {[void]$List.Add('USN_REASON_HARD_LINK_CHANGE')}
        ($ReasonCode -BOR 0x00020000) {[void]$List.Add('USN_REASON_COMPRESSION_CHANGE')}
        ($ReasonCode -BOR 0x00040000) {[void]$List.Add('USN_REASON_ENCRYPTION_CHANGE')}
        ($ReasonCode -BOR 0x00080000) {[void]$List.Add('USN_REASON_OBJECT_ID_CHANGE')}
        ($ReasonCode -BOR 0x00100000) {[void]$List.Add('USN_REASON_REPARSE_POINT_CHANGE')}
        ($ReasonCode -BOR 0x00200000) {[void]$List.Add('USN_REASON_STREAM_CHANGE')}
        ($ReasonCode -BOR 0x80000000) {[void]$List.Add('USN_REASON_CLOSE')}
    }
    $List -join ', '
} 
Function NewUsnEntry {
    [cmdletbinding()]
    Param (
        [intptr]$UsnRecord
    )
    #region Constants
    $FILE_ATTRIBUTE_DIRECTORY = 0x00000010
    #endregion Constants

    #region Marshal to Struct
    $USN_RECORD = [System.Runtime.InteropServices.Marshal]::PtrToStructure($UsnRecord, [type][USN_RECORD])
    #endregion Marshal to Struct

    #region Data Conversions 
    $Name = [System.Runtime.InteropServices.Marshal]::PtrToStringUni([intptr](
        $UsnRecord.ToInt64()+$USN_RECORD.FileNameOffset),
        ($USN_RECORD.FileNameLength/2)
    )
    #endregion Data Conversions 

    #region Object Creation
    If (($USN_RECORD.FileAttributes -BAND $FILE_ATTRIBUTE_DIRECTORY) -eq 0) {
        $IsFile = $True
        $IsFolder = $False
    } Else {
        $IsFile = $False
        $IsFolder = $True    
    }
    [pscustomobject]@{
        FileName = $Name
        TimeStamp = [DateTime]::FromFileTime($USN_RECORD.TimeStamp)
        Reason = ConvertToUsnReason $USN_RECORD.Reason
        RecordLength = $USN_RECORD.RecordLength
        FileReferenceNumber = $USN_RECORD.FileReferenceNumber
        ParentFileReferenceNumber = $USN_RECORD.ParentFileReferenceNumber
        USN = $USN_RECORD.USN
        FileAttributes = [System.IO.FileAttributes]($USN_RECORD.FileAttributes)
        IsFile = $IsFile
        IsDirectory = $IsFolder
    }
    #endregion Object Creation
}
Function OpenUSNJournal {
    Param ($DriveLetter = 'c:')

    $FileName = "\\.\$DriveLetter"
    $Access = [System.IO.FileAccess]::Read -BOR [System.IO.FileAccess]::Write
    $ShareAccess = [System.IO.FileShare]::Read -BOR [System.IO.FileShare]::Write
    $FileMode = [System.IO.FileMode]::Open
    $VolumeHandle = [PoshChJournal]::CreateFile(
        $FileName,
        $Access,
        $ShareAccess,
        [intptr]::Zero,
        $FileMode,
        0,
        [intptr]::Zero
    )
    If ($VolumeHandle -eq -1) {
        Write-Warning ("CreateFile failed: 0x{0:x}" -f [System.Runtime.InteropServices.Marshal]::GetHRForLastWin32Error())
    } Else {
        $VolumeHandle
    }
}
#endregion Private Helper Functions

#region Load Functions
Try {
    Get-ChildItem "$ScriptPath\Scripts" -Filter *.ps1 | Select -Expand FullName | ForEach {
        $Function = Split-Path $_ -Leaf
        . $_
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
#endregion Load Functions

#region Aliases
New-Alias -Name guj -Value Get-UsnJournal
New-Alias -Name guje -Value Get-UsnJournalEntry
#endregion Aliases

#region Format and Type Data
Update-FormatData "$ScriptPath\TypeData\PoshUsnJournal.Format.ps1xml"
#endregion Format and Type Data

Export-ModuleMember -Function *-USN* -Alias *
