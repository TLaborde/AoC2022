. ./common.ps1
$data = gc .\17.input.txt

$sample = @"
>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
"@ -split "`n"

function Find-Result ($sample, $rockfall = 2022) {
    $sample = $sample -replace "`r|`n"
    [int64]$rocks = 0
    [int64]$step = 0
    [int64]$highest = 0
    $terrain = New-HashSet -Type "int64"
    $null = 0..6 | % { $terrain.Add($_) }
    do {
        $rocks, $step, $Highest = Add-Block -Rocks $rocks -Terrain $terrain -Step $step -Highest $highest
    }while ($rocks -lt $rockfall)
    $Highest
}

function Find-Result2 ($sample, $rockfall = 2022) {
    $sample = $sample -replace "`r|`n"
    [int64]$rocks = 0
    [int64]$step = 0
    [int64]$highest = 0
    $terrain = New-HashSet -Type "int64"
    $null = 0..6 | % { $terrain.Add($_) }
    $terrainKeys = @{}
    do {
        $peakSum = Get-Peaks -Terrain $terrain -Highest $highest
        $terrainKey = ( @(($rocks % 5), ($step % $sample.Length)) + $peakSum) -join "-"
        if ($terrainKeys.Contains($terrainKey)) {
            $previousRocks, $previousHighest = $terrainKeys[$terrainKey] 
            $cyclePeriod = $rocks - $previousRocks
            $remainingCycles = [math]::Floor($rockfall / $cyclePeriod) - 1 # remove current cycle found
            $remainingRocks = $rockfall - ($rocks + $cyclePeriod * $remainingCycles)
            $y = ($highest - $previousHighest) * $remainingCycles
            for ($j = 0; $j -lt $remainingRocks; $j++) {
                $rocks, $step, $Highest = Add-Block -Rocks $rocks -Terrain $terrain -Step $step -Highest $highest
            }
            return $highest + $y
        }
        else {
            $terrainKeys[$terrainKey] = @($rocks, $highest)
        }
        $rocks, $step, $Highest = Add-Block -Rocks $rocks -Terrain $terrain -Step $step -Highest $highest
    }while ($rocks -lt $rockfall)
    return $highest
}

function Add-Block ($rocks, $terrain, $step, $Highest) {
    $newRock = Get-Block ($rocks % 5)
    for ($i = 0; $i -lt $newRock.Count; $i++) {
        $newRock[$i] += [int]($Highest + 4) * 7
        $newRock[$i] += 2
    }
    do {
        $null = Try-Move -Rock $newRock -Direction $sample[$step % $sample.Length] -Terrain $Terrain
        $step++
    }while ((Try-GoDown -Rock $newRock -Terrain $Terrain))
    $null = $newRock | % { $terrain.Add($_) }
    $rocks++
    $Highest = [math]::Floor(($terrain | Measure-Object -Maximum | % Maximum) / 7)
    $rocks, $step, $Highest
}
function Get-Peaks ($Terrain, $Highest) {
    $peaks = @(0, 0, 0, 0, 0, 0, 0)
    foreach ($t in $terrain) {
        $tk = $t % 7
        $peaks[$tk] = [math]::max([math]::Floor($t / 7), $peaks[$tk])
    }
    $peaks | % { $highest - $_ }
}
function Clear-Terrain {
    [OutputType([System.Collections.Generic.HashSet[[int64]]])]
    Param($terrain) 
    $active = New-HashSet -Type "int64"
    $terrain | sort -Descending | select -first 100 | % { $active.Add($_) }
    return $active
    $maxHigh = [math]::Floor(($terrain | Measure-Object -Maximum | % Maximum) / 7) * 7 + 7
    $active = New-HashSet -Type "int64"
    $null = [int64]($maxHigh)..[int64]($maxHigh + 6) | % { $active.Add($_) }
    $newTerrain = New-HashSet -Type "int64"
    while ($active.Count) {
        #go down
        $newActive = New-HashSet -Type "int64"
        foreach ($current in $active) {
            if ($terrain.Contains($current - 7)) {
                $null = $newTerrain.Add($current - 7)
            }
            else {
                $null = $newActive.Add($current - 7)
            }
        }
        #go lat
        $lat = New-HashSet -Type "int64"
        foreach ($current in $newActive) {
            $current
            while ($current % 7 -ne 0) {
                $current--
                if ($terrain.Contains($current)) {
                    $null = $newTerrain.Add($current)
                    break
                }
                else {
                    $null = $lat.Add($current)
                }
            }
            while ($current % 7 -ne 6) {
                $current++
                if ($terrain.Contains($current)) {
                    $null = $newTerrain.Add($current)
                    break
                }
                else {
                    $null = $lat.Add($current)
                }
            }
        }
        $null = $lat | % { $newActive.Add($_) }
        $active = $newActive
    }
    return $newTerrain
}
function Try-GoDown ($rock, $terrain) {
    for ($i = 0; $i -lt $rock.Count; $i++) {
        $rock[$i] -= 7
    }

    $revertMove = $false
    foreach ($r in $rock) {
        if ($terrain.Contains($r)) {
            $revertMove = $true
            break
        }
    }
    if ($revertMove) {
        for ($i = 0; $i -lt $rock.Count; $i++) {
            $rock[$i] += 7
        }
    }
    return !$revertMove
}
function Try-Move ($rock, $direction, $terrain) {
    $revertMove = $false
    if ($direction -eq "<") {
        $offset = -1
        for ($i = 0; $i -lt $rock.Count; $i++) {
            if ($rock[$i] % 7 -eq 0) { $revertMove = $true }
        }
    }
    else {
        $offset = 1
        for ($i = 0; $i -lt $rock.Count; $i++) {
            if ($rock[$i] % 7 -eq 6) { $revertMove = $true }
        }
    }

    for ($i = 0; $i -lt $rock.Count; $i++) {
        $rock[$i] += $offset
    }

    foreach ($r in $rock) {
        if ($terrain.Contains($r)) {
            $revertMove = $true
            break
        }
    }
    if ($revertMove) {
        for ($i = 0; $i -lt $rock.Count; $i++) {
            $rock[$i] -= $offset
        }
    }
}

function Get-Block ($pos) {
    switch ($pos) {
        0 { return [int64[]]@(0, 1, 2, 3) }
        1 { return [int64[]]@(1, 7, 8, 9, 15) }
        2 { return [int64[]]@(0, 1, 2, 9, 16) }
        3 { return [int64[]]@(0, 7, 14, 21) }
        4 { return [int64[]]@(0, 1, 7, 8) }
    }
}



"Sample result should be: "
#Find-Result $sample -rockfall 2022

#Find-Result $data -rockfall 2022

"Second part, sample result should be: "
#Find-Result2 $sample[0] -rockfall 1000000000000

Find-Result2 $data -rockfall 1000000000000