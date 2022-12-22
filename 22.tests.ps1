. ./22.ps1

Describe "A suite" {
    It "top to back and back to top" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(0, 51)
            direction = 3
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(151, 0)
        $me.direction | Should -Be 0

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(0, 51)
    }
    It "right to back and back to right" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(0, 111)
            direction = 3
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(199, 11)
        $me.direction | Should -Be 3

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(0, 111)
        $me.direction | Should -Be 1
    }
    It "right to bottom and bottom to right" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(1, 149)
            direction = 0
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(148, 99)
        $me.direction | Should -Be 2

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(1, 149)
        $me.direction | Should -Be 2
    }
    It "right to front and front to right" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(49, 100)
            direction = 1
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(50, 99)
        $me.direction | Should -Be 2

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(49, 100)
        $me.direction | Should -Be 3
    }
    It "bottom to back and back to bottom" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(149, 50)
            direction = 1
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(150, 49)
        $me.direction | Should -Be 2

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(149, 50)
        $me.direction | Should -Be 3
    }

    It "left to top and top to left" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(100, 0)
            direction = 2
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(49, 50)
        $me.direction | Should -Be 0

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(100, 0)
        $me.direction | Should -Be 0

        $me = @{
            position  = @(149, 0)
            direction = 2
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(0, 50)
        $me.direction | Should -Be 0

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(149, 0)
        $me.direction | Should -Be 0
    }
    It "left to front and front to left" {
        $code, $map = Parse-Input $data
        $me = @{
            position  = @(100, 0)
            direction = 3
        }
        Move-MeCube $me 1 $map
        $me.position | Should -Be @(50, 50)
        $me.direction | Should -Be 0

        $me.direction = ($me.direction + 2 ) % 4

        Move-MeCube $me 1 $map
        $me.position | Should -Be @(100, 0)
        $me.direction | Should -Be 1
    }
}