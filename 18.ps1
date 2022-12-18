. ./common.ps1
$data = gc .\18.input.txt

$sample = @"
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
"@ -split "`n"

function Find-Result ($sample) {
    $cubes = Parse-Input $sample
    $count = 0
    foreach ($cube in $cubes.GetEnumerator()) {
        $val = $cube.Value
        $val[0]++
        if (!$cubes.ContainsKey(($val -join ","))) {
            $count++
        }
        $val[0]--
        $val[0]--
        if (!$cubes.ContainsKey(($val -join ","))) {
            $count++
        }
        $val[0]++
        $val[1]++
        if (!$cubes.ContainsKey(($val -join ","))) {
            $count++
        }
        $val[1]--
        $val[1]--
        if (!$cubes.ContainsKey(($val -join ","))) {
            $count++
        }
        $val[1]++
        $val[2]++
        if (!$cubes.ContainsKey(($val -join ","))) {
            $count++
        }
        $val[2]--
        $val[2]--
        if (!$cubes.ContainsKey(($val -join ","))) {
            $count++
        }
        $val[2]++
    }
    $count
}

function Find-Result2 ($sample) {
    $cubes = Parse-Input $sample
    $count = 0
    $freeAir = New-HashSet
    $bubbles = New-HashSet
    Make-Sky $cubes $freeAir
    foreach ($cube in $cubes.GetEnumerator()) {
        $val = $cube.Value
        $val[0]++
        if (Test-HasFreeAir -FreeAir $freeAir -Cubes $cubes -Bubbles $bubbles -Cube $val) {
            $count++
        }
        $val[0]--
        $val[0]--
        if (Test-HasFreeAir -FreeAir $freeAir -Cubes $cubes -Bubbles $bubbles -Cube $val) {
            $count++
        }
        $val[0]++
        $val[1]++
        if (Test-HasFreeAir -FreeAir $freeAir -Cubes $cubes -Bubbles $bubbles -Cube $val) {
            $count++
        }
        $val[1]--
        $val[1]--
        if (Test-HasFreeAir -FreeAir $freeAir -Cubes $cubes -Bubbles $bubbles -Cube $val) {
            $count++
        }
        $val[1]++
        $val[2]++
        if (Test-HasFreeAir -FreeAir $freeAir -Cubes $cubes -Bubbles $bubbles -Cube $val) {
            $count++
        }
        $val[2]--
        $val[2]--
        if (Test-HasFreeAir -FreeAir $freeAir -Cubes $cubes -Bubbles $bubbles -Cube $val) {
            $count++
        }
        $val[2]++
    }
    $count
}


function Test-HasFreeAir ($freeair, $cubes, $bubbles, $cube) {
    if ($bubbles.Contains(($cube -join ",")) -or $cubes[($cube -join ",")]) {
        return $false
    }
    $potentials = @{($cube -join ",") = $cube }
    $visited = New-HashSet
    while ($potentials.Count) {
        $toCheck = @{}
        foreach ($cube in $potentials.GetEnumerator()) {
            $val = $cube.Value
            if ($cubes[($val -join ",")]) {
                continue
            }
            $null = $visited.Add(($val -join ","))

            if ($freeAir.Contains(($val -join ","))) {
                $null = $visited | % { $freeAir.add($_) }
                return $true
            }

            $val[0]++

            if (!$visited.Contains(($val -join ","))) {
                $toCheck[($val -join ",")] = $val.Clone()
            }

            $val[0]--
            $val[0]--
            if (!$visited.Contains(($val -join ","))) {
                $toCheck[($val -join ",")] = $val.Clone()
            }
            $val[0]++
            $val[1]++
            if (!$visited.Contains(($val -join ","))) {
                $toCheck[($val -join ",")] = $val.Clone()
            }
            $val[1]--
            $val[1]--
            if (!$visited.Contains(($val -join ","))) {
                $toCheck[($val -join ",")] = $val.Clone()
            }
            $val[1]++
            $val[2]++
            if (!$visited.Contains(($val -join ","))) {
                $toCheck[($val -join ",")] = $val.Clone()
            }
            $val[2]--
            $val[2]--
            if (!$visited.Contains(($val -join ","))) {
                $toCheck[($val -join ",")] = $val.Clone()
            }
            $val[2]++
        
        }
        $potentials = $toCheck
    }
    $null = $visited | % { $bubbles.add($_) }
    return $false
}

function Make-Sky ($cubes, $freeAir) {
    $values = $cubes.Values
    $maxX, $minX = $values | % { $_[0] } | Measure-Object -Maximum -Minimum | % { ($_.maximum + 1), ($_.Minimum - 1) }
    $maxY, $minY = $values | % { $_[1] } | Measure-Object -Maximum -Minimum | % { ($_.maximum + 1), ($_.Minimum - 1) }
    $maxZ, $minZ = $values | % { $_[2] } | Measure-Object -Maximum -Minimum | % { ($_.maximum + 1), ($_.Minimum - 1) }
    for ($x = $minX; $x -lt $maxX; $x++) {
        for ($y = $minY; $y -lt $maxY; $y++) {
            $null = $freeAir.Add("$x,$y,$maxZ")
            $null = $freeAir.Add("$x,$y,$minZ")
        }
    }
    for ($x = $minX; $x -lt $maxX; $x++) {
        for ($z = $minZ; $z -lt $maxZ; $z++) {
            $null = $freeAir.Add("$x,$maxY,$z")
            $null = $freeAir.Add("$x,$minY,$z")
        }
    }
    for ($z = $minZ; $z -lt $maxZ; $z++) {
        for ($y = $minY; $y -lt $maxY; $y++) {
            $null = $freeAir.Add("$maxX,$y,$z")
            $null = $freeAir.Add("$minX,$y,$z")
        }
    }
}

function Parse-Input ($sample) {
    $table = @{}
    foreach ($line in $sample) {
        $line = $line -replace "`r|`n"
        $table[$line] = [int[]]($line -split ",")
    }
    $table
}


"Sample result should be: "
#Find-Result $sample

#Find-Result $data

"Second part, sample result should be: "
Find-Result2 $sample

Find-Result2 $data
