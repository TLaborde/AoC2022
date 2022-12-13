using namespace System.Text.Json.Nodes
. ./common.ps1
$data = Get-Content .\13.input.txt

$sample = @'
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
'@ -split "`n"

function Find-Result ($sample) {
    $sum = 0
    for ($i = 0; $i -lt $sample.Count; $i = $i + 3) {
        if ((Compare-Signal $sample[$i] $sample[$i + 1]) -lt 0) {
            $sum += ($i / 3) + 1
        }
    }
    $sum
}

function Find-Result2 ($sample) {
    $sample = $sample + @("[[2]]", "[[6]]") | ? { $_.length -gt 1 }
    $list = New-Object -TypeName "System.Collections.Generic.List[JsonNode]"
    $sample | % {
        $list.Add([JsonNode]::Parse($_))
    }
    $list.Sort([AOC.Solution]::Compare)
    $sample = $list | % { $_.tojsonstring() }
    ($sample.IndexOf("[[2]]") + 1) * ($sample.IndexOf("[[6]]") + 1)
}

function Compare-Signal ($left, $right) {
    [AOC.Solution]::Compare([JsonNode]::Parse($left), [JsonNode]::Parse($right))
}

$SourceCode = @"
using System;
using System.Linq;
using System.Collections.Generic;
using System.Text.Json.Nodes;

namespace AOC;
public class Solution {

    public static int Compare(JsonNode nodeA, JsonNode nodeB) {
        if (nodeA is JsonValue && nodeB is JsonValue) {
            return (int)nodeA - (int)nodeB;
        } else {
            var arrayA = nodeA as JsonArray ?? new JsonArray((int)nodeA);
            var arrayB = nodeB as JsonArray ?? new JsonArray((int)nodeB);
            return Enumerable.Zip(arrayA, arrayB)
                .Select(p => Compare(p.First, p.Second))
                .FirstOrDefault(c => c != 0, arrayA.Count - arrayB.Count);
        }
    }
}
"@
Add-Type -ReferencedAssemblies $Assembly -TypeDefinition $SourceCode -Language CSharp


'Sample result should be: 13'
Find-Result $sample



Find-Result $data
"The result for solution 1 is: 5843"
'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
"The result for solution 2 is: 26289"