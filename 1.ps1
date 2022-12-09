. ./common.ps1
$data = gc .\1.input.txt

$sample = @"
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
"@ -split "`r`n"

function Find-Result ($sample) {
    Get-Sums $sample | sort -Descending | select -first 1
}
function Find-Result2 ($sample) {
    Get-Sums $sample | sort -Descending | select -first 3 | Measure-Object -sum | % sum
}

function Get-Sums ($sample) {
    $currentSum = 0
    $allSums = @()
    for ($i = 0; $i -lt $sample.Count; $i++) {
        if(!$sample[$i]) {
            $allSums += $currentSum
            $currentSum = 0
            continue
        }
        $currentSum += $sample[$i]
    }
    $allSums += $currentSum
    $allSums
}

"Sample result should be: 24000"
Find-Result $sample

Find-Result $data

"Second part, sample result should be: 45000"
Find-Result2 $sample

Find-Result2 $data