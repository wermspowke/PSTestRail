$Script:ApiClient = $null
$Script:Debug = $false

function Initialize-TestRailSession
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Uri]
        $Uri,

        [Parameter(Mandatory=$true, Position=1)]
        [String]
        $User,

        [Parameter(Mandatory=$true, Position=2)]
        [Alias("ApiKey")]
        [String]
        $Password
    )

    $Script:ApiClient = New-Object Gurock.TestRail.APIClient -ArgumentList $Uri
    $Script:ApiClient.User = $User
    $Script:ApiClient.Password = $Password
}

function Get-TestRailProjects
{
    param
    (
        [Parameter(Mandatory=$false)]
        [bool]
        $IsCompleted
    )

    $Uri = "get_projects"
    $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    if ( $PSBoundParameters.ContainsKey("IsCompleted") )
    {
        if ( $IsCompleted -eq $true )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ is_completed = 1 } 
        }
        else
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ is_completed = 0 }
        }
    }

    Request-TestRailUri -Uri $Uri -Parameters $Parameters
}

function Get-TestRailSuites
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int[]]
        $ProjectId
    )

    PROCESS
    {
        foreach ( $PID in $ProjectId )
        {
            $Uri = "get_suites/$PID"
            $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

            Request-TestRailUri -Uri $Uri -Parameters $Parameters
        }
    }
}

function Get-TestRailSuite
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int[]]
        $SuiteId
    )

    PROCESS
    {
        foreach ( $SID in $SuiteId )
        {
            $Uri = "get_suite/$SID"
            $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

            Request-TestRailUri -Uri $Uri -Parameters $Parameters
        }
    }
}

