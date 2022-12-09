. ./common.ps1
$data = Get-Content .\3.input.txt

$sample = @'
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
'@ -split "`n"

function Find-Result ($sample)
{
    $hash = @{}
    $i = 1
    97..122 | ForEach-Object { $hash[[char]$_] = $i++ }
    65..90 | ForEach-Object { $hash[[char]$_] = $i++ }
    $sample | ForEach-Object {
        $first, $last = Split-Half $_
        $common = [char[]]$first  | Where-Object { $last -cmatch $_ } | Select-Object -first 1
        $hash[$common]
    } | Measure-Object -Sum | ForEach-Object sum
}

function Find-Result2 ($sample)
{
    $hash = @{}
    $i = 1
    97..122 | ForEach-Object { $hash[[char]$_] = $i++ }
    65..90 | ForEach-Object { $hash[[char]$_] = $i++ }
    $commons = for ($i = 0; $i -lt $sample.Count; $i = $i + 3)
    {
        [char[]]$sample[$i] | Where-Object { $sample[$i + 1].Contains($_) } | Where-Object { $sample[$i + 2].Contains($_) }  | Select-Object -first 1
    }
    $commons | ForEach-Object { $hash[$_] } | Measure-Object -Sum | ForEach-Object sum
}




'Sample result should be: 157'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
