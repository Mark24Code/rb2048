# Rb2048

Ruby 2048 Game


## Install

`gem install rb2048`

## Help

```
Usage: rb2048 [options]
        --version                    verison
        --size SIZE                  Size of board: 4-10
        --level LEVEL                Hard Level 2-5
```
## Game Screen

```

           -- Ruby 2048 --

 -------------------------------------
 |    16  |    16  |     2  |    16  |
 -------------------------------------
 |     0  |     0  |     0  |     0  |
 -------------------------------------
 |     0  |     0  |     0  |     2  |
 -------------------------------------
 |     0  |     0  |     0  |     0  |
 -------------------------------------

 Score: 16              You:UP



 Control: W(↑) A(←) S(↓) D(→) Q(quit) R(Restart)
```

## Game Model Lightspot

Not just a main thread to create TUI Game.

This is a experiment for just testing Ruby3 Thread & Queue.

I build this game that UserI/O, Data Computing, TUI Render use 3 different threads & message channel to work together.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Mark24Code/rb2048.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
