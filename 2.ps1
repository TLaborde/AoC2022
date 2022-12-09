$data = Get-Content .\2.input.txt


. ./common.ps1
$data = Get-Content .\2.input.txt

$sample = @'
A Y
B X
C Z
'@ -split "`r`n"

function Find-Result ($sample)
{
    #
    # A for Rock, B for Paper, and C for Scissors. 
    # X for Rock, Y for Paper, and Z for Scissors.
    # shape you selected (1 for Rock, 2 for Paper, and 3 for Scissors) plus the 
    # score for the outcome of the round (0 if you lost, 3 if the round was a draw, and 6 if you won).
    $scores = @{
        'A X' = 1 + 3
        'B X' = 1 + 0
        'C X' = 1 + 6
        'A Y' = 2 + 6
        'B Y' = 2 + 3
        'C Y' = 2 + 0
        'A Z' = 3 + 0
        'B Z' = 3 + 6
        'C Z' = 3 + 3
    }

    $sample | ForEach-Object { $scores[$_] } | Measure-Object -Sum | ForEach-Object Sum
}

function Find-Result2 ($sample)
{
    
    # X means you need to lose, Y means you need to end the round in a draw, and Z means you need to win.
    $scores = @{
        'A X' = 0 + 3
        'B X' = 0 + 1
        'C X' = 0 + 2
        'A Y' = 3 + 1
        'B Y' = 3 + 2
        'C Y' = 3 + 3
        'A Z' = 6 + 2
        'B Z' = 6 + 3
        'C Z' = 6 + 1
    }
    $sample | ForEach-Object { $scores[$_] } | Measure-Object -Sum | ForEach-Object Sum
}
'Sample result should be: 15'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: 12'
Find-Result2 $sample

Find-Result2 $data
