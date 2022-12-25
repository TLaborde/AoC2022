. ./common.ps1
$data = (gc .\25.input.txt) -replace "`r"

$sample = @"
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
"@ -replace "`r" -split "`n"

function Find-Result ($sample) {
    $decimal = 0
    foreach ($snafu in $sample) {
        $decimal += Convert-SNAFUToDecimal $snafu
    }
    Convert-DecimalToSnafu $decimal
}

# We don't do it clever, we bruteforce it
function Convert-DecimalToSnafu ($decimal) {
    $guessUnder = "1"
    $guessOver = "2"

    do {
        $guessUnder += "="
        $guessOver += "2"
        $decGuessUnder = Convert-SNAFUToDecimal $guessUnder
        $decGuessOver = Convert-SNAFUToDecimal $guessOver
    } while ($decGuessOver -lt $decimal)

    for ($i = 1; $i -lt $guessOver.Length; $i++) {
        $guesses = @(
            $guessUnder
            $guessUnder.remove($i, 1).Insert($i, "-")
            $guessUnder.remove($i, 1).Insert($i, "0")
            $guessUnder.remove($i, 1).Insert($i, "1")
            $guessUnder.remove($i, 1).Insert($i, "2")
            $guessOver.remove($i, 1).Insert($i, "=") 
            $guessOver.remove($i, 1).Insert($i, "-")
            $guessOver.remove($i, 1).Insert($i, "0")
            $guessOver.remove($i, 1).Insert($i, "1")
            $guessOver
        )
        foreach ($g in $guesses) {
            $decG = Convert-SNAFUToDecimal $g
            if ($decG -gt $decGuessUnder -and $decG -le $decimal) {
                $decGuessUnder = $decG
                $guessUnder = $g
            }
            if ($decG -lt $decGuessOver -and $decG -ge $decimal) {
                $decGuessOver = $decG
                $guessOver = $g
            }
        }

    }
    $guessOver
}

function Convert-SNAFUToDecimal ($snafu) {
    $power = 1
    $decimal = 0
    $translate = @{
        [char]"2" = 2
        [char]"1" = 1
        [char]"0" = 0
        [char]"-" = -1
        [char]"=" = -2
    }
    for ($i = ($snafu.Length - 1); $i -ge 0; $i--) {
        if ($translate.ContainsKey($snafu[$i])) {
            $decimal += $translate[$snafu[$i]] * $power
            $power *= 5 
        }
    }
    $decimal
}


function Find-Result2 ($sample) {

}




"Sample result should be: 2=-1=0"
Find-Result $sample

Find-Result $data
