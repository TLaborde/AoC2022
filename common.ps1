function Split-Half ($s)
{
    $s.substring(0, $s.Length / 2)
    $s.Substring($s.Length / 2)
}

function Get-Intersect ($begin1, $end1, $begin2, $end2)
{
    # this is an overkill, we should just do math with boundaries
    # but it's to remember the syntax for another day
    # also can be done without enumerable https://www.red-gate.com/simple-talk/development/dotnet-development/high-performance-powershell-linq/#post-71022-_Toc482783754
    [Linq.Enumerable]::Intersect(([int[]]@($begin1..$end1)), ([int[]]@($begin2..$end2)))
}

function Test-Inclusion ($begin1, $end1, $begin2, $end2)
{
    $r1 = [int[]]@($begin1..$end1)
    $r2 = [int[]]@($begin2..$end2)
    $inter = @([int[]][Linq.Enumerable]::Intersect($r1, $r2))
    [bool]($null -eq (Compare-Object -Reference $r1 -Difference $inter)) -or [bool]($null -eq (Compare-Object -Reference $r2 -Difference $inter))
}