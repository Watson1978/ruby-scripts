#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-

def main(n = 0)
  return fib(n.to_i)
end

def fib(n)
  return 0 if(n == 0)
  return 1 if(n == 1)
  return fib(n - 1) + fib(n - 2)
end

