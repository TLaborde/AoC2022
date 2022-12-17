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

function Find-Result ($sample) {
    $graph = Parse-Input $sample
    Find-BestPath $graph
}

function Find-Result2 ($sample) {
    $graph = Parse-Input $sample
    $directPaths = Get-DirectPath $graph
    Find-BestWithHelp $graph $directPaths

}

function Get-HashCode ($array) {
    $code = "".GetHashCode()
    foreach ($item in $array) {
        $code = $code -bxor $item.GetHashCode()
    }
    $code
}


function Find-BestWithHelp ($graph, $directPaths) {
    $endpoints = @{}
    $keys = $graph.GetEnumerator().Where({ $_.Value.rate -gt 0 }).Name + "AA"
    function Find-AllBestPath($current = "AA", $flow = 0, $timeLeft = 26, $seen = (new-hashset)) {
        $null = $seen.Add($current)
        $targets = $keys.where({ !$seen.Contains($_) })
        $torecord = $seen.where({ $_ -ne "AA" })
        $key = Get-HashCode $torecord
        if (!$endpoints.ContainsKey($key) -or $endpoints[$key].flow -lt $flow ) {
            $endpoints[$key] = @{flow = $flow ; set = $torecord }
        }
        $bestFlow = 0
        foreach ($target in $targets) {
            $time = $timeLeft - $directPaths[$current][$target] - 1
            if ($time -gt 0) {
                $newFlow = $graph[$target].rate * $time
                $newflow += Find-AllBestPath $target ($flow + $newFlow) $time ((new-hashset -Content $seen))
                if ($newFlow -gt $bestFlow) {
                    $bestFlow = $newFlow
                }
            }
        }
        return $bestFlow
    }
    function Find-OtherPaths($collection = ($keys.where({ $_ -ne "AA" }))) {
        $key = Get-HashCode $collection
        if (!$endpoints.ContainsKey($key)) {
            $bestFlow = 0
            foreach ($item in $collection) {
                $subCollection = [array]$collection.where({ $_ -ne $item })
                $newFlow = Find-OtherPaths $subCollection
                if ($newFlow.flow -gt $bestFlow) {
                    $bestFlow = $newFlow.flow
                }
    
            }
            $endpoints[$key] = @{flow = $bestFlow ; set = $collection }
        }
        return $endpoints[$key]
    }
    $null = Find-AllBestPath
    $null = Find-OtherPaths
    $bestFlow = 0
    foreach ($endpoint in $endpoints.GetEnumerator()) {
        # find the complement set
        $alternateSet = [array]$keys.Where({ $_ -notin $endpoint.Value.set -and $_ -ne "AA" })
        $key = Get-HashCode $alternateSet
        $sumFlow = $endpoint.Value.flow + $endpoints[$key].flow
        if ($sumFlow -gt $bestFlow) {
            $bestFlow = $sumFlow
        }
    }
    $bestFlow
}

function Get-DirectPath ($graph) {
    $directPaths = @{}
    $keys = $graph.GetEnumerator().Where({ $_.Value.rate -gt 0 }).Name + "AA"
    foreach ($k1 in $keys) {
        $directPaths[$k1] = @{}
        foreach ($k2 in $keys) {
            if ($k1 -ne $k2) {
                $directPaths[$k1][$k2] = Get-ShortestPath $graph $k1 $k2
            }
        }
    }
    $directPaths
}
# We more or less do DFS
Function Find-BestPath ($graph, $step = "AA", $timeLeft = 30 - 1, $state = @{}, $seen = @{}) {

    $current = 0
    foreach ($item in $state.GetEnumerator().where({ $_.value })) {
        $current += $item.Value * $graph[$item.name].rate
    }
    if ($timeleft -eq 0) {
        return $current
    } 
    $key = [string]$timeLeft + $step
    # if we did that before and better, stop early
    if ($seen.ContainsKey($key) -and $seen[$key] -ge $current) {
        return 0
    }
    $seen[$key] = $current

    $max = 0
    foreach ($s in ($graph[$step].neighboors + $step)) {
        if ($s -eq $step) {
            if (!$state[$s] -and $graph[$s].rate -gt 0) {
                $state[$s] = $timeleft
            }
            else {
                continue
            }
        }
        $max = [math]::Max($max, (Find-BestPath $graph $s ($timeleft - 1) $state $seen))

        if ($s -eq $step) {
            $state[$step] = $null
        }
    }
    return $max
}

# normal DFS to find distance between important points
Function Get-ShortestPath ($graph, $start, $end) {
    if ($start -isnot [array]) {
        $start = , $start
    }
    $depth = 0
    while ($true) {
        $nextSteps = New-HashSet
        foreach ($step in $start) {
            if ($step -eq $end) {
                return $depth
            }
            foreach ($s in $graph[$step].neighboors) {
                $null = $nextSteps.Add($s)
            }
        }
        $start = $nextSteps
        $depth++
    }
    $depth = 1
}

function Parse-Input ($sample) {
    $graph = @{}
    foreach ($line in $sample) {
        if ($line -match 'Valve ([A-Z]+) has flow rate=([0-9]+); tunnel[s]* lead[s]* to valve[s]* (.*)') {
            $graph[$Matches[1]] = @{
                rate       = [int]$Matches[2]
                neighboors = @( $Matches[3] -replace "`r|`n" -split ', ' | Where-Object { $_ })
            }
        }
    }
    $graph
}



'Sample result should be: 1649 '
#Find-Result $sample

#Find-Result $data

'Second part, sample result should be: 1707'
Find-Result2 $sample

Find-Result2 $data
