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