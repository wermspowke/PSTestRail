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