function Get-TestRailSections
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('project_id')]
        [int]
        $ProjectId,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Alias('suite_id')]
        [int]
        $SuiteId
    )

    PROCESS
    {
        $Uri = "get_sections/$ProjectId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("SuiteId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ suite_id = $SuiteId } 
        }

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailRuns
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('project_id')]
        [int]
        $ProjectId
    )

    PROCESS
    {
        $Uri = "get_runs/$ProjectId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailRun
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $RunId
    )

    PROCESS
    {
        $Uri = "get_run/$RunId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailProject
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('project_id')]
        [int]
        $ProjectId
    )

    PROCESS
    {
        $Uri = "get_project/$ProjectId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailTests
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$false)]
        [int[]]
        $StatusId
    )

    PROCESS
    {
        $Uri = "get_tests/$RunId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("StatusId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ status_id = [String]::Join(",", $StatusId ) }
        }

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailResults
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $TestId,

        [Parameter(Mandatory=$false)]
        [int]
        $Limit,

        [Parameter(Mandatory=$false)]
        [int]
        $Offset,

        [Parameter(Mandatory=$false)]
        [int[]]
        $StatusId
    )

    PROCESS
    {
        $Uri = "get_results/$TestId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("Offset") -and (-not $PSBoundParameters.ContainsKey("Limit") ) )
        {
            throw New-Object System.ArgumentException -ArgumentList "Cannot specify Offset without Limit"
        }

        if ( $PSBoundParameters.ContainsKey("Limit") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ limit = $Limit }

            if ( $PSBoundParameters.ContainsKey("Offset") )
            {
                Add-UriParameters -Parameters $Parameters -Hash @{ offset = $Offset }
            }
        }

        if ( $PSBoundParameters.ContainsKey("StatusId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ status_id = [String]::Join(",", $StatusId ) }
        }

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailResultsForCase
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('case_id')]
        [int]
        $CaseId,

        [Parameter(Mandatory=$false)]
        [int]
        $Limit,

        [Parameter(Mandatory=$false)]
        [int]
        $Offset,

        [Parameter(Mandatory=$false)]
        [int[]]
        $StatusId
    )

    PROCESS
    {
        $Uri = "get_results_for_case/$RunId/$CaseId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("Offset") -and (-not $PSBoundParameters.ContainsKey("Limit") ) )
        {
            throw New-Object System.ArgumentException -ArgumentList "Cannot specify Offset without Limit"
        }

        if ( $PSBoundParameters.ContainsKey("Limit") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ limit = $Limit }

            if ( $PSBoundParameters.ContainsKey("Offset") )
            {
                Add-UriParameters -Parameters $Parameters -Hash @{ offset = $Offset }
            }
        }

        if ( $PSBoundParameters.ContainsKey("StatusId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ status_id = [String]::Join(",", $StatusId ) }
        }

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailResultsForRun
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$false)]
        [DateTime]
        $CreatedBefore,

        [Parameter(Mandatory=$false)]
        [DateTime]
        $CreatedAfter,

        [Parameter(Mandatory=$false)]
        [int]
        $CreatedBy,

        [Parameter(Mandatory=$false)]
        [int]
        $Limit,

        [Parameter(Mandatory=$false)]
        [int]
        $Offset,

        [Parameter(Mandatory=$false)]
        [int[]]
        $StatusId
    )

    PROCESS
    {
        $Uri = "get_results_for_run/$RunId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("Offset") -and (-not $PSBoundParameters.ContainsKey("Limit") ) )
        {
            throw New-Object System.ArgumentException -ArgumentList "Cannot specify Offset without Limit"
        }

        if ( $PSBoundParameters.ContainsKey("CreatedAfter") )
        {
            $CreatedAfterTS = ConvertTo-UnixTimestamp -DateTime $CreatedAfter
            Add-UriParameters -Parameters $Parameters -Hash @{ created_after = $CreatedAfterTS }
        }

        if ( $PSBoundParameters.ContainsKey("CreatedBefore") )
        {
            $CreatedBeforeTS = ConvertTo-UnixTimestamp -DateTime $CreatedBefore
            Add-UriParameters -Parameters $Parameters -Hash @{ created_before = $CreatedBeforeTS }
        }

        if ( $PSBoundParameters.ContainsKey("CreatedBy") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ created_by = $CreatedBy }
        }

        if ( $PSBoundParameters.ContainsKey("Limit") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ limit = $Limit }

            if ( $PSBoundParameters.ContainsKey("Offset") )
            {
                Add-UriParameters -Parameters $Parameters -Hash @{ offset = $Offset }
            }
        }

        if ( $PSBoundParameters.ContainsKey("StatusId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ status_id = [String]::Join(",", $StatusId ) }
        }

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Add-TestRailResult
{
    param
    (
        [Parameter(Mandatory=$true)]
        [Alias('id')]
        [int]
        $TestId,

        [Parameter(Mandatory=$true)]
        [int]
        $StatusId,

        [Parameter(Mandatory=$false)]
        [string]
        $Comment,

        [Parameter(Mandatory=$false)]
        [string]
        $Version,

        [Parameter(Mandatory=$false)]
        [string]
        $Elapsed,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Defects,

        [Parameter(Mandatory=$false)]
        [int]
        $AssignedToId,

        [Parameter(Mandatory=$false)]
        [HashTable]
        $CustomFields = @{}
    )

    PROCESS
    {
        $Uri = "add_result/$RunId"
        $Parameters = @{}

        $Parameters.Add("status_id", $StatusId)

        if ( $PSBoundParameters.ContainsKey("Comment") )
        {
            $Parameters.Add("comment", $Comment)
        }

        if ( $PSBoundParameters.ContainsKey("Version") )
        {
            $Parameters.Add("version", $Version)
        }

        if ( $PSBoundParameters.ContainsKey("Elapsed") )
        {
            $Parameters.Add("elapsed", $Elapsed)
        }

        if ( $PSBoundParameters.ContainsKey("Defects") )
        {
            $Parameters.Add("defects", ([String]::Join(",", $Defects)))
        }

        if ( $PSBoundParameters.ContainsKey("AssignedToId") )
        {
            $Parameters.Add("assignedto_id", $AssignedToId)
        }

        $CustomFields.Keys |% {
            $Key = $_
            if ( $Key -notmatch "^custom_" )
            {
                $Key = "custom_" + $Key
            }

            $Parameters.Add($Key, $CustomFields[$_])
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Add-TestRailResultForCase
{
    param
    (
        [Parameter(Mandatory=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$true)]
        [int]
        $CaseId,

        [Parameter(Mandatory=$true)]
        [int]
        $StatusId,

        [Parameter(Mandatory=$false)]
        [string]
        $Comment,

        [Parameter(Mandatory=$false)]
        [string]
        $Version,

        [Parameter(Mandatory=$false)]
        [string]
        $Elapsed,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Defects,

        [Parameter(Mandatory=$false)]
        [int]
        $AssignedToId,

        [Parameter(Mandatory=$false)]
        [HashTable]
        $CustomFields = @{}
    )

    PROCESS
    {
        $Uri = "add_result_for_case/$RunId/$CaseId"
        $Parameters = @{}

        $Parameters.Add("status_id", $StatusId)

        if ( $PSBoundParameters.ContainsKey("Comment") )
        {
            $Parameters.Add("comment", $Comment)
        }

        if ( $PSBoundParameters.ContainsKey("Version") )
        {
            $Parameters.Add("version", $Version)
        }

        if ( $PSBoundParameters.ContainsKey("Elapsed") )
        {
            $Parameters.Add("elapsed", $Elapsed)
        }

        if ( $PSBoundParameters.ContainsKey("Defects") )
        {
            $Parameters.Add("defects", ([String]::Join(",", $Defects)))
        }

        if ( $PSBoundParameters.ContainsKey("AssignedToId") )
        {
            $Parameters.Add("assignedto_id", $AssignedToId)
        }

        $CustomFields.Keys |% {
            $Key = $_
            if ( $Key -notmatch "^custom_" )
            {
                $Key = "custom_" + $Key
            }

            $Parameters.Add($Key, $CustomFields[$_])
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function New-TestRailResult
{
    param
    (
        [Parameter(Mandatory=$true, ParameterSetName="ResultForTest")]
        [int]
        $TestId,

        [Parameter(Mandatory=$true, ParameterSetName="ResultForCase")]
        [int]
        $CaseId,

        [Parameter(Mandatory=$true)]
        [int]
        $StatusId,

        [Parameter(Mandatory=$false)]
        [string]
        $Comment,

        [Parameter(Mandatory=$false)]
        [string]
        $Version,

        [Parameter(Mandatory=$false)]
        [string]
        $Elapsed,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Defects,

        [Parameter(Mandatory=$false)]
        [int]
        $AssignedToId,

        [Parameter(Mandatory=$false)]
        [HashTable]
        $CustomFields = @{}
    )

    PROCESS
    {
        $Parameters = @{}

        switch ($PSCmdlet.ParameterSetName)
        {
            "ResultForTest" { $Parameters.Add("test_id", $TestId) }
            "ResultForCase" { $Parameters.Add("case_id", $CaseId) }
        }

        $Parameters.Add("status_id", $StatusId)

        if ( $PSBoundParameters.ContainsKey("Comment") )
        {
            $Parameters.Add("comment", $Comment)
        }

        if ( $PSBoundParameters.ContainsKey("Version") )
        {
            $Parameters.Add("version", $Version)
        }

        if ( $PSBoundParameters.ContainsKey("Elapsed") )
        {
            $Parameters.Add("elapsed", $Elapsed)
        }

        if ( $PSBoundParameters.ContainsKey("Defects") )
        {
            $Parameters.Add("defects", ([String]::Join(",", $Defects)))
        }

        if ( $PSBoundParameters.ContainsKey("AssignedToId") )
        {
            $Parameters.Add("assignedto_id", $AssignedToId)
        }

        $CustomFields.Keys |% {
            $Key = $_
            if ( $Key -notmatch "^custom_" )
            {
                $Key = "custom_" + $Key
            }

            $Parameters.Add($Key, $CustomFields[$_])
        }

        $Parameters
    }
}

function Add-TestRailResultsForCases
{
    param
    (
        [Parameter(Mandatory=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$true)]
        [HashTable[]]
        $Results
    )

    PROCESS
    {
        $Uri = "add_results_for_cases/$RunId"

        $NotCaseResults =  ($Results | Where-Object case_id -Eq $null).Length -ne 0
        if ( $NotCaseResults )
        {
            throw (New-Object ArgumentException -ArgumentList "Results must contain a 'case_id' property. Did you use New-TestRailResult -CaseId <x> ?")
        }

        $Parameters = @{}

        if ( $Results -is [Array] )
        {
            $Parameters = @{ results = $Results }
        }
        else
        {
            $Parameters = @{ results = @( $Results ) }
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Add-TestRailResults
{
    param
    (
        [Parameter(Mandatory=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$true)]
        [HashTable[]]
        $Results
    )

    PROCESS
    {
        $Uri = "add_results/$RunId"

        $NotTestResults =  ($Results | Where-Object test_id -Eq $null).Length -ne 0
        if ( $NotTestResults )
        {
            throw (New-Object ArgumentException -ArgumentList "Results must contain a 'test_id' property. Did you use New-TestRailResult -TestId <x> ?")
        }

        $Parameters = @{}

        if ( $Results -is [Array] )
        {
            $Parameters = @{ results = $Results }
        }
        else
        {
            $Parameters = @{ results = @( $Results ) }
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Start-TestRailRun
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('project_id','id')]
        [int]
        $ProjectId,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Alias('suite_id')]
        [int]
        $SuiteId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        [Parameter(Mandatory=$false)]
        [int]
        $MilestoneId,

        [Parameter(Mandatory=$true)]
        [int]
        $AssignedToId,

        [Parameter(Mandatory=$false)]
        [bool]
        $IncludeAll = $true,

        [Parameter(Mandatory=$false)]
        [int[]]
        $CaseId
    )

    PROCESS
    {
        $Uri = "add_run/$ProjectId"

        $Parameters = @{
            milestone_id = $MilestoneId
            suite_id = $SuiteId
            name = $Name
            description = $Description
            assignedto_id = $AssignedToId
            include_all = $IncludeAll
        }
        if ( $PSBoundParameters.ContainsKey("CaseId") )
        {
            $Parameters.case_ids = $CaseId
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Set-TestRailRun
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $RunId,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        [Parameter(Mandatory=$false)]
        [int]
        $MilestoneId,

        [Parameter(Mandatory=$false)]
        [bool]
        $IncludeAll,

        [Parameter(Mandatory=$false)]
        [int[]]
        $CaseId
    )

    PROCESS
    {
        $Uri = "update_run/$RunId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("MilestoneId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ milestone_id = $MilestoneId }
        }
        if ( $PSBoundParameters.ContainsKey("Name") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ name = $Name }
        }
        if ( $PSBoundParameters.ContainsKey("Description") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ description = $Description }
        }
        if ( $PSBoundParameters.ContainsKey("IncludeAll") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ include_all = $IncludeAll }
        }
        if ( $PSBoundParameters.ContainsKey("CaseId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ case_ids = [String]::Join(",", $CaseId) }
        }

        if ( $Parameters.Count -ne 0 )
        {
            Request-TestRailUri -Uri $Uri -Parameters $Parameters
        }
        else
        {
            Get-TestRailRun -RunId $RunId
        }
    }
}

function Stop-TestRailRun
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $RunId
    )

    PROCESS
    {
        $Uri = "close_run/$RunId"
        Submit-TestRailUri -Uri $Uri
    }
}

function ConvertTo-UnixTimestamp
{
    param
    (
        [Parameter(Mandatory=$true)]
        [DateTime]
        $DateTime,

        [Parameter(Mandatory=$false)]
        [switch]
        $UTC
    )

    $Kind = [DateTimeKind]::Local

    if ( $UTC.IsPresent )
    {
        $Kind = [DateTimeKind]::Utc
    }

    [int](( $DateTime - (New-Object DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, $Kind) ).TotalSeconds)
}

function ConvertFrom-UnixTimestamp
{
    param
    (
        [Parameter(Mandatory=$true, ParameterSetName="Timestamp")]
        [int]
        $Timestamp,

        [Parameter(Mandatory=$true, ParameterSetName="TimestampMS")]
        [long]
        $TimestampMS,

        [Parameter(Mandatory=$false)]
        [switch]
        $UTC
    )

    $Kind = [DateTimeKind]::Local

    if ( $UTC.IsPresent )
    {
        $Kind = [DateTimeKind]::Utc
    }

    switch ( $PSCmdlet.ParameterSetName )
    {
        "Timestamp" {
            (New-Object DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, $Kind).AddSeconds($Timestamp)
        }

        "TimestampMS" {
            (New-Object DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, $Kind).AddMilliseconds($TimestampMS)
        }
    }
}

function Set-TestRailDebug
{
    param
    (
        [Parameter(Mandatory=$true)]
        [bool]
        $Enabled
    )

    $Script:Debug = $Enabled
}

function Get-TestRailDebug
{
    $Script:Debug
}

function Request-TestRailUri
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Uri,

        [Parameter(Mandatory=$false)]
        [System.Collections.Specialized.NameValueCollection]
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    )

    if ( $Script:ApiClient -eq $null )
    {
        throw New-Object Exception -ArgumentList "You must call Initialize-TestRailSession first"
    }

    $RealUri = $Uri
    if ( -not [String]::IsNullOrEmpty($Parameters.ToString()) )
    {
        $RealUri += [String]::Format("&{0}", $Parameters.ToString())
    }

    if ( $Script:Debug -eq $true )
    {
        Write-Warning ([String]::Format("Uri: [{0}]", $RealUri))
    }

    $Result = $Script:ApiClient.SendGet($RealUri)

    New-ObjectHash -Object $Result
}

function Submit-TestRailUri
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Uri,

        [Parameter(Mandatory=$false)]
        [HashTable]
        $Parameters = @{}
    )

    if ( $Script:ApiClient -eq $null )
    {
        throw New-Object Exception -ArgumentList "You must call Initialize-TestRailSession first"
    }

    $Result = $Script:ApiClient.SendPost($Uri, $Parameters)

    New-ObjectHash -Object $Result
}

