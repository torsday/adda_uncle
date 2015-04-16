Uncle Puzzles
=============

Puzzles for my nephew & niece.


## Puzzle 1

Caesar Cypher

```ruby
message = "message to encrypt!"

# ENCRYPTION
cyphertext = Caesar.encrypt({:plaintext => message, :rot => 11})
# => xpddlrp ez pyncjae!

# DECRYPTION
cyphertext = "xpddlrp ez pyncjae!"
decrypted_msg = Caesar.decrypt({:cyphertext => cyphertext})[:text]
# => message to encrypt!
```

## Puzzle 2

direct ASCII translation using decimal radix

```ruby
plaintext = "message to encrypt!"

# ENCRYPTION
cyphertext = AsciiCrypto.encrypt(:plaintext => plaintext)
# => 109 101 115 115 097 103 101 032 116 111 032 101 110 099 114 121 112 116 033

# DECRYPTION
decrypted_msg = AsciiCrypto.decrypt({:cyphertext => cyphertext})
# => message to encrypt!
```

## Puzzle 3

Puzzle 2 introduced the idea of encoding letters with numbers (i.e. ASCII). This puzzle introduces the idea that not all numbers are decimal.

The driving code randomly selects a radix (or base) ranging from 2 to 36 (10 digits + 26 letters). The decryptor tries every possible radix, choosing the one with the most english words. Of note, the minimum radix is established from the number of different characters found in the cyphertext.

```ruby
MY_RADIX = 2 + rand(34)

plaintext = "message to encrypt!"

# ENCRYPTION
cyphertext = AsciiCrypto.encrypt(:plaintext => plaintext, :radix => MY_RADIX)

# CYPHER ALPHABET
cypher_alphabet = AsciiCrypto.used_chars(:text => cyphertext)
cypher_alphabet.delete(" ")

# DECRYPTION
decrypted_msg = AsciiCrypto.decrypt({:cyphertext => cyphertext})
```


## Puzzle 4

Let's start with creating our cyphertext. We'll be using these assumptions of the plaintext:

### Assumptions
* most common character is the space character
* plaintext language is english
* ```\n``` is the only special character
* lowercase and uppercase are normalized
* large text, from which to extrapolate significant percentages
* plaintext is english
* every word has a vowel in it
* most common single char words:
* most common triple char words: the, and
* h frequently goes before e, but rarely after

### Weaknesses
* can't handle significant amount of misspelled words
* can't handle text w/o spaces
