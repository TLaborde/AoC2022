. ./common.ps1
$data = Get-Content .\22.input.txt

$sample = @'
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
'@ -split "`n"

function Find-Result ($sample) {
    $code, $map = Parse-Input $sample
    $me = @{
        position  = @(0, ($map[0].Keys | Sort-Object | Select-Object -first 1))
        # Facing is 0 for right (>), 1 for down (v), 2 for left (<), and 3 for up (^).
        direction = 0
    }

    foreach ($move in $code) {
        Move-Me $me $move $map
        # $me.position -join 'x'
    }
    (($me.position[0] + 1) * 1000 + (($me.position[1] + 1) * 4) + $me.direction)
}


function Find-Result2 ($sample) {
    $code, $map = Parse-Input $sample
    $me = @{
        position  = @(0, ($map[0].Keys | Sort-Object | Select-Object -first 1))
        # Facing is 0 for right (>), 1 for down (v), 2 for left (<), and 3 for up (^).
        direction = 0
    }

    foreach ($move in $code) {
        Move-MeCube $me $move $map
       
        # $me.position -join 'x'
    }
    (($me.position[0] + 1) * 1000 + (($me.position[1] + 1) * 4) + $me.direction)
}




function Move-Me ($me, $move, $map) {
    if ($move -eq 'L') {
        $me.direction = ($me.direction + 3) % 4
    }
    elseif ($move -eq 'R') {
        $me.direction = ($me.direction + 1) % 4
    }
    else {
        $move = [int]$move
        for ($i = 0; $i -lt $move; $i++) {
            $nextStep = switch ($me.direction) {
                0 { @($me.position[0], ($me.position[1] + 1)) }
                1 { @(($me.position[0] + 1), $me.position[1]) }
                2 { @($me.position[0], ($me.position[1] - 1)) }
                3 { @(($me.position[0] - 1), $me.position[1]) }
            }
            if (!$map[$nextStep[0]] -or !$map[$nextStep[0]][$nextStep[1]]) {
                do {
                    $nextStep = switch ($me.direction) {
                        0 { @($nextStep[0], ($nextStep[1] - 1)) }
                        1 { @(($nextStep[0] - 1), $nextStep[1]) }
                        2 { @($nextStep[0], ($nextStep[1] + 1)) }
                        3 { @(($nextStep[0] + 1), $nextStep[1]) }
                    }
                } while ($map[$nextStep[0]] -and $map[$nextStep[0]][$nextStep[1]])
                $nextStep = switch ($me.direction) {
                    0 { @($nextStep[0], ($nextStep[1] + 1)) }
                    1 { @(($nextStep[0] + 1), $nextStep[1]) }
                    2 { @($nextStep[0], ($nextStep[1] - 1)) }
                    3 { @(($nextStep[0] - 1), $nextStep[1]) }
                }
            }
            if ($map[$nextStep[0]][$nextStep[1]] -eq 'free') {
                $me.position = $nextStep
            }
            else {
                return
            }
        }
    }
}


