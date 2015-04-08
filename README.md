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
