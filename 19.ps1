. ./common.ps1
$data = Get-Content .\19.input.txt

$sample = @'
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
'@ -split "`n"

function Find-Result ($sample) {
    $blueprints = Parse-Input $sample
    $total = 0
    for ($i = 0; $i -lt $blueprints.Count; $i++) {
        $bestGeode = Find-BestGeode $blueprints[$i]
        $total += ($i + 1) * $bestGeode
    }
    $total
}

function Find-Result2 ($sample) {
    $blueprints = Parse-Input $sample | select -first 3
    $total = 1
    for ($i = 0; $i -lt $blueprints.Count; $i++) {
        $bestGeode = Find-BestGeode $blueprints[$i] -maxtime 32
        $total *= $bestGeode
    }
    $total
}

function Find-BestGeode ($blueprint, $maxtime = 24) {
    $i = 0
    $triangularSum = 0..32 | % { $i + $_ ; $i = $_ + $i ; }
    $states = New-Object System.Collections.Generic.Stack[HashTable] 
    $states.Push(
        @{
            ore       = 0
            clay      = 0
            obsidian  = 0 
            geode     = 0
            oreR      = 1
            clayR     = 0
            obsidianR = 0
            geodeR    = 0
            time      = $maxtime
        }
    )
    $maxGeode = 0
    while ($states.count) {
        $state = $states.Pop()

        if ($state.time -eq 0) {
            if ($state.geode -gt $maxGeode) {
                $maxGeode = $state.geode
            }
            continue
        }
        
        # best case scenario, we can produce one new robot each time before the end, and each can produce geodes, so we
        # need to get the total of new geode created in that case, which is the triangular sum
        if (($state.time * $state.geodeR + $state.geode + $triangularSum[$state.time - 1]) -lt $maxGeode) {
            # can't catch up, skip
            continue
        }

        # next step is to wait to build something or wait
        # let's build an ore machine, if we have less than then max ore cost
        if ($state.oreR -and $state.oreR -lt $blueprint.maxOreCost) {
            $timeToWait = [math]::Ceiling([math]::Max(0, $blueprint.oreRobotOre - $state.ore) / $state.oreR) + 1
            if ($state.time - $timeToWait -ge 0) {
                $newState = $state.Clone()
                $newState.ore += $newState.oreR * $timeToWait
                $newState.clay += $newState.clayR * $timeToWait
                $newState.obsidian += $newState.obsidianR * $timeToWait
                $newState.geode += $newState.geodeR * $timeToWait
                $newState.ore -= $blueprint.oreRobotOre
                $newState.time -= $timeToWait
                $newState.oreR++
                $states.Push($newState)
            }
        }
        if ($state.oreR -and $state.clayR -lt $blueprint.obsidianRobotclay) {
            $timeToWait = [math]::Ceiling([math]::Max(0, $blueprint.clayRobotOre - $state.ore) / $state.oreR) + 1
            if ($state.time - $timeToWait -ge 0) {
                $newState = $state.Clone()
                $newState.ore += $newState.oreR * $timeToWait
                $newState.clay += $newState.clayR * $timeToWait
                $newState.obsidian += $newState.obsidianR * $timeToWait
                $newState.geode += $newState.geodeR * $timeToWait
                $newState.ore -= $blueprint.clayRobotOre
                $newState.time -= $timeToWait
                $newState.clayR++
                $states.Push($newState)
            }
        }
        if ($state.oreR -and $state.clayR -and $state.obsidianR -lt $blueprint.geodeRobotobsidian) {
            #make obsidian robot
            $timeToWait1 = [math]::Ceiling([math]::Max(0, $blueprint.obsidianRobotore - $state.ore) / $state.oreR)
            $timeToWait2 = [math]::Ceiling([math]::Max(0, $blueprint.obsidianRobotclay - $state.clay) / $state.clayR)
            $timeToWait = [math]::Max($timeToWait1, $timeToWait2) + 1
            if ($state.time - $timeToWait -ge 0) {
                $newState = $state.Clone()
                $newState.ore += $newState.oreR * $timeToWait
                $newState.clay += $newState.clayR * $timeToWait
                $newState.obsidian += $newState.obsidianR * $timeToWait
                $newState.geode += $newState.geodeR * $timeToWait
                $newState.ore -= $blueprint.obsidianRobotore
                $newState.clay -= $blueprint.obsidianRobotclay
                $newState.time -= $timeToWait
                $newState.obsidianR++
                $states.Push($newState)
            }
        }
        if ($state.oreR -and $state.obsidianR) {
            $timeToWait1 = [math]::Ceiling([math]::Max(0, $blueprint.geodeRobotore - $state.ore) / $state.oreR)
            $timeToWait2 = [math]::Ceiling([math]::Max(0, $blueprint.geodeRobotobsidian - $state.obsidian) / $state.obsidianR)
            $timeToWait = [math]::Max($timeToWait1, $timeToWait2) + 1
            if ($state.time - $timeToWait -ge 0) {
                $newState = $state.Clone()
                $newState.ore += $newState.oreR * $timeToWait
                $newState.clay += $newState.clayR * $timeToWait
                $newState.obsidian += $newState.obsidianR * $timeToWait
                $newState.geode += $newState.geodeR * $timeToWait
                $newState.ore -= $blueprint.geodeRobotore
                $newState.obsidian -= $blueprint.geodeRobotobsidian
                $newState.time -= $timeToWait
                $newState.geodeR++
                $states.Push($newState)
            }
        }

        if ($state.geode + $state.geodeR * $state.time -gt $maxGeode) {
            $maxGeode = $state.geode + $state.geodeR * $state.time
        }
    }
    return $maxGeode
}

function Parse-Input ($sample) {
    foreach ($line in $sample) {
        if ($line -match 'Blueprint [0-9]+: Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian.') {
            @{
                oreRobotOre        = [int]$Matches[1]
                clayRobotOre       = [int]$Matches[2]
                obsidianRobotore   = [int]$Matches[3]
                obsidianRobotclay  = [int]$Matches[4]
                geodeRobotore      = [int]$Matches[5]
                geodeRobotobsidian = [int]$Matches[6]
                maxOreCost         = ([int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[5]) | Measure-Object -Maximum | % Maximum
            }
        }
        else {
            write-error 'parse error'
        }
    }
}



'Sample result should be: 33'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
