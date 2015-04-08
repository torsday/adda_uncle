Uncle Puzzles
=============

Puzzles for my nephew & niece.


## Puzzle 1

Caesar Cypher

### encryption

```ruby
message = "message to encrypt!"
cypher_text = Caesar.encrypt({:plain_text => message, :rot => 11})
# => xpddlrp ez pyncjae!
```

### decryption

```ruby
cypher_text = "xpddlrp ez pyncjae!"
decrypted_msg = Caesar.decrypt({:cypher_text => cypher_text})[:text]
# => message to encrypt!
```

## Puzzle 2

direct ASCII translation using decimal radix

### encryption

```ruby
plain_text = "message to encrypt!"
cypher_text = AsciiCrypto.encrypt(:plain_text => plain_text)
# => 109 101 115 115 097 103 101 032 116 111 032 101 110 099 114 121 112 116 033
```

### decryption

```ruby
decrypted_msg = AsciiCrypto.decrypt({:cypher_text => cypher_text})
# => message to encrypt!
```
