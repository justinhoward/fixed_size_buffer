# frozen_string_literal: true

RSpec.describe FixedSizeBuffer do
  subject(:buffer) { described_class.new(capacity) }
  let(:capacity) { 3 }

  it 'reads nil if empty' do
    expect(buffer.read).to eq(nil)
  end

  context 'with full buffer' do
    subject(:buffer) do
      #   r           w
      # | 1 | 2 | 3 |   |
      buffer = described_class.new(capacity)
      buffer.write(1)
      buffer.write(2)
      buffer.write(3)
      buffer
    end

    it 'reads in FIFO order' do
      expect(buffer.read).to eq(1)
      expect(buffer.read).to eq(2)
      expect(buffer.read).to eq(3)
    end

    it 'overwrites oldest item' do
      buffer.write(4)
      expect(buffer.read).to eq(2)
    end

    it 'can interleave read/write' do
      expect(buffer.read).to eq(1)
      buffer.write(4)
      expect(buffer.read).to eq(2)
      buffer.write(5)
      expect(buffer.read).to eq(3)
      buffer.write(6)
      expect(buffer.read).to eq(4)
    end

    it 'is full' do
      expect(buffer).to be_full
    end

    it 'has size 3' do
      expect(buffer.size).to eq(3)
    end

    it 'wraps the write and read pointer while writing' do
      buffer.write(4)
      buffer.write(5)
      #       w   r
      # | 5 | 2 | 3 | 4 |
      expect(buffer.read).to eq(3)
      buffer.write(6)
      buffer.write(7)
      #   r   w
      # | 5 | 6 | 7 | 4 |
      expect(buffer.read).to eq(5)
    end

    it 'gets array without consuming' do
      expect(buffer.to_a).to eq([1, 2, 3])
      expect(buffer.read).to eq(1)
    end

    it 'peeks without consuming' do
      expect(buffer.peek).to eq(1)
      expect(buffer.read).to eq(1)
    end
  end

  # The state where the write pointer is in position
  # before the read pointer, so we have to calculate
  # ranges and sizes in a more complex way
  context 'with wrapped around buffer' do
    subject(:buffer) do
      #       w   r
      # | 5 | 2 | 3 | 4 |
      buffer = described_class.new(capacity)
      buffer.write(1)
      buffer.write(2)
      buffer.write(3)
      buffer.read
      buffer.read
      buffer.write(4)
      buffer.write(5)
      buffer
    end

    it 'has accurate size' do
      expect(buffer.size).to eq(3)
      buffer.read
      expect(buffer.size).to eq(2)
    end

    it 'gets array' do
      expect(buffer.to_a).to eq([3, 4, 5])
    end

    it 'is full' do
      expect(buffer).to be_full
      buffer.read
      expect(buffer).not_to be_full
    end

    it 'is not empty' do
      expect(buffer).not_to be_empty
      buffer.read
      buffer.read
      buffer.read
      expect(buffer).to be_empty
    end
  end

  context 'with capacity 0' do
    #   rw
    # |    |
    let(:capacity) { 0 }

    it 'reads nothing' do
      expect(buffer.read).to be_nil
    end

    it 'peeks nothing' do
      expect(buffer.peek).to be_nil
    end

    it 'writes nothing' do
      expect(buffer.write('test')).to be_nil
      expect(buffer.read).to be_nil
    end

    it 'is empty' do
      expect(buffer).to be_empty
    end

    it 'is full' do
      expect(buffer).to be_full
    end

    it 'is size 0' do
      buffer.write('test')
      expect(buffer.size).to eq(0)
    end
  end
end
