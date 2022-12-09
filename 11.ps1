. ./common.ps1
$data = gc .\11.input.txt

$sample = @"

"@ -split "`n"

function Find-Result ($sample) {

}

function Find-Result2 ($sample) {

}




"Sample result should be: "
Find-Result $sample

Find-Result $data

"Second part, sample result should be: "
Find-Result2 $sample

Find-Result2 $data
