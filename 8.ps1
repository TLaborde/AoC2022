. ./common.ps1
$data = Get-Content .\8.input.txt

$sample = @'
30373
25512
65332
33549
35390
'@ -split "`r`n"

function Find-Result ($sample)
{
    $rows, $columns = Parse-Input $sample
    $count = 0
    write-host ($rows[0] -join '') -BackgroundColor Green
    for ($i = 1; $i -lt $rows.Count - 1; $i++)
    {
        Write-Host $rows[$i][0] -NoNewline -BackgroundColor Green
        for ($j = 1; $j -lt $columns.Count - 1; $j++)
        {
            if ((Test-Visible $rows[$i] $j) -or (test-visible $columns[$j] $i))
            {
                $count++
                Write-Host $rows[$i][$j] -NoNewline -BackgroundColor Green
            }
            else
            {
                Write-Host $rows[$i][$j] -NoNewline -BackgroundColor red
            }
        }
        Write-Host $rows[$i][$rows.Count - 1] -NoNewline -BackgroundColor Green
        Write-Host ''
    }
    write-host ($rows[$rows.Count - 1] -join '') -BackgroundColor Green
    $count + $rows.Count * 2 + ($columns.count - 2) * 2
}

function Find-Result2 ($sample)
{
    $rows, $columns = Parse-Input $sample
    $max = 0
    for ($i = 1; $i -lt $rows.Count - 1; $i++)
    {
        for ($j = 1; $j -lt $columns.Count - 1; $j++)
        {

            $val = (Get-ScenicValue $rows[$i] $j) * (Get-ScenicValue $columns[$j] $i)
            $max = [math]::Max($val, $max)
        }
    }
    $max
}

function Parse-Input ($sample)
{
    $rows = @()
    $columns = @()
    $line = $sample[0] -split '' | Where-Object { $_ }
    $rows += , $line
    $line | ForEach-Object { $columns += , $_ }
    for ($i = 1; $i -lt $sample.Count; $i++)
    {
        $line = $sample[$i] -split '' | Where-Object { $_ }
        $rows += , $line
        for ($j = 0; $j -lt $line.Count; $j++)
        {
            $columns[$j] += $line[$j]
        }
    }
    for ($i = 0; $i -lt $columns.Count; $i++)
    {
        $columns[$i] = $columns[$i] -split '' | Where-Object { $_ }
    }
    $rows, $columns
}
function Test-Visible ($row, $x)
{

    if (($row[0..($x - 1)] | Measure-Object -Maximum | ForEach-Object Maximum) -lt $row[$x])
    {
        return $true
    }
    if (($row[($x + 1)..($row.count)] | Measure-Object -Maximum | ForEach-Object Maximum) -lt $row[$x])
    {
        return $true
    }
    return $false
}

function Get-ScenicValue ($row, $x)
{
    $scenicValue1 = 0
    $scenicValue2 = 0

    for ($i = $x - 1; $i -ge 0; $i--)
    {
        $scenicValue1++
        if ($row[$i] -ge $row[$x]) { break }
    }
    for ($i = $x + 1; $i -lt $row.count; $i++)
    {
        $scenicValue2++
        if ($row[$i] -ge $row[$x]) { break }
    }
    $scenicValue1 * $scenicValue2
}


'Sample result should be: 21'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: 8'
Find-Result2 $sample

Find-Result2 $data
