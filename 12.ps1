. ./common.ps1
$data = Get-Content .\12.input.txt

$sample = @'
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
'@ -split "`n"

function Find-Result ($sample)
{
    $map = Parse-Map $sample
    Find-Path $map
}
    
function Find-Path ($map)
{
    $begin = New-HashSet
    $null = $begin.add('' + $map.starting.x + 'x' + $map.starting.y)
    $paths = @(, $begin)
    $visited = New-HashSet
    do
    {
        $newPaths = @()
        foreach ($path in $paths)
        {
            
            $possibles = Get-PossibleNextStep $path $map
            foreach ($possible in $possibles)
            {
                if (Test-Arrived $possible $map)
                {
                    return $path.Count
                }
                if ($visited.add($possible))
                {
                    $pathCopy = New-HashSet -Type 'String' -Content $path
                    $null = $pathCopy.Add($possible)
                    $newPaths += , $pathCopy
                }
            }
        }
        $paths = $newPaths
    } while ($paths)
}

$possibleSteps = @{}
function Get-PossibleNextStep ($path, $data)
{
    $em = $data.elevationmap
    $current = @($path)[$path.count - 1]
    if (!$possibleSteps.ContainsKey($current))
    {
        [int]$x, [int]$y = $current -split 'x'
        $poss = @()
        if ($x -gt 0 -and $em[$x - 1][$y] -le ($em[$x][$y] + 1))
        {
            $poss += '' + ($x - 1 ) + 'x' + $y
        }
        if ($x -lt ($em.count - 1) -and $em[$x + 1][$y] -le ($em[$x][$y] + 1))
        {
            $poss += '' + ($x + 1 ) + 'x' + $y
        }
        if ($y -gt 0 -and $em[$x][$y - 1] -le $em[$x][$y] + 1)
        {
            $poss += '' + $x + 'x' + ($y - 1)
        }
        if ($y -lt ($em[0].count - 1) -and $em[$x][$y + 1] -le $em[$x][$y] + 1)
        {
            $poss += '' + $x + 'x' + ($y + 1)
        }
        $possibleSteps[$current] = $poss
    }
    return $possibleSteps[$current]
}
function Test-Arrived ($possible, $map)
{
    [int]$x, [int]$y = $possible -split 'x'
    return ($x -eq $map.ending.x -and $y -eq $map.ending.y)
}
function Find-Result2 ($sample)
{
    $map = Parse-Map $sample
    $results = foreach ($start in $map.otherStarting)
    {
        $map.starting = $start
        Find-Path $map
    }
    $results | Sort-Object | Select-Object -First 1
}

function Parse-Map ($sample)
{
    $hash = @{}
    $i = 1
    97..122 | ForEach-Object { $hash[[char]$_] = $i++ }
    $data = @{
        starting      = @{x = 0; y = 0 }
        ending        = @{x = 0; y = 0 }
        elevationmap  = @{}
        otherStarting = @()
    }
    for ($i = 0; $i -lt $sample.Count; $i++)
    {
        $data.elevationmap[$i] = @{}
        for ($j = 0; $j -lt $sample[$i].Length; $j++)
        {
            if ($sample[$i][$j] -match '[a-z]')
            { 
                $data.elevationmap[$i][$j] = $hash[$sample[$i][$j]]
                if ($matches[0] -eq 'a')
                {
                    $data.otherStarting += @{x = $i; y = $j }
                }
            }
            if ($sample[$i][$j] -ceq 'S')
            {
                $data.elevationmap[$i][$j] = $hash[[char]'a']
            
                $data.starting.x = $i
                $data.starting.y = $j
            }
            if ($sample[$i][$j] -ceq 'E')
            {
                $data.elevationmap[$i][$j] = $hash[[char]'z']
            
                $data.ending.x = $i
                $data.ending.y = $j
            }
        }
    }
    $data
}


'Sample result should be: 31'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: 29'
$possibleSteps = @{}
Find-Result2 $sample
Find-Result2 $data
