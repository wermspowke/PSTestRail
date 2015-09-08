## Getting Started

First, import the module:

    PS> Import-Module .\PSTestRail

Use the `Initialize-TestRailSession` to initialise the module with your TestRail API credentials (you must have API access enabled). There are two equivalent parameter sets for the `Initialize-TestRailSession`

    PS> Initialize-TestRailSession [-Uri] <uri> [-User] <string> [-Password] <string>

and

    PS> Initialize-TestRailSession [-Uri] <uri> [-User] <string> [-ApiKey] <string>

Since the TestRail API doesn't distinguish between your normal login password and a configured API Key, `-ApiKey` is just an alias for `-Password`, but helps to make your intentions clear when scripting.

There's no return value here - it just sets up an internal instance of the .Net TestRail API Client. This means you won't get an error if you pass bogus information until the first time you try an API operation.

If you have a hosted TestRail subscription, your Uri will be `https://<tenantname>.testrail.net/`. The API endpoint suffix is added by the client.

## Cmdlet Naming

This module tries to use Powershell Verbs properly. If the TestRail API method conflicts with the Powershell meaning of the Verb then I've used the Powershell convention. This hopefully makes it less confusing to people already familiar with Powershell.

For example: The TestRail API has `update_run` for changing the properties of an existing Test Run definition, but the Powershell `Set` verb is more appropriate than the `Update` verb in my opinion; hence `Set-TestRailRun`.

Likewise, the API operation `add_run` creates a new Test Run, but `New-TestRailRun` is more appropriate.

Generally:

* `Add-` to create a new instance or instances of a thing in TestRail, e.g. `Add-TestRailResult`, `Add-TestRailResultsForCases`
* `Start/Stop-` to start/begin or conclude/end a session (e.g. Test Run), e.g. `Start-TestRailRun`, `Stop-TestRailRun`
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
    PS> $run = Start-TestRailRun -ProjectId $project.id -SuiteId $suite.id -Name "My Test Run" -AssignedTo 1 -Description "A test run where I test things" -CaseId 17,36,142,86
    # Do some tests
    PS> $results = @()
    PS> $results += New-TestRailResult -CaseId 17 -StatusId 1 -Comment "Everything was fine" -Elapsed "3m" -CustomFields @{ "custom_colour" = "Blue" }
    PS> $results += New-TestRailResult -CaseId 36 -StatusId 2 -Comment "Something useful about the test case" -CustomFields @{ "detail" = "The custom_ prefix will be added automatically"; colour = "Yellow" }
    PS> Add-TestRailResultsForCases -RunId $run.id -Results $results
    PS> Stop-TestRailRun -RunId $run.id

## Troubleshooting

This is still a work in progress, so there are going to be bugs. To help with bug reports please use the module like this and include the information in your issue report:

    PS> Import-Module .\PSTestRail
    PS> Set-TestRailDebug -Enabled:$true
    PS> $DebugPreference = "Continue"
    # Now use as normal

To disable debugging simply set debug mode to disabled:

    PS> Set-TestRailDebug -Enabled:$false

though thanks to the `$DebugPreference` setting you might continue to see debug information from other cmdlets outside of the `PSTestRail` module. The *normal* state of `$DebugPreference` is `SilentlyContinue` so set it back to that to completely unwind changes made above.

    PS> $DebugPreference = "SilentlyContinue"

While debugging is enabled you will see some more verbose output including the full request URI and the raw JSON response:

    PS> Get-TestRailProjects
    DEBUG: Request-TestRailUri: Uri: get_projects
    DEBUG: Request-TestRailUri: Result: [
      {
        "id": 1,
        "name": "Test Project",
        "announcement": null,
        "show_announcement": false,
        "is_completed": false,
        "completed_on": null,
        "suite_mode": 1,
        "url": "https://tenant.testrail.net/index.php?/projects/overview/1"
      }
    ]
    DEBUG: New-ObjectHash: Object is 'Newtonsoft.Json.Linq.JArray' from 'Newtonsoft.Json, Version=7.0.0.0, Culture=neutral,
    PublicKeyToken=30ad4fe6b2a6aeed' (\path\to\pstestrail\lib\Newtonsoft.Json.dll)
    DEBUG: New-ObjectHash: Object is 'Newtonsoft.Json.Linq.JObject' from 'Newtonsoft.Json, Version=7.0.0.0, Culture=neutral,
    PublicKeyToken=30ad4fe6b2a6aeed' (\path\to\pstestrail\lib\Newtonsoft.Json.dll)

When the module converts the response into a `Hashtable` or `Hashtable[]` it reports a bit more information about what's being passed around. This was to shed light on a specific issue where some type checking seemed to give inconsistent results.

## Notes

### Start/Stop vs Open/Close

I'm in two minds with `Start-`/`Stop-TestRailRun`. There's an argument that it should be `Open-`/`Close-TestRailRun` instead, except that once you stop (or close) a Test Run in TestRail you can't re-open it to make changes. TestRail's own nomenclature talks about closing Runs down, but then it's confused because you create a new run with `add_run` and anyway I've already said I'm ignoring TestRail's verbs in favour of doing the right thing by PowerShell. `Start-` and `Stop-` are *Lifecycle* verbs so I'll stick with those semantics for now.

### Being Independant

There's an argument for going pure PowerShell and dropping the dependency on the GuRock .Net API client library. It doesn't do much beyond JSON serialization and de-serialization, and that was kind of the point with this library - to take the hassle out of building the request payloads and query strings. `Invoke-RestMethod` would be a reasonable substitute.

Even the JSON parsing could be replaced with the built-in `ConvertFrom-Json` and `ConvertTo-Json`. The `Newtonsoft.Json` library *is* the best, though. It's both better and faster than Microsoft's own JSON-parsing routines. `ConvertFrom-Json` might give me a better JSON to Hashtable (or PowerShell Object) experience than my rather naive JObject to Hashtable approach, though. And for that matter, `Invoke-RestMethod` appears to automatically de-serialize JSON response payloads.

Let's see if I can get 100% API coverage first, shall we? First make it work, then make it pretty, right?