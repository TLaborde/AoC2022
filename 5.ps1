. ./common.ps1
$data = Get-Content .\5.input.txt

$sample = @'
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
'@ -split "`n"

function Find-Result ($sample, [bool]$reverse = $false)
{
    $stacks = Parse-Stack $sample
    $steps = parse-Steps $sample
    foreach ($step in $steps)
    {
        $vals = @((1..$step.times) | ForEach-Object { $stacks[$step.from].pop() })
        if ($reverse)
        {
            [array]::Reverse($vals)
        }
        $vals | ForEach-Object { $stacks[$step.to].push($_) }
    }
    $out += for ($i = 1; $i -le $stacks.Count; $i++)
    {
        $stacks["$i"].Pop()
    }
    $out -join ''
}

function Find-Result2 ($sample)
{    
    Find-Result $sample $true
}

function Parse-Stack ($sample)
{
    $stackInput = $sample | Where-Object { $_ -match '\[' }
    [array]::Reverse($stackInput)
    $stacks = @{}
    for ($i = 0; $i -lt ($stackInput[0].Length / 4); $i++)
    {
        $stack = New-Object System.Collections.Generic.Stack[String]
        $stackInput | ForEach-Object { 
            $val = ([char[]]$_)[$i * 4 + 1]
            if ($val -match '[a-zA-Z]')
            {
                $stack.push($val)
            }
        }
        $stacks[[string]($i + 1)] = $stack
    }
    $stacks
}

function parse-Steps ($sample)
{
    $stepsInput = $sample | Where-Object { $_ -match 'move' }
    $steps = @()
    foreach ($step in $stepsInput)
    {
        [void]($step -match 'move ([0-9]+) from ([0-9]+) to ([0-9]+)')

        $steps += @{
            from  = $matches[2]
            to    = $matches[3]
            times = $matches[1]
        }
    }
    $steps
}


'Sample result should be: '
Find-Result $sample

'first answer is: '
Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
