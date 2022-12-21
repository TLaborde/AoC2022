. ./common.ps1
$data = Get-Content .\21.input.txt

$sample = @'
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
'@ -split "`n"

function Find-Result ($sample)
{
    $monkeys = Parse-Input $sample
    Solve-Value $monkeys 'root'
}

function Find-Result2 ($sample)
{
    $monkeys = Parse-Input $sample
    $monkeys['humn'].result = 'x'
    $leftSide = Solve-Value $monkeys $monkeys['root'].left
    $rightSide = Solve-Value $monkeys $monkeys['root'].right
    Simplify-Equation $leftSide $rightSide

}

function Simplify-Equation ($leftSide, [int64]$rightSide)
{
    while ($leftSide -ne 'x')
    {
        if ($leftSide -match '^\(([x0-9\(\) \*\+\-/]+) ([\*\+\-/]) ([0-9]+)\)$')
        {
            switch ($Matches[2])
            {
                '+' { $rightSide -= [int64]$Matches[3] }
                '*' { $rightSide /= [int64]$Matches[3] }
                '/' { $rightSide *= [int64]$Matches[3] }
                '-' { $rightSide += [int64]$Matches[3] }
            }
            $leftSide = $Matches[1]
        }
        elseif ($leftSide -match '^\(([0-9]+) ([\*\+\-/]) ([x0-9\(\) \*\+\-/]+)\)$')
        {
            switch ($Matches[2])
            {
                '+' { $rightSide -= [int64]$Matches[1] }
                '*' { $rightSide /= [int64]$Matches[1] }
                '/' { $rightSide = [int64]$Matches[1] / $rightSide }
                '-' { $rightSide = - ($rightSide - [int64]$Matches[1]) }
            }
            $leftSide = $Matches[3]
        }
    }
    "$leftSide=$rightSide"
}

function Solve-Value ($monkeys, $monkey)
{
    if (!$monkeys[$monkey].result)
    {
        $left = Solve-Value $monkeys $monkeys[$monkey].left
        $right = Solve-Value $monkeys $monkeys[$monkey].right
        $res = "($left $($monkeys[$monkey].operation) $right)"
        if ($res -match 'x')
        {
            $monkeys[$monkey].result = $res
        }
        else
        {
            $monkeys[$monkey].result = $res  | Invoke-Expression
        }
    }
    return $monkeys[$monkey].result
}

function Parse-Input ($sample)
{
    $monkeys = @{ }
    foreach ($line in $sample)
    {
        $name, $op = $line -split ': '
        if ($op -as [int64])
        {
            $monkeys[$name] = @{
                result = [int64]$op
            }
        }
        else
        {
            $exp = $op -split ' ' -replace "`r|`n"
            $monkeys[$name] = @{
                result    = $false
                right     = $exp[2]
                left      = $exp[0]
                operation = $exp[1]
            }
        }
    }
    $monkeys
}

'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
