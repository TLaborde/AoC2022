. ./common.ps1
$data = Get-Content .\15.input.txt

$sample = @'
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
'@ -split "`n"

function Find-Result ($sample, $y = 10)
{
    $mapData = Parse-BeaconSignal $sample
    $y, $beacons, $ranges = Get-YCoverage $y $mapData
    $y - $beacons
}

function Find-Result2 ($sample, $maxSize)
{
    $mapData = Parse-BeaconSignal $sample
    #brute force version, bit slow
    #for ($y = 0; $y -lt $mergeRangeLimit.maxX; $y++)
    #{
    #    $pos, $beacons, $ranges = Get-YCoverage $y $mapData $mergeRangeLimit
    #    if ($pos -ne ($mergeRangeLimit.maxX + 1) )
    #    {
    #     ($ranges[0].end + 1) * 4000000 + $y
    #        break
    #    }
    #}
    # bit cleverer, the solution has to be just outside of the range of the diamond
    Get-Suspects $mapData $maxSize
}

function Get-Suspects ($mapData, $maxSize = 20)
{
    $mapData = $mapData | Sort-Object -Property distance

    foreach ($dataPoint in $mapData)
    {
        $verticalSpan = ($dataPoint.SensorY - $dataPoint.Distance - 1)..($dataPoint.SensorY + $dataPoint.Distance + 1)
        foreach ($y in $verticalSpan)
        {
            if ($y -lt $maxSize + 1 -and $y -ge 0)
            {
                $lat = $dataPoint.Distance + 1 - [math]::abs($y - $dataPoint.SensorY)
                $x = $dataPoint.SensorX - $lat
                if ($x -ge 0 -and $x -lt ($maxSize + 1))
                {
                    if (!(Test-ISCovered $x $y $mapData))
                    {
                        "found it $x $y, $([int]$x*4000000+$y)"
                        return
                    }
                }
                $x = $dataPoint.SensorX + $lat
                if ($x -ge 0 -and $x -lt ($maxSize + 1))
                {
                    
                    if (!(Test-ISCovered $x $y $mapData))
                    {
                        "found it $x $y, $([int]$x*4000000+$y)"
                        return
                    }
                }
            }
        }
    }
}

function Get-YCoverage ($y, $mapData, $mergeRangeLimit = $false)
{
    $ranges = foreach ($dataPoint in $mapData)
    {
        $verticalDistanceToSensor = $dataPoint.Distance - [math]::abs($y - $dataPoint.SensorY)
        if ($verticalDistanceToSensor -gt 0)
        {
            @{
                begin = $dataPoint.SensorX - $verticalDistanceToSensor
                end   = $dataPoint.SensorX + $verticalDistanceToSensor
            }
        }
    }
    do
    {
        $count = @($ranges).Count
        $ranges = Merge-Range $ranges $mergeRangeLimit
    } while ( 
        @($ranges).count -ne $count -and 1 -ne @($ranges).count)
    $i = 0
    foreach ($noolr in $ranges)
    {
        $i += $noolr.end - $noolr.begin + 1
    }
    $beacons = @($mapData | Where-Object { $_.beaconY -eq $y } | Sort-Object -Unique).Count
    $i, $beacons, $ranges
}
function Merge-Range ($ranges, $mergeRangeLimit)
{
    $ranges = $ranges | Sort-Object -Property begin
    if ($mergeRangeLimit)
    {
        $ranges = $ranges.Where({ $_.end -gt $mergeRangeLimit.minX -or $_.begin -lt $mergeRangeLimit.maxX })
        foreach ($range in $ranges)
        {
            if ($range.begin -lt $mergeRangeLimit.minX)
            {
                $range.begin = $mergeRangeLimit.minX
            }
            if ($range.end -gt $mergeRangeLimit.maxX)
            {
                $range.end = $mergeRangeLimit.maxX
            }
        }
    }
    $noOverLapRanges = @($ranges[0])
    for ($i = 1; $i -lt $ranges.Count; $i++)
    {
        $last = $noOverLapRanges[$noOverLapRanges.count - 1]
        if ($last.end -lt $ranges[$i].begin)
        {
            $noOverLapRanges += $ranges[$i]
        }
        elseif ($last.end -le $ranges[$i].end)
        {
            $last.end = $ranges[$i].end
        }
    }
    $noOverLapRanges
}

function Test-ISCovered ($x, $y, $mapData)
{
    foreach ($dataPoint in $mapData)
    {
        $distanceToSensor = [math]::abs($x - $dataPoint.SensorX) + [math]::abs($y - $dataPoint.SensorY)
        if ($distanceToSensor -le $dataPoint.Distance)
        {
            return $true
        }
    }
    return $false
}

function Parse-BeaconSignal ($sample)
{
    foreach ($line in $sample)
    {
        if ($line -match 'Sensor at x=([0-9-]+), y=([0-9-]+): closest beacon is at x=([0-9-]+), y=([0-9-]+)')
        {
            @{
                SensorX  = [int]$Matches[1]
                SensorY  = [int]$Matches[2]
                BeaconX  = [int]$Matches[3]
                BeaconY  = [int]$Matches[4]
                Distance = [math]::abs([int]$Matches[1] - [int]$Matches[3]) + [math]::abs([int]$Matches[2] - [int]$Matches[4])
            }
        }
        else
        {
            Write-Error 'parse-error'
        }
    }
}

'Sample result should be: '
Find-Result $sample
$y = 2000000
Find-Result $data -y $y 

'Second part, sample result should be: '
Find-Result2 $sample -maxSize 20 

Find-Result2 $data -maxSize  4000000
