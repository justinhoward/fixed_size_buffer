# frozen_string_literal: true

require 'fixed_size_buffer/version'

# A ring buffer with a fixed capacity
#
# Principal of Operation
# ========================
# A ring buffer is a continuously writable and continuously readable
# data structure that is contained in a fixed amount of memory. It can be
# conceptualized as writing values around a circular array. As we write,
# we move clockwise around the circle, and reading trails around in the
# same direction.
#
# If the reader catches up to the writer, the buffer is empty. If the writer
# wraps around and catches up to the reader, the buffer is full. In our case,
# we allow the writer to continue writing to a full buffer, which causes
# the oldest values to be dropped.
#
# Implementation
# =======================
# This ring buffer is implemented as a fixed-size array. We also maintain
# a read index and a write index. These are the positions where the next read
# or write will occur. We increase the write pointer by one each time we write
# to the buffer. We also increase the read pointer by one every time we read.
#
# The buffer is considered empty if the read and write pointers are in the
# same position. In this state, reading will not move the read pointer, and
# `nil` will be returned.
#
# An empty buffer of capacity 3.
# ```text
#        rw
# |  |  |  |  |
# ```
#
# The buffer is considered full if the write pointer is in the position
# immediately before the read pointer. In this state, writing will overwrite
# the next position, which will be the oldest value in the buffer. Writing
# in this state will also move the read pointer forward so that the next
# read will continue from the next-oldest value.
#
# A full buffer of capacity 3. Note that the 2 here is already considered
# overwritten.
# ```text
#       w   r
# | 5 | 2 | 3 | 4 |
# ```
#
# Another full buffer with the same values but in a wrapped-around position.
# ```text
#   r           w
# | 3 | 4 | 5 | 2 |
# ```
#
# Notice that the array for this buffer has one extra position. This is used to
# differentiate between an empty buffer (read/write pointers in same position),
# and a full buffer (write pointer just before read pointer). The value
# in-between the read and write pointers for a full buffer will not be read.
class FixedSizeBuffer
  # The capacity given to {.new}
  attr_reader :capacity

  # Create a new empty {FixedSizeBuffer}
  #
  # Start state
  #
  # ```text
  #  rw
  # |  |  |  |  |
  # ```
  #
  # @param capacity [Integer] The number of items this buffer can hold
  def initialize(capacity)
    @capacity = capacity
    @buffer = Array.new(capacity + 1)
    @read = 0
    @write = 0
  end

  # Read one value from the buffer
  #
  # The value will be "consumed", meaning it will no longer be readable. If the
  # buffer is empty, this will return nil, so if it matters, check `empty?`
  # before calling `read`.
  #
  # @return [Object, nil] The value that was read, or nil if empty
  def read
    return nil if empty?

    value = @buffer[@read]
    @read = (@read + 1) % @buffer.size
    value
  end

  # Read a value from the buffer without consuming it
  #
  # Like {#read}, this will return nil when the buffer is empty, so
  # check {#empty} if you need to distinguish between the two states.
  #
  # @return [Object, nil] The value that was read, or nil if empty
  def peek
    return nil if empty?

    @buffer[@read]
  end

  # Write one value to the buffer
  #
  # Write a value to thee buffer
  #
  # @param value [Object] The value to write
  # @return [void]
  def write(value)
    @buffer[@write] = value

    # If the buffer is full before a write, we drop the oldest value by
    # moving the read pointer as well
    @read = (@read + 1) % @buffer.size if full?
    @write = (@write + 1) % @buffer.size
    nil
  end

  # Is the buffer full?
  #
  # A full buffer does not prevent writes, but it does mean that the next
  # write will overwrite an unread value.
  #
  # @return [Boolean] True if the buffer is full
  def full?
    # When full, the write pointer will be one less than the read pointer
    # (mod buffer size).
    (@write + 1) % @buffer.size == @read
  end

  def empty?
    # When empty, the read and write pointers will be in the same place.
    @read == @write
  end

  # The number of unread items
  #
  # @return [Integer] The buffer size
  def size
    if @write >= @read
      @write - @read
    else
      @buffer.size - @read + @write
    end
  end

  # Get an array of all the unread items in the buffer
  #
  # Unlike {#read}, this does not consume buffer items
  #
  # @return [Array<Object>] An array having length of {#size}
  def to_a
    if @write >= @read
      @buffer[@read...@write]
    else
      @buffer[@read...@buffer.size] + @buffer[0...@write]
    end
  end
end