function Add-UriParameters
{
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Specialized.NameValueCollection]
        $Parameters,
        
        [Parameter(Mandatory=$true)]
        [HashTable]
        $Hash
    )

    if ( $Parameters -eq $null )
    {
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    }

    $Hash.Keys |% {
        $Key = $_;

        if ( $Hash.$_ -is [Array] )
            { $Key = $_; $Hash.$Key |% { $Parameters.Add( $Key, $_ ) } }
        else
            { $Parameters.Add( $Key, $Hash.$Key ) }
    }
}

function Get-TestRailApiClient
{
    $Script:ApiClient
}

function New-ObjectHash
{
    param
    (
        [Parameter(Mandatory=$true)]
        [object]
        $Object
    )

    if ( $Object -is [Newtonsoft.Json.Linq.JArray] )
    {
        $Object |% { New-ObjectHash -Object $_ }
    }
    elseif ( $Object -is [Newtonsoft.Json.Linq.JObject] )
    {
        $Hash = New-Object PSObject
        $Object.Properties() |% { Add-Member -InputObject $Hash -MemberType NoteProperty -Name $_.Name -Value $_.Value.ToString() -PassThru:$false }
        $Hash
    }
    else
    {
        throw New-Object ArgumentException -ArgumentList ("Object must be a JObject or JArray but it is a " + $Object.GetType().Name)
    }
}

<#
Export-ModuleMember -Function @(
    'Add-TestRailResult',
    'Close-TestRailRun',
    'Get-TestRailDebug',
    'Get-TestRailProject',
    'Get-TestRailProjects',
    'Get-TestRailResults',
    'Get-TestRailResultsForCase',
    'Get-TestRailResultsForRun',
    'Get-TestRailRun',
    'Get-TestRailRuns',
    'Get-TestRailSections',
    'Get-TestRailSuite',
    'Get-TestRailSuites',
    'Get-TestRailTests',
    'Initialize-TestRailSession',
    'New-TestRailRun',
    'Request-TestRailUri',
    'Set-TestRailDebug',
    'Set-TestRailRun',
    'Submit-TestRailUri'
)
#>