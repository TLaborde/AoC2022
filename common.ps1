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

function New-HashSet ($Type = 'string', $Content)
{
    return New-Object System.Collections.Generic.HashSet[$Type] $content
}

function Sort-UsingQuickSort
{
    # quicksort in place with custom comparer
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')] 
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Justification = 'False positive, get-partition is not implictly called. partition is a internal function')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)]$InputObject,
        [parameter(Mandatory)][string]$Comparator
    )

    BEGIN
    {
        $Unsorted = [collections.arraylist]::New()
    }

    PROCESS
    {
        $InputObject | ForEach-Object {
            $null = $Unsorted.Add($PSItem)
        }
    }

    END
    {
        function quicksort ($array, $low, $high)
        {
            if ($low -lt $high)
            {
                $p = partition -array $array -low $low -high $high
                quicksort -array $array -low $low -high ($p - 1)
                quicksort -array $array -low ($P + 1) -high $high
            }
        }
        function cmp ($a, $b)
        {
            "$Comparator `$a `$b" | iex
        }
        function partition
        {
            param(
                $array,
                $low,
                $high
            )
            $pivot = $array[$high]
            $i = $low
            for ($j = $low; $j -le $high; $j++)
            {
                if ((cmp $array[$j] $pivot) -lt 0)
                {
                    swap -array $array -position $i -with $j
                    $i = $i + 1
                }
            }
            swap -array $array -position $i -with $high
            return $i
        }
        function swap($array, $pos1, $pos2)
        {
            $array[$pos1], $array[$pos2] = $array[$pos2], $array[$pos1]
        }

        quicksort -array $Unsorted -low 0 -high ($Unsorted.count - 1)
        return $Unsorted
    }

}