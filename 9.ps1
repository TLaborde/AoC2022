. ./common.ps1
$data = Get-Content .\9.input.txt

$sample = @'
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
'@ -split "`n"

function Find-Result ($sample)
{
    $head = @{x = 0; y = 0 }
    $tail = @{x = 0; y = 0 }
    $tailPos = @()
    foreach ($line in $sample)
    {
        $direction, $amount = $line -split ' '
        for ($i = 0; $i -lt $amount; $i++)
        {
            switch ($direction)
            {
                'R' { $head.x++ ; break }
                'L' { $head.x-- ; break }
                'U' { $head.y++ ; break }
                'D' { $head.y-- ; break }
                Default
                {
                    Write-Error 'parse error' 
                }
            }
            $tail = Update-Tail $head $tail
            $tailPos += 'T=' + $tail.x + 'x' + $tail.y
        }
    }
($tailPos | Sort-Object -Unique).count
}

function Find-Result2 ($sample)
{
    $rope = @(
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 },
        @{x = 0; y = 0 }
    )
    $tailPos = @()
    foreach ($line in $sample)
    {
        $direction, $amount = $line -split ' '
        for ($i = 0; $i -lt $amount; $i++)
        {
            switch ($direction)
            {
                'R' { $rope[0].x++ ; break }
                'L' { $rope[0].x-- ; break }
                'U' { $rope[0].y++ ; break }
                'D' { $rope[0].y-- ; break }
                Default
                {
                    Write-Error 'parse error' 
                }
            }
            for ($j = 1; $j -lt $rope.Count; $j++)
            {
                $rope[$j] = Update-Tail $rope[($j - 1)] $rope[$j]
            }
            $tailPos += 'T=' + $rope[9].x + 'x' + $rope[9].y 
        }
    }
($tailPos | Sort-Object -Unique).count
}

function Update-Tail ($head, $tail)
{
    if ($head.x -eq $tail.x -and $tail.y -eq $head.y)
    {
        return $tail
    }
    #vertical/horizontal move
    if ([math]::abs($head.x - $tail.x) -eq 2 -and $head.y -eq $tail.y)
    {
        if ($head.x -gt $tail.x)
        {
            $tail.x++
        }
        else
        {
            $tail.x--
        }
    }
    if ([math]::abs($head.y - $tail.y) -eq 2 -and $head.x -eq $tail.x)
    {
        if ($head.y -gt $tail.y)
        {
            $tail.y++
        }
        else
        {
            $tail.y--
        }
        return $tail
    }
    # diagonal move
    if ([math]::abs($head.x - $tail.x) -eq 2 -and [math]::abs($head.y - $tail.y) -eq 1)
    {
        if ($head.x -gt $tail.x)
        {
            $tail.x++
        }
        else
        {
            $tail.x--
        }
        $tail.y = $head.y
    }
    if ([math]::abs($head.y - $tail.y) -eq 2 -and [math]::abs($head.x - $tail.x) -eq 1)
    {
        if ($head.y -gt $tail.y)
        {
            $tail.y++
        }
        else
        {
            $tail.y--
        }
        $tail.x = $head.x
    }
    if ([math]::abs($head.y - $tail.y) -eq 2 -and [math]::abs($head.x - $tail.x) -eq 2)
    {
        if ($head.y -gt $tail.y)
        {
            $tail.y++
        }
        else
        {
            $tail.y--
        }
        if ($head.x -gt $tail.x)
        {
            $tail.x++
        }
        else
        {
            $tail.x--
        }
    }
    return $tail
}



'Sample result should be: 13'
#Find-Result $sample

#Find-Result $data



$sample = @'
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
'@ -split "`n"

'Second part, sample result should be: 36'
Find-Result2 $sample

Find-Result2 $data
