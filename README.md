Uncle Puzzles
=============

Puzzles for my nephew & niece.


## Puzzle 1

Caesar Cypher

```ruby
message = "message to encrypt!"

# ENCRYPTION
cypher_text = Caesar.encrypt({:plain_text => message, :rot => 11})
# => xpddlrp ez pyncjae!

# DECRYPTION
cypher_text = "xpddlrp ez pyncjae!"
decrypted_msg = Caesar.decrypt({:cypher_text => cypher_text})[:text]
# => message to encrypt!
```

## Puzzle 2

direct ASCII translation using decimal radix

```ruby
plain_text = "message to encrypt!"

# ENCRYPTION
cypher_text = AsciiCrypto.encrypt(:plain_text => plain_text)
# => 109 101 115 115 097 103 101 032 116 111 032 101 110 099 114 121 112 116 033

# DECRYPTION
decrypted_msg = AsciiCrypto.decrypt({:cypher_text => cypher_text})
# => message to encrypt!
```

## Puzzle 3

Puzzle 2 introduced the idea of encoding letters with numbers (i.e. ASCII). This puzzle introduces the idea that not all numbers are decimal.

The driving code randomly selects a radix (or base) ranging from 2 to 36 (10 digits + 26 letters). The decryptor tries every possible radix, choosing the one with the most english words. Of note, the minimum radix is established from the number of different characters found in the cyphertext.

```ruby
MY_RADIX = 2 + rand(34)

plain_text = "message to encrypt!"

# ENCRYPTION
cypher_text = AsciiCrypto.encrypt(:plain_text => plain_text, :radix => MY_RADIX)

# CYPHER ALPHABET
cypher_alphabet = AsciiCrypto.used_chars(:text => cypher_text)
cypher_alphabet.delete(" ")

# DECRYPTION
decrypted_msg = AsciiCrypto.decrypt({:cypher_text => cypher_text})
```
