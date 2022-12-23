#. ./common.ps1
$data = Get-Content "C:\Users\Luc\Desktop\AoC2022\23.input.txt"

$sample = @'
....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
'@ -split "`n"

function Find-Result ($sample) {
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$elves = Parse-Input $sample
    $rounds = 10
    for ($i = 0; $i -lt $rounds; $i++) {
        $proposedChanges = Get-Phase1 $elves $i
        $null = Apply-Changes $proposedChanges $elves
        #"end of round $i"
        #Draw-Elves $elves
        #''
    }
    $maxY, $minY = $elves | ForEach-Object { $_[0] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    $maxX, $minX = $elves | ForEach-Object { $_[1] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    ($maxY - $minY + 1) * ($maxX - $minX + 1) - $elves.Count
}

function Draw-Elves ($elves) {
    $maxY, $minY = $elves | ForEach-Object { $_[0] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    $maxX, $minX = $elves | ForEach-Object { $_[1] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    for ([int]$i = $minY; $i -le $maxY; $i++) {
        for ([int]$j = $minX; $j -le $maxX; $j++) {
            $pos = [valuetuple]::create($i, $j)
            if ($elves.Contains($pos)) {
                write-host '#' -NoNewline
            }
            else {
                write-host '.' -NoNewline
            }
        }
        write-host ''
    }
}
function Find-Result2 ($sample) {

    [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$elves = Parse-Input $sample
    $i = 0
    do {
        $proposedChanges = Get-Phase1 $elves $i
        $hasmoves = Apply-Changes $proposedChanges $elves
        $i++
    } while ($hasmoves)
    $i
}

function Apply-Changes ($proposedChanges, $elves) {
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$conflicts = [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]::new()
    ($proposedChanges.values | Group-Object).where({ $_.count -gt 1 }).foreach({ $null = $conflicts.Add($_.group[0]) })
    $moved = 0
    foreach ($elf in $proposedChanges.GetEnumerator().Where({ !$conflicts.Contains($_.Value) })) {
        $null = $elves.Remove($elf.Key)
        $null = $elves.Add($elf.Value)
        $moved++
    }
    $moved
}

function Get-Phase1 ([System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$elves, $round) {
    $proposal = @(
        @(
            [valuetuple]::Create(-1, 0), [valuetuple]::Create(-1, -1), [valuetuple]::Create(-1, 1) # check north
        ),
        @(
            [valuetuple]::Create(1, 0), [valuetuple]::Create(1, -1), [valuetuple]::Create(1, 1) # check south
        ),
        @(
            [valuetuple]::Create(0, -1), [valuetuple]::Create(-1, -1), [valuetuple]::Create(1, -1) # check west
        ),
        @(
            [valuetuple]::Create(0, 1), [valuetuple]::Create(-1, 1), [valuetuple]::Create(1, 1) # check east
        )
    )
    $around = @([valuetuple]::Create(-1, -1), [valuetuple]::Create(-1, 0), [valuetuple]::Create(-1, 1), [valuetuple]::Create(0, 1), [valuetuple]::Create(1, 1), [valuetuple]::Create(1, 0), [valuetuple]::Create(1, -1), [valuetuple]::Create(0, -1))
    $moves = @{}
    $aroundValues = @{}

    foreach ($elf in $elves) {
        for ($i = 0; $i -lt 8; $i++) {
            $aroundValues[$around[$i]] = $elves.Contains([valuetuple]::Create(($elf[0] + $around[$i][0]), ($elf[1] + $around[$i][1]))) 
        }
        if ($true -notin $aroundValues.Values) {
            continue
        }

        for ($i = $round; $i -lt ($round + 4); $i++) {
            $conflict = $false
            $prop = $proposal[$i % 4]
            foreach ($p in $prop) {
                if ($aroundValues[$p]) {
                    $conflict = $true
                    break
                }
            }
            if (!$conflict) {
                $moves[$elf] = [valuetuple]::Create(($elf[0] + $prop[0][0]), ($elf[1] + $prop[0][1]))
                break
            }
        }
    }
    $moves
}

function Parse-Input ($sample) {
    [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]$elves = [System.Collections.Generic.HashSet[System.ValueTuple[int, int]]]::new()
    for ($i = 0; $i -lt $sample.Count; $i++) {
        if ($sample[$i] -match '[#\.]+') {
            for ($j = 0; $j -lt $sample[$i].Length; $j++) {
                if ($sample[$i][$j] -eq '#') {
                    $null = $elves.Add([valuetuple]::create([int]$i, [int]$j))
                }
            }
        }
    }
    $elves
}


'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample


Find-Result2 $data
