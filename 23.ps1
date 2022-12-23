. ./common.ps1
$data = Get-Content .\23.input.txt

$sample = @'
....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
'@ -split "`n"

function Find-Result ($sample)
{
    $elves = Parse-Input $sample
    $rounds = 10
    for ($i = 0; $i -lt $rounds; $i++)
    {
        $proposedChanges = Get-Phase1 $elves $i
        $null, $elves = Apply-Changes $proposedChanges
        #"end of round $i"
        #Draw-Elves $elves
        #''
    }
    $maxY, $minY = $elves | ForEach-Object { $_[0] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    $maxX, $minX = $elves | ForEach-Object { $_[1] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    ($maxY - $minY + 1) * ($maxX - $minX + 1) - $elves.Count
}

function Draw-Elves ($elves)
{
    $maxY, $minY = $elves | ForEach-Object { $_[0] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    $maxX, $minX = $elves | ForEach-Object { $_[1] } | Measure-Object -Minimum -Maximum | ForEach-Object { $_.maximum, $_.minimum }
    for ([int]$i = $minY; $i -le $maxY; $i++)
    {
        for ([int]$j = $minX; $j -le $maxX; $j++)
        {
            $pos = [tuple]::create($i, $j)
            if ($elves.Contains($pos))
            {
                write-host '#' -NoNewline
            }
            else
            {
                write-host '.' -NoNewline
            }
        }
        write-host ''
    }
}
function Find-Result2 ($sample)
{

    $elves = Parse-Input $sample
    $rounds = 10
    $i = 0
    do
    {
        $proposedChanges = Get-Phase1 $elves $i
        $hasmoves, $elves = Apply-Changes $proposedChanges
        $i++
    } while ($hasmoves)

    $i
}

function Apply-Changes ($proposedChanges)
{
    $conflicts = @(($proposedChanges.values | Group-Object | Where-Object { $_.count -gt 1 }) | ForEach-Object { $_.group[0] })
    $newElves = @()
    $moved = $false
    foreach ($elf in $proposedChanges.GetEnumerator())
    {
        if ($conflicts.Contains($elf.Value))
        {
            $newElves += $elf.Key
        }
        else
        {
            $newElves += $elf.Value
            if ($elf.Value -ne $elf.Key)
            {
                $moved = $true
            }
        }
    }
    $moved, $newElves
}

function Get-Phase1 ($elves, $round)
{
    $proposal = @(
        @(
            @(-1, 0), @(-1, -1), @(-1, 1) # check north
        ),
        @(
            @(1, 0), @(1, -1), @(1, 1) # check south
        ),
        @(
            @(0, -1), @(-1, -1), @(1, -1) # check west
        ),
        @(
            @(0, 1), @(-1, 1), @(1, 1) # check east
        )
    )
    $around = @(@(-1, -1), @(-1, 0), @(-1, 1), @(0, 1), @(1, 1), @(1, 0), @(1, -1), @(0, -1))
    $moves = @{}
    foreach ($elf in $elves)
    {
        $moves[$elf] = $elf
        # if nothing around, don't move
        if (!$around.where({ $elves.Contains([tuple]::Create(($elf[0] + $_[0]), ($elf[1] + $_[1]))) }))
        {
            continue
        }

        for ($i = $round; $i -lt ($round + 4); $i++)
        {
            $conflict = $false
            $prop = $proposal[$i % 4]
            foreach ($p in $prop)
            {
                $newPos = [tuple]::Create(($elf[0] + $p[0]), ($elf[1] + $p[1]))
                if ($elves.Contains($newPos))
                {
                    $conflict = $true
                    break
                }
            }
            if (!$conflict)
            {
                $moves[$elf] = [tuple]::Create(($elf[0] + $prop[0][0]), ($elf[1] + $prop[0][1]))
                break
            }
        }
    }
    $moves
}

function Parse-Input ($sample)
{
    $elves = @()
    for ($i = 0; $i -lt $sample.Count; $i++)
    {
        if ($sample[$i] -match '[#\.]+')
        {
            $map[$i] = @{}
            for ($j = 0; $j -lt $sample[$i].Length; $j++)
            {
                
                if ($sample[$i][$j] -eq '#')
                {
                    $elves += [tuple]::create([int]$i, [int]$j)
                }
            }
        }
    }
    $elves
}


'Sample result should be: '
#Find-Result $sample

#Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
