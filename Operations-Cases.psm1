function Get-TestRailCase
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [int]
        $CaseId
    )

    PROCESS
    {
        $Uri = "get_case/$CaseId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Get-TestRailCases
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('project_id')]
        [int]
        $ProjectId,

        [Parameter(Mandatory=$false)]
        [int]
        $SuiteId,

        [Parameter(Mandatory=$false)]
        [int]
        $SectionId,

        [Parameter(Mandatory=$false)]
        [DateTime]
        $CreatedBefore,

        [Parameter(Mandatory=$false)]
        [DateTime]
        $CreatedAfter,

        [Parameter(Mandatory=$false)]
        [int[]]
        $CreatedBy,
        
        [Parameter(Mandatory=$false)]
        [int]
        $MilestoneId,
        
        [Parameter(Mandatory=$false)]
        [int[]]
        $PriorityId,
        
        [Parameter(Mandatory=$false)]
        [int[]]
        $TypeId,

        [Parameter(Mandatory=$false)]
        [DateTime]
        $UpdatedBefore,

        [Parameter(Mandatory=$false)]
        [DateTime]
        $UpdatedAfter,
        
        [Parameter(Mandatory=$false)]
        [int[]]
        $UpdatedBy
    )

    PROCESS
    {
        $Uri = "get_cases/$ProjectId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("SuiteId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "suite_id" = $SuiteId }
        }

        if ( $PSBoundParameters.ContainsKey("SectionId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "section_id" = $SectionId }
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
            Add-UriParameters -Parameters $Parameters -Hash @{ created_by = [string]::Join(",", $CreatedBy) }
        }

        if ( $PSBoundParameters.ContainsKey("MilestoneId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "milestone_id" = $MilestoneId }
        }

        if ( $PSBoundParameters.ContainsKey("PriorityId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "priority_id" = [string]::Join(",", $PriorityId) }
        }

        if ( $PSBoundParameters.ContainsKey("TypeId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "type_id" = [string]::Join(",", $TypeId) }
        }

        if ( $PSBoundParameters.ContainsKey("UpdatedAfter") )
        {
            $UpdatedAfterTS = ConvertTo-UnixTimestamp -DateTime $UpdatedAfter
            Add-UriParameters -Parameters $Parameters -Hash @{ "updated_after" = $UpdatedAfterTS }
        }

        if ( $PSBoundParameters.ContainsKey("UpdatedBefore") )
        {
            $UpdatedBeforeTS = ConvertTo-UnixTimestamp -DateTime $UpdatedBefore
            Add-UriParameters -Parameters $Parameters -Hash @{ "updated_before" = $UpdatedBeforeTS }
        }

        if ( $PSBoundParameters.ContainsKey("UpdatedBy") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "updated_by" = [string]::Join(",", $UpdatedBy) }
        }

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Add-TestRailCase
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]
        $SectionId,

        [Parameter(Mandatory=$true)]
        [string]
        $Title,
        
        [Parameter(Mandatory=$false)]
        [int]
        $TypeId,
        
        [Parameter(Mandatory=$false)]
        [int]
        $PriorityId,

        [Parameter(Mandatory=$false)]
        [string]
        $Estimate,
        
        [Parameter(Mandatory=$false)]
        [int]
        $MilestoneId,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Refs,

        [Parameter(Mandatory=$false)]
        [HashTable]
        $CustomFields = @{}
    )

    PROCESS
    {
        $Uri = "add_case/$SectionId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Add-UriParameters -Parameters $Parameters -Hash @{ "title" = $Title }

        
        if ( $PSBoundParameters.ContainsKey("TypeId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "type_id" = $TypeId }
        }
        
        if ( $PSBoundParameters.ContainsKey("PriorityId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "priority_id" = $PriorityId }
        }
        
        if ( $PSBoundParameters.ContainsKey("Estimate") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "estimate" = $Estimate }
        }

        if ( $PSBoundParameters.ContainsKey("MilestoneId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "milestone_id" = $MilestoneId }
        }

        if ( $PSBoundParameters.ContainsKey("MilestoneId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "milestone_id" = $MilestoneId }
        }
        
        if ( $PSBoundParameters.ContainsKey("Refs") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ refs = [String]::Join(",", $Refs ) }
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

function Set-TestRailCase
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [int]
        $CaseId,

        [Parameter(Mandatory=$false)]
        [string]
        $Title,
        
        [Parameter(Mandatory=$false)]
        [int]
        $TypeId,
        
        [Parameter(Mandatory=$false)]
        [int]
        $PriorityId,

        [Parameter(Mandatory=$false)]
        [string]
        $Estimate,
        
        [Parameter(Mandatory=$false)]
        [int]
        $MilestoneId,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Refs,

        [Parameter(Mandatory=$false)]
        [HashTable]
        $CustomFields = @{}
    )

    PROCESS
    {
        $Uri = "update_case/$CaseId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ( $PSBoundParameters.ContainsKey("Title") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "title" = $Title }
        }

        if ( $PSBoundParameters.ContainsKey("TypeId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "type_id" = $TypeId }
        }
        
        if ( $PSBoundParameters.ContainsKey("PriorityId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "priority_id" = $PriorityId }
        }
        
        if ( $PSBoundParameters.ContainsKey("Estimate") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "estimate" = $Estimate }
        }

        if ( $PSBoundParameters.ContainsKey("MilestoneId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "milestone_id" = $MilestoneId }
        }

        if ( $PSBoundParameters.ContainsKey("MilestoneId") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ "milestone_id" = $MilestoneId }
        }
        
        if ( $PSBoundParameters.ContainsKey("Refs") )
        {
            Add-UriParameters -Parameters $Parameters -Hash @{ refs = [String]::Join(",", $Refs ) }
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