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
    for ($i = 0; $i -lt $list.Count; $i++)
    {
        $node = $list.Where({ $_.index -eq $i })[0]
        $swap = $node
        if ($node.content -eq 0)
        {
            continue
        }

        #remove the node
        $node.previous.next = $node.next
        $node.next.previous = $node.previous
        $moves = $node.content % ($list.count - 1)
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
        
        # move head before removing node
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
    #let make a ghetto circular double linked list
    $i = 0
    $list = @()
    $list = foreach ($item in $sample)
    {
        @{
            next     = 0
            previous = 0
            index    = $i++
            content  = [int]$item
            head     = $false
        }
    }
    for ($i = 1; $i -lt $list.Count - 1; $i++)
    {
        $list[$i].next = $list[$i + 1]
        $list[$i].previous = $list[$i - 1]
    }
    $list[0].head = $true
    $list[0].next = $list[1]
    $list[0].previous = $list[$list.Count - 1]
    $list[$list.Count - 1].next = $list[0]
    $list[$list.Count - 1].previous = $list[$list.Count - 2]
    $list
}



'Sample result should be: '
Find-Result $sample

Find-Result $data

'Second part, sample result should be: '
#Find-Result2 $sample

#Find-Result2 $data
