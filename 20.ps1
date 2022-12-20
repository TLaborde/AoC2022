. ./common.ps1
$data = Get-Content .\20.input.txt

$sample = @'
1
2
-3
3
-2
0
4
'@ -split "`n"

function Find-Result ($sample)
{
    $list = Parse-Input $sample
    $list = Mix-List $list
    #show list
    $node = $list.Where({ $_.content -eq 0 })[0] # get the head
    $sum = 0
    for ($i = 0; $i -lt 3001; $i++)
    {
        if ($i % 1000 -eq 0)
        {
            $sum += $node.content
        }
        $node = $node.next
    }
    $sum
}

function Find-Result2 ($sample)
{
    $list = Parse-Input $sample
    $list | ForEach-Object { $_.content *= 811589153 }
    1..10 | ForEach-Object { $list = Mix-List $list }
    
    #show list
    $node = $list.Where({ $_.content -eq 0 })[0] # get the head

    $sum = 0
    for ($i = 0; $i -lt 3001; $i++)
    {
        if ($i % 1000 -eq 0)
        {
            $sum += $node.content
        }
        $node = $node.next
    }
    $sum
}

function Mix-List ($list)
{
    $modulo = $list.count - 1
    for ($i = 0; $i -lt $list.Count; $i++)
    {
        $node = $list[$i]
        $swap = $node
        if ($node.content -eq 0)
        {
            continue
        }

        #remove the node
        $node.previous.next = $node.next
        $node.next.previous = $node.previous

        $moves = $node.content % $modulo
        # we could simplify by having moves always positive but eh
        # that would allow for having simple linked list tho
        if ($moves -gt 0)
        {
            for ($j = 0; $j -lt $moves; $j++)
            {
                $swap = $swap.next
            }
        }
        else
        {
            $swap = $swap.previous
            for ($j = 0; $j -lt - $moves; $j++)
            {
                $swap = $swap.previous
            }
        }
        
        # move head if needed
        # a node cannot be moved to head using the puzzle logic
        if ($node.head)
        {
            $node.next.head = $true
            $node.head = $false
        }
        #add node after swap
        $swap.next.previous = $node
        $node.next = $swap.next
        $node.previous = $swap
        $swap.next = $node
    }
    $list
}
function Parse-Input ($sample)
{
    # let make a ghetto circular double linked list
    # We store it in an array, so we can index it for the main loop
    # create array of "nodes" as hashtable with ref to previous and next
    # hed should be something external, but whatever
    $list = @()
    $list = foreach ($item in $sample)
    {
        @{
            next     = $null
            previous = $null
            content  = [int]$item
            head     = $false
        }
    }
    # fill previous/next for all node
    for ($i = 0; $i -lt $list.Count; $i++)
    {
        $list[$i].next = $list[($i + 1) % $list.Count]
        $list[$i].previous = $list[$i - 1]
    }
    $list[0].head = $true
    $list
}



'Sample result should be: 3'
Find-Result $sample

Find-Result $data

'Second part, sample result should be: 1623178306'
Find-Result2 $sample

Find-Result2 $data
