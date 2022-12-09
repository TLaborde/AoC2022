. ./common.ps1
$data = Get-Content .\7.input.txt

$sample = @'
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
'@ -split "`n"

function Find-Result ($sample)
{ 
    $tree = Make-Tree $sample 
    $sums = Sum-Tree $tree
    $sums | Where-Object { $_ -lt 100000 } | Measure-Object -Sum | ForEach-Object sum
}

function Find-Result2 ($sample)
{
    $tree = Make-Tree $sample 
    $sums = Sum-Tree $tree
    # the total amount of used space) is 48381165; this means that the size of the unused space must currently be 21618835, which isn't quite the 30000000
    $free = 70000000 - $sums[0]
    $tofree = 30000000 - $free
    $sums | Where-Object { $_ -gt $tofree } | Sort-Object | Select-Object -first 1

}

function Make-Tree ($sample)
{
    $currentLevel = New-Object System.Collections.Generic.Stack[String]
    $tree = @{}
    foreach ($l in $sample)
    {
        if ($l -match '\$ cd ([a-z\./]*)')
        {
            if ($Matches[1] -match '\.\.')
            {
                $null = $currentLevel.Pop()
                $currentBranch = $tree
                for ($i = $currentLevel.Count - 1; $i -ge 0; $i--)
                {
                    $currentBranch = $currentBranch[@($currentLevel)[$i]]
                }
            }
            elseif (($Matches[1] -match '/'))
            {
                $currentLevel = New-Object System.Collections.Generic.Stack[String]
                $currentBranch = $tree
            }
            else
            {
                $currentLevel.Push($Matches[1])
                $currentBranch = $currentBranch[$Matches[1]]
            }
        }
        if ($l -match 'dir ([a-z]+)')
        {
            $currentBranch[$matches[1]] = @{}
        }
        if ($l -match '([0-9]+) ([a-z\.]+)')
        {
            $currentBranch[$matches[2]] = [int]$matches[1]
        }
    }
    $tree
}

function Sum-Tree ($tree)
{
    File-Size $tree
    $tree.GetEnumerator() | Where-Object { $_.value -is [hashtable] } | ForEach-Object {
        Sum-Tree $_.value
    }
}
function File-Size ($tree)
{
    $filesize = 0
    $filesize += @($tree.values | Where-Object { $_ -is [int] }) | Measure-Object -Sum | ForEach-Object Sum
    $tree.GetEnumerator() | Where-Object { $_.value -is [hashtable] } | ForEach-Object {
        $filesize += file-size $_.value
    }
    $filesize
}

'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
Find-Result2 $sample

Find-Result2 $data
