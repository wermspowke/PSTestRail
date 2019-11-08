function Get-TestRailReports
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
        $Uri = "get_reports/$ProjectId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}

function Start-TestRailReport
{
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('report_id')]
        [int]
        $ReportId
    )

    PROCESS
    {
        $Uri = "run_report/$ReportId"
        $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        Request-TestRailUri -Uri $Uri -Parameters $Parameters
    }
}