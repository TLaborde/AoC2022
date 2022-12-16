. ./common.ps1
$data = Get-Content .\16.input.txt

$sample = @'
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
'@ -split "`n"

function Find-Result ($sample)
{
    $graph = Parse-Input $sample
    Find-BestNextStep $graph -Start 'AA'
}

function Find-Result2 ($sample)
{

}

function New-Path ($steps , $pressure = 0, $valves = @())
{
    @{
        steps    = $steps
        pressure = $pressure
        valves   = $valves
    }
}
function Find-BestNextStep ($graph, $start, $timeLeft = 30)
{
    $nextPaths = $graph[$start].neighboors | ForEach-Object {
        New-Path -steps $_
    }
    do
    {
        $timeleft--
        $write-host $timeleft
        $newPaths = @()
        foreach ($path in $nextPaths)
        {
            $step = $path.steps
            if ($step -notin $path.valves -and $graph[$step].rate -gt 0)
            {
                $newPaths += New-Path -pressure ($path.pressure + ($graph[$step].rate * ($timeleft)) ) -valves ($path.valves + , $step) -steps $step
            } 
            foreach ($nextStep in $graph[$step].neighboors)
            {
                $newPaths += New-Path -pressure $path.pressure -valves $path.valves -steps $nextStep
            }

        }
        $nextPaths = $newPaths
    } while ($timeleft -gt 0)
}
function Parse-Input ($sample)
{
    $graph = @{}
    foreach ($line in $sample)
    {
        if ($line -match 'Valve ([A-Z]+) has flow rate=([0-9]+); tunnel[s]* lead[s]* to valve[s]* (.*)')
        {
            $graph[$Matches[1]] = @{
                rate       = [int]$Matches[2]
                neighboors = $Matches[3] -replace "`r|`n" -split ', ' | Where-Object { $_ }
            }
        }
    }
    $graph
}



'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
