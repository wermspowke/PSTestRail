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

function Add-Project
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Announcement,

        [Parameter(Mandatory=$false)]
        [switch]
        $ShowAnnouncement,

        [Parameter(Mandatory=$false)]
        [ValidateRange(1,2)]
        [int]
        $SuiteMode
    )

    $Uri = "add_project"
    $Parameters = @{}

    $Parameters.name = $Name
    if ( $PSBoundParameters.ContainsKey("Announcement") )
    {
        $Parameters.announcement = $Announcement
    }

    # Defaults to false is ommitted
    if ( $ShowAnnouncement.IsPresent )
    {
        $Parameters.show_announcement = $true
    }

    if ( $PSBoundParameters.ContainsKey("SuiteMode") )
    {
        $Parameters.suite_mode = $SuiteMode
    }

    Submit-TestRailUri -Uri $Uri -Parameters $Parameters
}

function Set-Project
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $ProjectId,

        [Parameter(Mandatory=$false)]
        [string]
        $Name,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Announcement,

        [Parameter(Mandatory=$false)]
        [bool]
        $ShowAnnouncement,

        [Parameter(Mandatory=$false)]
        [ValidateRange(1,2)]
        [int]
        $SuiteMode,

        [Parameter(Mandatory=$false)]
        [bool]
        $IsCompleted
    )

    $Uri = "update_project/$ProjectId"
    $Parameters = @{}
    
    if ( $PSBoundParameters.ContainsKey("Name") )
    {
        $Parameters.name = $Name
    }

    if ( $PSBoundParameters.ContainsKey("Announcement") )
    {
        $Parameters.announcement = $Announcement
    }

    if ( $PSBoundParameters.ContainsKey("ShowAnnouncement") )
    {
        $Parameters.show_announcement = $ShowAnnouncement
    }

    if ( $PSBoundParameters.ContainsKey("SuiteMode") )
    {
        $Parameters.suite_mode = $SuiteMode
    }

    if ( $PSBoundParameters.ContainsKey("IsCompleted") )
    {
        $Parameters.is_completed = $IsCompleted
    }

    Submit-TestRailUri -Uri $Uri -Parameters $Parameters
}

function Remove-Project
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $ProjectId
    )

    $Uri = "delete_project/$ProjectId"
    $Parameters = @{}

    Submit-TestRailUri -Uri $Uri -Parameters $Parameters
}