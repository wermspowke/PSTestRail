function Get-TestRailSection
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]
        $SectionId
    )

    PROCESS
    {
        $Uri = "get_section/$SectionId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailSections
{
    [CmdletBinding()]
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

function Add-TestRailSection
{
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,
        
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('project_id')]
        [int]
        $ProjectId,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Alias('suite_id')]
        [int]
        $SuiteId,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        [Parameter(Mandatory=$false)]
        [int]
        $ParentId
    )

    PROCESS
    {
        $Uri = "add_section/$ProjectId"
        $Parameters = @{}

        $Parameters.name = $Name

        if ( $PSBoundParameters.ContainsKey("SuiteId") )
        {
            $Parameters.suite_id = $SuiteId
        }

        if ( $PSBoundParameters.ContainsKey("Description") )
        {
            $Parameters.description = $Description
        }

        if ( $PSBoundParameters.ContainsKey("ParentId") )
        {
            $Parameters.parent_id = $ParentId
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Set-TestRailSection
{
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $SectionId,
        
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description
    )

    PROCESS
    {
        $Uri = "update_section/$SectionId"
        $Parameters = @{}

        if ( $PSBoundParameters.ContainsKey("Name") )
        {
            $Parameters.name = $Name
        }

        if ( $PSBoundParameters.ContainsKey("Description") )
        {
            $Parameters.description = $Description
        }

        Submit-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Remove-TestRailSection
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]
        $SectionId
    )

    PROCESS
    {
        $Uri = "delete_section/$SectionId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}