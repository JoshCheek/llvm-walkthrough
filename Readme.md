Implementing a language for LLVM
=================================

Going through [this](http://llvm.org/docs/tutorial/LangImpl1.html)
tutorial to learn about LLVM by building a language, "Kaleidoscope"
on top of it.

Here is an example of the fibonacci sequence in Kaleidoscope:

```ruby
# Compute the x'th fibonacci number.
def fib(x)
  if x < 3 then
    1
  else
    fib(x-1)+fib(x-2)

# This expression will compute the 40th number.
fib(40)
```
