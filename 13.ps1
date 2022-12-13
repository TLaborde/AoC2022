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
        #$left = $sample[$i] -replace '\[\[\[\[', ',[,[,[,[' -replace '\[\[\[', ',[,[,[' -replace '\[\[', ',[,[' -replace '\[\]', ',@()' -replace '\[', '@(' -replace '\]', ')' | Invoke-Expression
        #$right = $sample[$i + 1] -replace '\[\[\[\[', ',[,[,[,[' -replace '\[\[\[', ',[,[,[' -replace '\[\[', ',[,[' -replace '\[\]', ',@()' -replace '\[', '@(' -replace '\]', ')' | Invoke-Expression
        $left = Parse-input $sample[$i]
        $right = Parse-input $sample[$i + 1]
        #$right = ConvertFrom-Json $sample[$i + 1]
        if (Compare-Signal $left $right)
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

}


function Compare-Signal ($left, $right, $depth = 0)
{
    #if ($left -eq $null) { return 'go' }
    if ($right -eq $null)
    { 
        write-host '    Right side ran out of items, so inputs are not in the right order'
        return $false 
    }
    if ($left -isnot [array] -and $right -isnot [array])
    {
        write-host "comparing $left to $right"
        if ([int]$left -lt [int]$right)
        {
            write-host '    Left side is smaller, so inputs are in the right order'
            return $true
        }
        if ([int]$left -gt [int]$right)
        {
            write-host '    Right side is smaller, so inputs are not in the right order'
            return $false
        }
        if ([int]$left -eq [int]$right)
        {
            return 'go'
        }
    }
    write-host "comparing $( convertto-json -input $left -Compress -Depth 10) to $(convertto-json -input $right -Compress -Depth 10)"
    if ($left -isnot [array])
    { 
        write-host '- Mixed types; convert left to [array] and retry comparison'
        $subResult = Compare-Signal (, $left) $right ($depth)
        return $subResult
    }
    if ($right -isnot [array])
    { 
        write-host '- Mixed types; convert right to [array] and retry comparison'
        $subResult = Compare-Signal ($left) (, $right) ($depth)
        return $subResult
    }
    for ($i = 0; $i -lt $left.Count; $i++)
    {
        $subResult = Compare-Signal $left[$i] $right[$i] ($depth + 1)
        if ($subResult -is [bool])
        {
            return $subResult
        }
    }

    write-host '   Left side ran out of items, so inputs are in the right order'
    return $true
}


'Sample result should be: '
Find-Result $sample



Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
