. ./common.ps1
$data = Get-Content .\19.input.txt

$sample = @'
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
'@ -split "`n"

function Find-Result ($sample)
{
    $blueprints = Parse-Input $sample
    $total = 0
    for ($i = 0; $i -lt $blueprints.Count; $i++)
    {
        $bestGeode = Find-BestGeode $blueprints[$i]
        $total += ($i + 1) * $bestGeode
    }
    $total
}

function Find-Result2 ($sample)
{

}

function Find-BestGeode ($blueprint)
{
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
            time      = 24
        }
    )
    $fields = $states[0].keys | Where-Object { $_ -ne 'time' } | Sort-Object
    $maxGeode = 0
    $knownStates = @{}
    while ($states.count)
    {
        $state = $states.Pop()
        if ($state.time -le 0)
        {
            if ($state.geode -gt $maxGeode)
            {
                $maxGeode = $state.geode
                write-host "new max $maxGeode"
            }
            continue
        }
        else
        {
            $key = [tuple]::create(($fields | ForEach-Object { $state[$_] })).gethashcode()
            if ($knownStates.ContainsKey($key) -and $knownStates[$key] -gt $state.time)
            {
                continue
            }
            $knownStates[$key] = $state.time

            if ($state.obsidian -lt $blueprint.geodeRobotobsidian -or $state.ore -lt $blueprint.geodeRobotore)
            {
                # in case we don't build stuff
                $newState = $state.Clone()
                $newState.ore += $newState.oreR
                $newState.clay += $newState.clayR
                $newState.obsidian += $newState.obsidianR
                $newState.geode += $newState.geodeR
                $newState.time--
                $states.Push($newState)
            }


            if ($state.ore -ge $blueprint.oreRobotOre)
            {
                #make ore robot
                $newState = $state.Clone()
                $newState.ore += $newState.oreR
                $newState.clay += $newState.clayR
                $newState.obsidian += $newState.obsidianR
                $newState.geode += $newState.geodeR
                $newState.oreR++
                $newState.ore -= $blueprint.oreRobotOre
                $newState.time--
                $states.Push($newState)
            }
            if ($state.ore -ge $blueprint.clayRobotOre)
            {
                #make clay robot
                $newState = $state.Clone()
                $newState.ore += $newState.oreR
                $newState.clay += $newState.clayR
                $newState.obsidian += $newState.obsidianR
                $newState.geode += $newState.geodeR
                $newState.clayR++
                $newState.ore -= $blueprint.clayRobotore
                $newState.time--
                $states.Push($newState)
            }
            if ($state.clay -ge $blueprint.obsidianRobotclay -and $state.ore -ge $blueprint.obsidianRobotore) #make obsidian robot
            {
                $newState = $state.Clone()
                $newState.ore += $newState.oreR
                $newState.clay += $newState.clayR
                $newState.obsidian += $newState.obsidianR
                $newState.geode += $newState.geodeR
                $newState.obsidianR++
                $newState.clay -= $blueprint.obsidianRobotclay
                $newState.ore -= $blueprint.obsidianRobotore
                $newState.time--
                $states.Push($newState)
            }
            if ($state.obsidian -ge $blueprint.geodeRobotobsidian -and $state.ore -ge $blueprint.geodeRobotore)
            {
                # make geode robot
                $newState = $state.Clone()
                $newState.ore += $newState.oreR
                $newState.clay += $newState.clayR
                $newState.obsidian += $newState.obsidianR
                $newState.geode += $newState.geodeR
                $newState.geodeR++
                $newState.obsidian -= $blueprint.geodeRobotobsidian
                $newState.ore -= $blueprint.geodeRobotore
                $newState.time--
                $states.Push($newState)
            }

        }
    }

    return $maxGeode
}


function Parse-Input ($sample)
{
    foreach ($line in $sample)
    {
        if ($line -match 'Blueprint [0-9]+: Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian.')
        {
            @{
                oreRobotOre        = [int]$Matches[1]
                clayRobotOre       = [int]$Matches[2]
                obsidianRobotore   = [int]$Matches[3]
                obsidianRobotclay  = [int]$Matches[4]
                geodeRobotore      = [int]$Matches[5]
                geodeRobotobsidian = [int]$Matches[6]
            }
        }
        else
        {
            write-error 'parse error'
        }
    }
}



'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data

# go from result
#to have 1 at the end, need 1 machine step - 1