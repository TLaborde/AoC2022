. ./common.ps1
$data = Get-Content .\4.input.txt

$sample = @'
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
'@ -split "`n"

function Find-Result ($sample)
{
    $sample | ForEach-Object {
        $l = $_ -split '-|,' | ForEach-Object { [int]$_ }
        if (Test-Inclusion @l)
        {
            1
        }
    } | Measure-Object -Sum | ForEach-Object sum
}

function Find-Result2 ($sample)
{
    $sample | ForEach-Object {
        $l = $_ -split '-|,' | ForEach-Object { [int]$_ }
        if (Get-Intersect @l)
        {
            1
        }
    } | Measure-Object -Sum | ForEach-Object sum
}




'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