function Move-MeCube ($me, $move, $map) {
    if ($move -eq 'L') {
        $me.direction = ($me.direction + 3) % 4
    }
    elseif ($move -eq 'R') {
        $me.direction = ($me.direction + 1) % 4
    }
    else {
        $move = [int]$move
        for ($i = 0; $i -lt $move; $i++) {
            $nextStep = switch ($me.direction) {
                0 { @($me.position[0], ($me.position[1] + 1)) }
                1 { @(($me.position[0] + 1), $me.position[1]) }
                2 { @($me.position[0], ($me.position[1] - 1)) }
                3 { @(($me.position[0] - 1), $me.position[1]) }
            }
            $newDirection = $me.direction
            if (!$map[$nextStep[0]] -or !$map[$nextStep[0]][$nextStep[1]]) {
                if ($nextStep[0] -eq -1 -and $nextStep[1] -lt 100) {
                    # from top to back
                    $nextStep = @( (100 + $nextStep[1]) , 0)
                    $newDirection = 0
                }
                elseif ($nextStep[0] -eq -1 -and $nextStep[1] -ge 100) {
                    #from right, arrive to back from bottom
                    $nextstep = @(199, ($nextStep[1] - 100))
                }
                elseif ($nextstep[1] -eq 150) {
                    #right to bottom
                    $nextstep = @((149 - $nextStep[0]), 99)
                    $newDirection = 2
                }
                elseif ($me.position[0] -eq 49 -and $nextstep[0] -eq 50) {
                    # from right to front
                    $nextstep = @((50 + ($nextStep[1] % 50)), 99)
                    $newDirection = 2
                }
                elseif ($me.position[1] -eq 99 -and $nextStep[1] -eq 100) {
                    if ($me.position[0] -le 99) {
                        # from front to right
                        $nextstep = @(49, ($nextStep[0] + 50))
                        $newDirection = 3
                    }
                    else {
                        # from bottom to right
                        $nextstep = @((49 - ($nextStep[0] % 50) ), 149)
                        $newDirection = 2
                    }
                }
                elseif ($me.position[0] -eq 149 -and $nextStep[0] -eq 150) {
                    # from bottom to back
                    $nextstep = @((150 + ($nextStep[1] % 50) ), 49)
                    $newDirection = 2
                }
                elseif ($nextStep[1] -eq 50 -and $me.position[1] -eq 49) {
                    # from back to bottom
                    $nextStep = @(149, (50 + ($nextStep[0] % 50)))
                    $newDirection = 3
                }
                
                elseif ($nextstep[0] -eq 200) {
                    # from back to right
                    $nextStep = @(0, (100 + ($nextStep[1] % 50)))
                    $newDirection = 1
                }
                elseif ($nextstep[1] -eq -1 -and $nextStep[0] -gt 149) {
                    # from back to top
                    $nextStep = @(0, (50 + ($nextStep[0] % 50)))
                    $newDirection = 1
                }
                elseif ($nextstep[1] -eq -1 -and $nextStep[0] -le 149) {
                    # from left to top
                    $nextStep = @((49 - ($nextStep[0] % 50)), 50)
                    $newDirection = 0
                }
                elseif ($nextstep[0] -eq 99 -and $me.position[0] -eq 100) {
                    # from left to front
                    $nextStep = @((50 + $nextStep[1]), 50)
                    $newDirection = 0
                }
                elseif ($nextstep[1] -eq 49 -and $me.position[1] -eq 50 -and $nextStep[0] -ge 50) {
                    # from front to left
                    $nextStep = @(100, ($nextStep[0] % 50))
                    $newDirection = 1
                }
                elseif ($nextstep[1] -eq 49 -and $me.position[1] -eq 50 -and $nextStep[0] -lt 50) {
                    # from top to left
                    $nextStep = @((149 - ($nextStep[0] % 50)), 0)
                    $newDirection = 0
                }
            }
            if ($map[$nextStep[0]][$nextStep[1]] -eq 'free') {
                $me.position = $nextStep
                $me.direction = $newDirection
            }
            else {
                return
            }
        }
    }
}


function Parse-Input ($sample) {
    $map = @{}
    for ($i = 0; $i -lt $sample.Count; $i++) {
        if ($sample[$i] -match '[#\.]+') {
            $map[$i] = @{}
            for ($j = 0; $j -lt $sample[$i].Length; $j++) {
                if ($sample[$i][$j] -eq '.') {
                    $map[$i][$j] = 'free'
                }
                elseif ($sample[$i][$j] -eq '#') {
                    $map[$i][$j] = 'wall'
                }
            }
        }
    }
    $code = $sample[-1] -replace "`n|`r" -replace 'R', ',R,' -replace 'L', ',L,' -split ','
    $code, $map
}


'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
# 65324 is too low
# 183071 is too high
# not 101240