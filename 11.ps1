. ./common.ps1
$data = gc .\11.input.txt

$sample = @"
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
"@ -split "`n"



function Find-Result ($sample) {
    Find-Result2 -sample $sample -round 20 -worryDivider 3
}


function Find-Result2 ($sample, $round = 10000, $worryDivider = 1) {
    $monkeys = Parse-MonkeyInput $sample
    $divid = 1
    $monkeys.testdiv | % { $divid *= $_ }
    for ($i = 0; $i -lt $round; $i++) {
        for ($j = 0; $j -lt $monkeys.Count; $j++) {
            for ($item = 0; $item -lt $monkeys[$j].items.count; $item++) {
                $monkeys[$j].inspections++
                if ($monkeys[$j].operation[1] -eq "+") {
                    $worry = $monkeys[$j].items[$item] + $monkeys[$j].operation[2]
                }
                elseif ($monkeys[$j].operation[2] -eq "old") {
                    $worry = $monkeys[$j].items[$item] * $monkeys[$j].items[$item]
                }
                else {
                    $worry = $monkeys[$j].items[$item] * $monkeys[$j].operation[2]
                }
                $worry = $worry % $divid
                if ($worryDivider -ne 1) { 
                    $worry = [math]::Floor($worry / $worryDivider) 
                }
                if (!($worry % $monkeys[$j].testdiv)) {
                    $monkeys[$monkeys[$j].iftrue].items += $worry
                }
                else {
                    $monkeys[$monkeys[$j].iffalse].items += $worry
                }
            }
            $monkeys[$j].items = @()
        }
    }
    $insp = $monkeys.inspections | Sort-Object -Descending
    $insp[0] * $insp[1]
}

function Parse-MonkeyInput ($sample) {
    for ($i = 0; $i -lt $sample.Count; $i = $i + 7) {
        [pscustomobject]@{
            items       = @(($sample[$i + 1] -replace "`r" -split ": ")[1] -split ", " | % { [int]$_ })
            operation   = $sample[$i + 2] -replace "  Operation: new = " -replace "`r" -split " "
            testdiv     = [int]($sample[$i + 3] -replace "Test: divisible by ")
            iftrue      = [int]($sample[$i + 4] -replace "    If true: throw to monkey ")
            iffalse     = [int]($sample[$i + 5] -replace "    If false: throw to monkey ")
            inspections = [long]0
        }
    }
}



"Sample result should be: 10605"
Find-Result $sample

Find-Result $data

"Second part, sample result should be: 2713310158"
Find-Result2 $sample

Find-Result2 $data
