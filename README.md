FixedSizeBuffer
==================

[![Gem Version](https://badge.fury.io/rb/fixed_size_buffer.svg)](https://badge.fury.io/rb/fixed_size_buffer)
[![CI](https://github.com/justinhoward/fixed_size_buffer/workflows/CI/badge.svg)](https://github.com/justinhoward/fixed_size_buffer/actions?query=workflow%3ACI+branch%3Amaster)
[![Code Quality](https://app.codacy.com/project/badge/Grade/e647db61b5064a6e97fc20ffe7f0430e)](https://www.codacy.com/gh/justinhoward/fixed_size_buffer/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=justinhoward/fixed_size_buffer&amp;utm_campaign=Badge_Grade)
[![Code Coverage](https://app.codacy.com/project/badge/Coverage/e647db61b5064a6e97fc20ffe7f0430e)](https://www.codacy.com/gh/justinhoward/fixed_size_buffer/dashboard?utm_source=github.com&utm_medium=referral&utm_content=justinhoward/fixed_size_buffer&utm_campaign=Badge_Coverage)
[![Inline docs](http://inch-ci.org/github/justinhoward/fixed_size_buffer.svg?branch=master)](http://inch-ci.org/github/justinhoward/fixed_size_buffer)

A ring buffer with a fixed capacity

```ruby
buffer = FixedSizeBuffer.new(3)
buffer.write(1)
buffer.write(2)
buffer.to_a # [1, 2]
buffer.read # => 1
buffer.read # => 2
```

What is a Ring Buffer?
------------------------

A ring buffer is a continuously writable and continuously readable data
structure that is contained in a fixed amount of memory. It can be
conceptualized as writing values around a circular array. As we write, we move
clockwise around the circle, and the reader trails around in the same direction.

The advantages of a ring buffer as opposed to pushing and shifting an array is
that a ring buffer only can be heap allocated once, and since it's a fixed size,
it never needs to be reallocated.

Installation
---------------

Add it to your `Gemfile`:

```ruby
gem 'fixed_size_buffer'
```

Or install it manually:

```sh
gem install fixed_size_buffer
```

API Documentation
--------------

API docs can be read [on rubydoc.info][api docs], inline in the source code, or
you can generate them yourself with Ruby `yard`:

```sh
bin/yardoc
```

Then open `doc/index.html` in your browser.

Usage
-----------

Create a new ring buffer with a given capacity

```ruby
buffer = FixedSizeBuffer.new(100)
```

Then write and read from the buffer

```ruby
buffer = FixedSizeBuffer.new(2)
buffer.empty? # => true
buffer.size # => 0
buffer.write('hello')
buffer.write('world')
buffer.size # => 2
buffer.full? # => true
buffer.to_a # => ['hello', 'world']
buffer.peek # => 'hello'
buffer.read # => 'hello'
buffer.read # => 'world'
buffer.read # => nil
```

Once the buffer fills up, it will overwrite the oldest values.

```ruby
buffer = FixedSizeBuffer.new(2)
buffer.write('hello')
buffer.write('world')
buffer.write('again')
buffer.read # => 'world'
```

[api docs]: https://www.rubydoc.info/github/justinhoward/fixed_size_buffer/master
