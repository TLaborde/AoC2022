. ./common.ps1
$data = Get-Content .\14.input.txt

$sample = @'
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
'@ -split "`n"

function Find-Result ($sample)
{
    $Blocks, $maxY = Generate-Rock $sample
    $start = $blocks.Count
    While (Add-Sand -Blocks $Blocks -MaxY $maxY) {}
    $blocks.count - $start
}

function Find-Result2 ($sample)
{
    $Blocks, $maxY = Generate-Rock $sample
    $start = $blocks.Count
    While (Add-Sand2 -Blocks $Blocks -MaxY $maxY) {}
    $blocks.count - $start
}

function Add-Sand ($Blocks, $x = 500, $y = 0, $MaxY)
{
    do
    {
        $currentY = $y
        while (!($Blocks.Contains("$($x)x$($y+1)"))) # go down
        {
            $y++
            if ($y -gt $MaxY)
            { return $false }
        }
        if (!($Blocks.Contains("$($x-1)x$($y+1)"))) # go left
        {
            $x--
            $y++
        }
        elseif (!($Blocks.Contains("$($x+1)x$($y+1)") )) # go right
        {
            $x++
            $y++
        }
    } while ($currentY -ne $y)
    return $blocks.Add("$($x)x$($y)")
}

function Add-Sand2 ($Blocks, $x = 500, $y = 0, $MaxY)
{
    do
    {
        $currentY = $y
        while (!($Blocks.Contains("$($x)x$($y+1)")) -and ($y -lt ($MaxY + 1)))
        {
            $y++
        }
        if (!($Blocks.Contains("$($x-1)x$($y+1)")) -and ($y -lt ($MaxY + 1)))
        {
            $x--
            $y++
        }
        elseif (!($Blocks.Contains("$($x+1)x$($y+1)")) -and ($y -lt ($MaxY + 1)))
        {
            $x++
            $y++
        }
    } while ($currentY -ne $y)
    return $blocks.Add("$($x)x$($y)")
}
function Generate-Rock ($sample)
{
    $maxY = 0
    $blocks = New-HashSet
    foreach ($line in $sample)
    {
        $segments = $line -split ' -> '
        for ($i = 0; $i -lt ($segments.Count - 1); $i++)
        {
            [int]$sourceX, [int]$sourceY = $segments[$i] -split ','
            [int]$destinationX, [int]$destinationY = $segments[$i + 1] -split ','
            foreach ($x in $sourceX..$destinationX)
            {
                foreach ($y in $sourceY..$destinationY)
                {
                    if ($maxY -lt $y) { $maxY = $y }
                    $null = $blocks.Add("$($x)x$($y)")
                }
            }
        }
    }
    $blocks, $maxY
}


'Sample result should be: 24'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: 93 '
Find-Result2 $sample

Find-Result2 $data
