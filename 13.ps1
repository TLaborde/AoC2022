. ./common.ps1
$data = Get-Content .\13.input.txt

$sample = @'
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
'@ -split "`n"

function Find-Result ($sample)
{
    $sum = 0
    for ($i = 0; $i -lt $sample.Count; $i = $i + 3)
    {
        $left = Parse-input $sample[$i]
        $right = Parse-input $sample[$i + 1]
        if ((Compare-SignalPS $left $right) -lt 0)
        {
            $sum += ($i / 3) + 1
        }
    }
    $sum
}

function Parse-Input ($s)
{
    ConvertFrom-Json $s -NoEnumerate
}
function Find-Result2 ($sample)
{
    $array = ($sample + @('[[2]]', '[[6]]')) | Where-Object { $_.length -gt 1 }
    $array = Sort-ObjectCustom $array
    ($array.IndexOf('[[2]]') + 1) * ($array.IndexOf('[[6]]') + 1)
}

function Sort-ObjectCustom($array)
{
    switch ($array.count)
    {
        0 {}
        1 { $array }
        2 { if ( Compare-Signal (Parse-Input $array[0]) (Parse-Input $array[1]) -lt) { $array[0], $array[1] } else { $array[1], $array[0] } }
        default
        {
            $anchor = get-random $array 
            $lt = $array | Where-Object { (Compare-Signal (Parse-Input $_) (Parse-Input $anchor)) -lt 0 }
            $eq = $array | Where-Object { (Compare-Signal (Parse-Input $_) (Parse-Input $anchor)) -eq 0 }
            $gt = $array | Where-Object { (Compare-Signal (Parse-Input $_) (Parse-Input $anchor)) -gt 0 }
            @(Sort-ObjectCustom $lt) + @($eq) + @(Sort-ObjectCustom $gt)
        }
    }
}

function Compare-Signal ($left, $right)
{
    if ($left -isnot [array] -and $right -isnot [array])
    {
        return ([int]$left - [int]$right)
    }
    if ($left -isnot [array])
    { 
        return Compare-Signal (, $left) $right
    }
    if ($right -isnot [array])
    { 
        if ($right.count -eq 0) { return ($left.count - $right.count) }
        return Compare-Signal ($left) (, $right)
    }
    for ($i = 0; $i -lt $left.Count; $i++)
    {
        $subResult = Compare-Signal $left[$i] $right[$i]
        if ($subResult -ne 0)
        {
            return $subResult
        }
    }
    return ($left.count - $right.count)
}

'Sample result should be: 13'
Find-Result $sample



Find-Result $data
'The result for solution 1 is: 5843'
'Second part, sample result should be: 140'
Find-Result2 $sample

Find-Result2 $data
'The result for solution 2 is: 26289'