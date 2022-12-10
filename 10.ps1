. ./common.ps1
$data = gc .\10.input.txt

$sample = @"
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
"@ -split "`n"

function Find-Result ($sample) {
    $X = 1
    $cycle = 0
    $signalStrength = 0
    foreach ($line in $sample) {
        if ($line -match "addx ([-0-9]+)") {
            $cycle++
            if (!(($cycle - 20) % 40)) {
                $signalStrength += $cycle * $X
            }
            $cycle++
            if (!(($cycle - 20) % 40)) {
                $signalStrength += $cycle * $X
            }
            $X += [int]$matches[1]
        }
        if ($line -match "noop") {
            $cycle++
            if (!(($cycle - 20) % 40)) {
                $signalStrength += $cycle * $X
            }
        }
    }
    $signalStrength
    $cycle
}

function Find-Result2 ($sample) {
    $X = 1
    $cycle = 0
    foreach ($line in $sample) {
        if ($line -match "addx ([-0-9]+)") {
            $cycle = Draw-Pixel $cycle $X
            $cycle = Draw-Pixel $cycle $X
            $X += [int]$matches[1]
        }
        if ($line -match "noop") {
            $cycle = Draw-Pixel $cycle $X
        }
    }
}

function Draw-Pixel ($cycle, $X) {
    $cycle = $cycle % 40
    if ([math]::abs($cycle - $X) -le 1) {
        write-host "#"  -NoNewline
    }
    else {
        write-host "."  -NoNewline
    }
    $cycle++
    if (!($cycle % 40)) {
        write-host ""
    }
    $cycle
}


"Sample result should be: 13140"
Find-Result $sample

"Answer to part 1:"
Find-Result $data

"Second part, sample result should be: "
@"
##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....
"@

"Sample run:"
Find-Result2 $sample

"Answer to part 2:"
Find-Result2 $data
