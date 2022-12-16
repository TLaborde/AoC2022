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

function New-Path ($step , $pressure = 0, [Valve]$valves = 0)
{
    @{
        step     = $step
        pressure = $pressure
        valves   = [Valve]$valves
    }
}

function Make-Enum ($keys)
{
    $s = '[flags()] enum Valve {'
    $i = 1
    foreach ($k in $keys)
    {
        $s += "`n$k = $i"
        $i *= 2
    }
    $s += "`nALL = $($i-1)"
    $s += '}'
    $s | Invoke-Expression
}
function Find-BestNextStep ($graph, $start, $timeLeft = 30)
{
    $nextPaths = $graph[$start].neighboors | ForEach-Object {
        New-Path -step $_
    }
    Make-Enum $graph.GetEnumerator().where({ $_.Value.rate -gt 0 }).Name
    $best = @{}
    do
    {
        $timeleft--
        write-host $timeleft
        write-host $nextPaths.count
        $newPaths = @()
        foreach ($path in $nextPaths)
        {
            $step = $path.step
            $key = $step + [int]$path.valves
            if ($best.ContainsKey($key) -and $best[$key] -gt $path.pressure)
            {
                continue
            }
            if ($path.pressure -eq 0 -and $timeleft -lt 25)
            {
                continue
            }
            $best[$key] = $path.pressure

            if (!$path.valves.HasFlag([Valve]::$step) -and $graph[$step].rate -gt 0)
            {
                $newPaths += New-Path -pressure ($path.pressure + ($graph[$step].rate * ($timeleft)) ) -valves ($path.valves + [Valve]::$step) -step $step
            } 
            foreach ($nextStep in $graph[$step].neighboors)
            {
                $newPaths += New-Path -pressure $path.pressure -valves $path.valves -step $nextStep
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
