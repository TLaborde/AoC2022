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

function Find-Result ($sample, $size = 2) {
    $rope = New-Rope -Size $size
    $tailPos = New-Object System.Collections.Generic.HashSet[string]
    foreach ($line in $sample) {
        $direction, $amount = $line -split ' '
        for ($i = 0; $i -lt $amount; $i++) {
            # update head
            switch ($direction) {
                'R' { $rope[0].x++ ; break }
                'L' { $rope[0].x-- ; break }
                'U' { $rope[0].y++ ; break }
                'D' { $rope[0].y-- ; break }
                Default {
                    Write-Error 'parse error' # shouldn't happen
                }
            }
            # update rest
            for ($j = 1; $j -lt $rope.Count; $j++) {
                $rope[$j] = Update-Tail $rope[($j - 1)] $rope[$j]
            }
            # store new tail position if new
            $null = $tailPos.Add('T=' + $rope[$rope.Count - 1].x + 'x' + $rope[$rope.Count - 1].y)
        }
    }
    $tailPos.count
}

function Find-Result2 ($sample) {
    Find-Result $sample 10
}

function New-Rope ($size) {
    1..$size | ForEach-Object { @{x = 0; y = 0 } }
}
function Update-Tail ($head, $tail) {
    # if we are adjacent or on same position, don't move
    if ([math]::Abs($head.x - $tail.x) -le 1 -and [math]::Abs($head.y - $tail.y) -le 1) {
        return $tail 
    }

    #vertical/horizontal move
    $newTail = @{x = (($head.x + $tail.x) / 2); y = ($head.y + $tail.y) / 2 }

    # rule for moving in a L shape
    if ([math]::Abs($head.x - $tail.x) -eq 1) {
        $newTail.x = $head.x
    }  
    if ([math]::Abs($head.y - $tail.y) -eq 1) {
        $newTail.y = $head.y
    }

    return $newTail
}


'Sample result should be: 13'
Find-Result $sample

Find-Result $data



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
