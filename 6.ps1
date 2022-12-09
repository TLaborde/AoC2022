. ./common.ps1
$data = Get-Content .\6.input.txt

$sample = @'
bvwbjplbgvbhsrlpgdmjqwftvncz
nppdvjthqldpwncqszvftbrmjlhg
nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg
zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw
'@ -split "`n"

function Find-Result ($sample)
{
    foreach ($l in $sample)
    {
        Find-UniqueSec $l 4
    }
}

function Find-Result2 ($sample)
{
    foreach ($l in $sample)
    {
        Find-UniqueSec $l 14
    }
}

function Find-UniqueSec ($l, $uniqueLength)
{
    for ($i = 0; $i -lt $l.Length - $uniqueLength; $i++)
    {
        if (([char[]]$l.Substring($i, $uniqueLength) | Sort-Object -Unique).count -eq $uniqueLength)
        {
            'first unique ' + ($i + $uniqueLength)
            break
        }
    }
}


'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
