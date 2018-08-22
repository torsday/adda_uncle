# CaesarShift Cypher
# basic implementation: only letters, no numbers, or symbols
# decrypts by going through the 26 possible results, returning the translation
# containing the most engligh (and personal) words

require_relative 'word_list'

class CaesarShift
  def self.encrypt(args)
    plain_text = args[:plain_text].downcase
    alphabet = ("a".."z").to_a
    rot  = args[:rot]
    key = Hash[alphabet.zip(alphabet.rotate(rot))]
    key[" "] = " "
    key["."] = "."
    plain_text.each_char.inject("") do |encrypted, char|
      if key[char]
        encrypted + key[char]
      else
        encrypted + char
      end
    end
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

  def self.pruneNumAndSymFromString(_string)
    finalStr = _string
    # finalStr = swapPeriodsWithSpaces(finalStr)
    # finalStr = swapNewlinesWithSpaces(finalStr)
    # finalStr = removeSymbols(finalStr)
    # finalStr = removeNumbers(finalStr)
    # finalStr = cleanSpaces(finalStr)

    finalStr
  end

  def self.cleanSpaces(_string)
    return_str = _string
    return_str.gsub!(/\ \ /, " ")
    return_str.strip! || return_str
  end

  def self.swapNewlinesWithSpaces(_string)
    _string.gsub!(/\n/, ' ')
  end

  def self.swapPeriodsWithSpaces(_string)
    _string.gsub!(/\./, ' ')
  end

  def self.removeNumbers(_string)
    _string.tr("0-9", "")
  end

  def self.removeSymbols(_string)
    _string.gsub!(/[^0-9A-Za-z ]/, '')
  end
end

# ---

known_words = WordList::ALL

triumph = <<-MSG
The only thing necessary for the triumph of evil is for good men to do nothing.
Edmund Burke
MSG

message = <<-MSG
I risk it for the freedom, to see what is true, what I really want in the
deepest part of myself. I can make whatever choices I want in my life,
and I will live with the consequences of those choices. But if I want to
live a life close to my deepest desires, I have to risk knowing who I
really am and have always been. Knowing this, then I can choose.
MSG

invitation = <<-MSG
Interested in cryptography? Cryptograms? Come to this thursday's lunch and learn. We'll be going over Cryptography from ancient times through the early twentieth century.
MSG

cleaned_plaintext = CaesarShift.pruneNumAndSymFromString(invitation)

cypher_text = CaesarShift.encrypt({:plain_text => cleaned_plaintext, :rot => 11})

puts "\nPLAIN"
puts cleaned_plaintext
puts "---"

puts "\nCYPHER"
puts cypher_text
puts "---"

decrypted_msg = CaesarShift.decrypt({:cypher_text => cypher_text})[:text]

puts "\nDECRYPTED"
puts decrypted_msg
