. ./common.ps1
$data = gc .\24.input.txt

$sample = @"
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
"@ -replace "`r" -split "`n"

function Find-Result ($sample) {
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int, int]]]$winds, [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$freeSpaces = Parse-Input $sample
    $width = $sample[1].Length - 2
    $height = $sample.Count - 2
    $windMaps = Calculate-WindMaps $winds $freeSpaces $width $height
    write-host "Calculated $($windMaps.Count) unique maps"
    $start = [System.ValueTuple]::create(-1, 0)
    $arrival = [System.ValueTuple]::create(($height - 1), ($width - 1))
    Calculate-Path $windMaps $width $height $start $arrival
}
function Find-Result2 ($sample) {
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int, int]]]$winds, [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$freeSpaces = Parse-Input $sample
    $width = $sample[1].Length - 2
    $height = $sample.Count - 2
    $windMaps = Calculate-WindMaps $winds $freeSpaces $width $height
    write-host "Calculated $($windMaps.Count) unique maps"
    $start = [System.ValueTuple]::create(-1, 0)
    $arrival = [System.ValueTuple]::create(($height - 1), ($width - 1))
    $steps = Calculate-Path $windMaps $width $height $start $arrival
    $arrival = [System.ValueTuple]::create(0, 0)
    $start = [System.ValueTuple]::create($height, ($width - 1))
    $steps = Calculate-Path $windMaps $width $height $start $arrival $steps
    $start = [System.ValueTuple]::create(-1, 0)
    $arrival = [System.ValueTuple]::create(($height - 1), ($width - 1))
    Calculate-Path $windMaps $width $height $start $arrival $steps
}

function Calculate-Path ($windMaps, $width, $height, $start, $arrival, $step = 0) {
    $tries = [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]::new()
    $null = $tries.Add($start)
    $previousStates = [System.Collections.Generic.HashSet[System.ValueTuple[int, int, int]]]::new()
    while ($tries.Count) {
        $step++
        write-host "Step $step"
        $nextTries = [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]::new()
        foreach ($try in $tries) {
            $state = [System.ValueTuple]::create($try[0], $try[1], $step % $windMaps.Count)
            if ($previousStates.Contains($state)) {
                continue
            }
            $null = $previousStates.Add($state)
            # try go north
            if ($try[0] -ge 1) {
                $move = [System.ValueTuple]::create(($try[0] - 1), $try[1])
                if ($windMaps[$step % $windMaps.Count].Contains($move)) {
                    if ($move -eq $arrival) {
                        return ($step + 1)
                    }
                    $null = $nextTries.Add($move)
                }
            }
            # or south
            if ($try[0] -lt ($height - 1)) {
                $move = [System.ValueTuple]::create(($try[0] + 1), $try[1])
                if ($windMaps[$step % $windMaps.Count].Contains($move)) {
                    if ($move -eq $arrival) {
                        return ($step + 1)
                    }
                    $null = $nextTries.Add($move)
                }
            }
            # or west
            if ($try[1] -ge 1) {
                $move = [System.ValueTuple]::create($try[0], ($try[1] - 1))
                if ($windMaps[$step % $windMaps.Count].Contains($move)) {
                    if ($move -eq $arrival) {
                        return ($step + 1)
                    }
                    $null = $nextTries.Add($move)
                }
            }
            # or east
            if ($try[1] -lt ($width - 1)) {
                $move = [System.ValueTuple]::create($try[0], ($try[1] + 1))
                if ($windMaps[$step % $windMaps.Count].Contains($move)) {
                    if ($move -eq $arrival) {
                        return ($step + 1)
                    }
                    $null = $nextTries.Add($move)
                }
            }
            # or don't move
            if ($windMaps[$step % $windMaps.Count].Contains($try) -or $try -eq $start) {
                $null = $nextTries.Add($try)
            }
        }
        $tries = $nextTries
    }
}


function Calculate-WindMaps ($winds, $freeSpaces, $width, $height) {
    $maps = @(, $freeSpaces)
    while ($true) {
        #mark all free
        $free = [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]::new()
        for ($i = 0; $i -lt $height; $i++) {
            for ($j = 0; $j -lt $width; $j++) {
                $null = $free.Add([System.ValueTuple]::create($i, $j))
            }
        }
        #calculate wind change and remove from free
        $newWinds = [System.Collections.Generic.HashSet[System.ValueTuple[int, int, int]]]::new()
        foreach ($wind in $winds) {
            switch ($wind[2]) {
                0 { $x = $wind[0] ; $y = ($wind[1] + 1) % $width }
                1 { $x = ($wind[0] + 1) % $height ; $y = $wind[1] }
                2 { $x = $wind[0] ; $y = ($wind[1] + $width - 1) % $width }
                3 { $x = ($wind[0] + $height - 1) % $height ; $y = $wind[1] }
            }
            # new wind position, remove from free
            $null = $free.Remove([System.ValueTuple]::create($x, $y))
            # and add to new wind
            $null = $newWinds.Add([System.ValueTuple]::create($x, $y, $wind[2]))
        }
        if ($free.SetEquals($freeSpaces)) {
            break
        }
        else {
            $maps += , $free
        }
        $winds = $newWinds
    }
    $maps
}

function Parse-Input ($sample) {
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int, int]]]$winds = [System.Collections.Generic.HashSet[System.ValueTuple[int, int, int]]]::new()
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$freeSpaces = [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]::new()
    $directions = @{
        [char]">" = 0
        [char]"v" = 1
        [char]"<" = 2
        [char]"^" = 3
    }
    for ([int]$i = 1; $i -lt ($sample.Count - 1); $i++) {
        for ([int]$j = 1; $j -lt ($sample[$i].Length - 1); $j++) {
            if ($directions.ContainsKey($sample[$i][$j])) {
                $null = $winds.Add([System.ValueTuple]::create(($i - 1), ($j - 1), $directions[$sample[$i][$j]]))
            }
            else {
                $null = $freeSpaces.Add([System.ValueTuple]::create(($i - 1), ($j - 1)))
            }

        }
    }
    $winds, $freeSpaces
}



"Sample result should be: "
Find-Result $sample

Find-Result $data

"Second part, sample result should be: "
Find-Result2 $sample

Find-Result2 $data
