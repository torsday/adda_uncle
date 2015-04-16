# Caesar Cypher
# basic implementation: only letters, no numbers, or symbols
# decrypts by going through the 26 possible results, returning the translation
# containing the most engligh (and personal) words

require_relative 'word_list'

class Caesar
  def self.encrypt(args)
    plaintext = args[:plaintext].downcase
    alphabet = ("a".."z").to_a
    rot  = args[:rot]
    key = Hash[alphabet.zip(alphabet.rotate(rot))]
    key[" "] = " "
    plaintext.each_char.inject("") do |encrypted, char|
      if key[char]
        encrypted + key[char]
      else
        encrypted + char
      end
    end
  end

  def self.decrypt(args)
    cyphertext = args[:cyphertext]
    possibles = []
    top_contender = {:score => 0, :text => ""}
    (0..25).each do |n|
      translation = self.encrypt(:rot => n, :plaintext => cyphertext)
      eng_word_count = num_of_english_words(translation)
      if eng_word_count > top_contender[:score]
        top_contender[:score] = eng_word_count
        top_contender[:text] = translation
      end
    end
    top_contender
  end

  def self.num_of_english_words(str)
    arr = str.downcase.split(" ")
    count = 0
    arr.each do |w|
      count += 1 if WordList::ALL.include?(w)
    end
    count
  end

end

# ---

known_words = WordList::ALL

message = <<-MSG
I risk it for the freedom, to see what is true, what I really want in the
deepest part of myself. I can make whatever choices I want in my life,
and I will live with the consequences of those choices. But if I want to
live a life close to my deepest desires, I have to risk knowing who I
really am and have always been. Knowing this, then I can choose.
MSG
cyphertext = Caesar.encrypt({:plaintext => message, :rot => 11})

puts "CYPHER"
puts cyphertext
puts "---"

decrypted_msg = Caesar.decrypt({:cyphertext => cyphertext})[:text]

puts "DECRYPTED"
puts decrypted_msg
