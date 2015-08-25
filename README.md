## Getting Started

First, import the module:

    PS> Import-Module .\PSTestRail

Use the `Initialize-TestRailSession` to initialise the module with your TestRail API credentials (you must have API access enabled). There are two equivalent parameter sets for the `Initialize-TestRailSession`

    PS> Initialize-TestRailSession [-Uri] <uri> [-User] <string> [-Password] <string>

and

    PS> Initialize-TestRailSession [-Uri] <uri> [-User] <string> [-ApiKey] <string>

Since the TestRail API doesn't distinguish between your normal login password and a configured API Key, `-ApiKey` is just an alias for `-Password`, but helps to make your intentions clear when scripting.

There's no return value here - it just sets up an internal instance of the .Net TestRail API Client. This means you won't get an error if you pass bogus information until the first time you try an API operation.

If you have a hosted TestRail subscription, your Uri will be `https://<tenantname>.testrail.net/`. The API suffix is added by the client.

## Commandlet Naming

This module tries to use Powershell Verbs properly. If the TestRail API method conflicts with the Powershell meaning of the Verb then I've used the Powershell convention. This hopefully makes it less confusing to people already familiar with Powershell.

For example: The TestRail API has `update_run` for changing the properties of an existing Test Run definition, but the Powershell `Set` verb is more appropriate than the `Update` verb in my opinion; hence `Set-TestRailRun`.

Likewise, the API operation `add_run` creates a new Test Run, but `New-TestRailRun` is more appropriate.

Generally:

* `Add-` to create a new instance of a thing, e.g. `Add-TestRailResult`, `Add-TestRailResultsForCases`
* `Close-` to end or conclude an open session (e.g. Test Run), e.g. `Close-TestRailRun`
* `Get-` to retrieve a resource, e.g. `Get-TestRailProjects`, `Get-TestRailTests`
* `New-` create a new instance of a resource, e.g. `New-TestRailResult`
* `Set-` change the data associated with an existing resource, e.g. `Set-TestRailRun`

## Return Values

The native .Net API methods return `Newtonsoft.Linq.Json.JObjects` (or a `JArray` of `JObjects`). This module converts `JObjects` to `Hashtable`s, and `Hashtable[]` for `JArray`.

## Simple Usage

Initialise the TestRail session

    PS> Initialize-TestRailSession -Uri https://tenant.testrail.net/ -User someuser -ApiKey myapikey

Enumerate completed projects (`-IsCompleted` defaults to `$false`)

    PS> Get-TestRailProjects -IsCompleted $true

Enumerate Test Suites associated with a project

    PS> Get-TestRailSuites -ProjectId 76

 or even

    PS> Get-TestRailProject -ProjectId 76 | Get-TestRailSuites

or perhaps

    PS> Get-TestRailProjects | Where name -eq "My Project" | Get-TestRailSuites

### Conduct a new Test Run

    PS> $project = Get-TestRailProjects | Where name -eq "My Project"
    PS> $suite = Get-TestRailSuites -ProjectId $project.id | Where name -eq "Test Suite"
    PS> $run = New-TestRailRun -ProjectId $project.id -SuiteId $suite.id -Name "My Test Run" -Description "A test run where I test things" -CaseId 17,36,142,86
    # Do some tests
    PS> $results = @()
    PS> $results += New-TestRailResult -CaseId 17 -StatusId 1 -Comment "Everything was fine" -Elapsed "3m" -CustomFields @{ "custom_colour" = "Blue" }
    PS> $results += New-TestRailResult -CaseId 36 -StatusId 2 -Comment "Something useful about the test case" -CustomFields @{ "detail" = "The custom_ prefix will be added automatically"; colour = "Yellow" }
    PS> Add-TestRailResultsForCases -RunId $run.id -Results $results
    PS> Close-TestRailRun -RunId $run.id