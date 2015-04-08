# Caesar Cypher
# basic implementation: only letters, no numbers, or symbols
# decrypts by going through the 26 possible results, returning the translation
# containing the most engligh (and personal) words

require_relative 'word_list'

class Caesar
  def self.encrypt(args)
    plain_text = args[:plain_text].downcase
    alphabet = ("a".."z").to_a
    rot  = args[:rot]
    key = Hash[alphabet.zip(alphabet.rotate(rot))]
    key[" "] = " "
    plain_text.each_char.inject("") { |encrypted, char| encrypted + key[char] }
  end

  def self.decrypt(args)
    cypher_text = args[:cypher_text]
    possibles = []
    top_contender = {:score => 0, :text => ""}
    (0..25).each do |n|
      translation = self.encrypt(:rot => n, :plain_text => cypher_text)
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

message = "Lorem ipsum dolor sit amet consectetur adipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum"
cypher_text = Caesar.encrypt({:plain_text => message, :rot => 11})

puts "CYPHER"
puts cypher_text
puts "---"

decrypted_msg = Caesar.decrypt({:cypher_text => cypher_text})[:text]

puts "DECRYPTED"
puts decrypted_msg
