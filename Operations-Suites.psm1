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
