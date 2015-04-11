# this'll be a doozy...
# purpose, to (en/de)crypt true cryptograms. Those not using a rotation cypher,
# but rather a random key-value pairing
# examing characater frequency is where my gut wants to take me, but that is but
# a step in towards a solution
#
# Limit this to substitution cypher
# spaces will mean spaces
# in English, one letter words can only be "i" or "a" (and sometimes "o")
# numbers and symbols don't change
#
# If we were to try every combination of our 26 char alphabet, it would be
# 26!, or 4e+26 combinations, with a exponential Big O notation ...yikes
#
# Letter frequency tacts
#   overall
#   first character
#   based upon word length
#   common word lengths (when you can't trust " " as a space)
#
# go through dictionary, word by word, making hash with key of order of letters,
# matched to resulting keyset, e.g.
# christopher... dict_lookup[]


# require 'rspec'
require_relative 'word_list'

class Cryptogram

  attr_accessor :plain_text, :cypher_text, :key, :seed

  def initialize(args={})
    @plain_text  = args[:plain_text].downcase || nil
    @cypher_text = args[:cypher_text] || nil
    @key         = args[:key] || nil
    @seed        = args[:seed] || 1234
  end

  def encrypt
    alphabet      = ("a".."z").to_a
    crypto_seed   = Random.new(seed) if seed
    crypto_seed ||= Random.new
    key           = Hash[alphabet.zip(alphabet.shuffle(random: crypto_seed))]

    self.cypher_text = plain_text.each_char.inject("") do |encrypted, char|
      if key[char]
        encrypted + key[char]
      else
        encrypted + char
      end
    end
    return true
  end

  def decrypt()
  end

end

# ---

class CypherAnalysis

  attr_reader :cypher_text, :key
  attr_accessor :delimiter, :plain_text

  def initialize(args)
    @cypher_text = args[:cypher_text]
    @plain_text
    @delimiter   = args[:delimiter] || " "
    @key         = args[:key] || Hash[alphabet.zip(alphabet.rotate(0))]
  end

  def alphabet
    alphabet = []
    cypher_text
      .each_char{|c| alphabet << c}
    alphabet.uniq.sort
  end

  def plain_text
    cypher_text
      .each_char
      .map {|char| key[char]}
      .join()
  end

  def letter_freq
    results = {}
    alphabet.each {|char| results[char] = 0}
    cypher_text.each_char {|cypher_char| results[cypher_char] += 1}
    results.sort_by {|key,value| value}.reverse.to_h
  end

  def most_common_first_letter
    results = {}
    first_letters = words.map{|word| word[0]}
    first_letters.uniq.each{|l| results[l] = 0}
    first_letters.each{|l| results[l] += 1}

    only_one = []
    results.each { |key,value| only_one << key if value <= 1 }
    only_one.each {|oo| results.delete(oo)}

    results.sort_by {|key,value| value}.reverse.to_h
  end

  def most_common_single_char_words
    results = {}
    single_char_words = words.select {|word| word.length == 1}
    single_char_words.each {|w| results[w] = 0}
    single_char_words.each {|w| results[w] += 1}
    results
  end

  def words(args={})
    clean = args[:clean] || false
    str   = args[:str] || cypher_text

    all_words = str
      .split(delimiter)
      .uniq

    if clean == false
      return all_words.sort
    else
      cleaned_words = all_words
        .map{|word| word.downcase}
        .map{|word| word.gsub(/(^\W*|\W*$)/,"")} # remove leading/trailing non-words
        .uniq
        .sort_by{|word| word.length}
      return cleaned_words
    end
  end

  def percentage_of_english_words(list_of_words)
    total_words = list_of_words.length
    count = 0

    list_of_words.each do |w|
      match = false

      # create a list of possible base words
      word_versions = [w]
      word_versions << w.gsub(/s$/,"")
      word_versions << w.gsub(/es$/,"")
      word_versions << w.gsub(/ed$/,"")
      word_versions << w.gsub(/ing$/,"")
      word_versions << w.gsub(/ing$/,"e")
      word_versions.uniq!

      # count occurrences of word (examining different versions)
      word_versions.each do |version|
        match = true if WordList::ALL.include?(version)
      end
      count += 1 if match
    end
    ((count * 1.0) / total_words).round(4)
  end

  def word_lengths_with_delimiter
    results = {}
    word_lengths = words(:delimiter => " ").map {|w| w.length}
    word_lengths.each {|wl| results[wl] = 0}
    word_lengths.each {|wl| results[wl] += 1}
    results.sort_by {|key,value| value}.reverse.to_h
  end

  def decrypt

    # translate words to ordered version
    cypher_words_res = []
    words(:clean => true).each do |word|
      results = translate_word_to_positional(word)
      word_in_num_form = results[:translation]
      cypher_words_res << {:translation => results[:translation], :num_to_char => results[:num_to_char]}
    end

    # translate dictionary into positional hash
    # {position => [num_to_char hashes]}
    dictionary_of_order_alphabet = {}
    WordList::ALL.each do |word|
      results = translate_word_to_positional(word)
      dictionary_of_order_alphabet[results[:translation]] ||= []
      dictionary_of_order_alphabet[results[:translation]] << results[:num_to_char]
    end
    # p dictionary_of_order_alphabet.keys

    # go through each
    possible_keys = []
    cypher_words_res.each do |word_res|
      char_to_char = {}
      word_were_working_with = word_res[:translation]
      (1..word.length).each do |n|
        c_char = word_res[:num_to_char][n]
        p_char =

        dictionary_of_order_alphabet[]


        {c_char => p_char}
        pchar_to_char[word_res[:num_to_char][n]]
      end
      possible_keys += dictionary_of_order_alphabet[word]
    end
    # p possible_keys.count # 32086, still high, but not 26! high

    # rank keys in terms of score
    key_scores = []
    possible_keys.each do |possible_key|
      p possible_key
      possible_plain_text = translate_with_key(:key => possible_key)
      p possible_plain_text
      list_of_words = words(:clean => true, :str => possible_plain_text)
      p list_of_words
      score = percentage_of_english_words(list_of_words) # list of words
      key_scores << {:score => score, :key => possible_key}
    end
    p key_scores
    return true
  end

  # ---

  def translate_with_key(args={})
    temp_key = args[:key]
    self.cypher_text.split(self.delimiter).map {|c| temp_key[c]}.join()
  end

  def translate_word_to_positional(word)
    char_to_num = {}
    num_to_char = {}
    count       = 1
    word.split("").each do |char|
      count_base_36 = count.to_s(36)
      raise "can't go that high" if count > 35
      unless char_to_num.has_key?(char)
        char_to_num[char] ||= count_base_36
        count += 1
      end
    end

    translated_word = word.each_char.map{|w| char_to_num[w]}.join()

    char_to_num.each { |key,value| num_to_char[value] = key }

    # char_to_char = {}
    # char_to_num.each { |char,num| char_to_char[char] = num_to_char[num]}
    # p char_to_char

    # p num_to_char

    {
      :char_to_num  => char_to_num,
      :num_to_char  => num_to_char,
      # :char_to_char => char_to_char,
      :original     => word,
      :translation  => translated_word
    }
  end

end

# ---

p_text = <<-PLAIN
When it came time for me to give my talk on the subject,
I started off by drawing an outline of the cat and began to name
the various muscles. The other students in the class interrupt me:
“We know all that!” “Oh,” I say, “you do? Then no wonder I can catch
up with you so fast after you’ve had four years of biology.”
They had wasted all their time memorizing stuff like that,
when it could be looked up in fifteen minutes.

Feynman, Richard P.
PLAIN


puts "\n--- plain text\n#{p_text}---"

# hash of dic word length => arr of words
# dictionary_word_length = {}
# WordList::ALL.each do |word|
#   dictionary_word_length[word.length] ||= []
#   dictionary_word_length[word.length] << word
# end

# ---

# display list of dictionary word lengths, and number of matching words
# dictionary_word_length
#   .keys
#   .sort
#   .each do |length|
#     puts "#{length}: #{dictionary_word_length[length].length}"
#   end
#
# p dictionary_word_length[1].map{|x|x.downcase}.uniq
# puts dictionary_word_length[24]

# ---

cryptogram = Cryptogram.new(:plain_text => p_text)
cryptogram.encrypt

puts "\nCYPHER TEXT"
puts cryptogram.cypher_text

cypher = CypherAnalysis.new(cypher_text: cryptogram.cypher_text, delimiter: " ")

puts "\nalphabet"
p cypher.alphabet
puts "\ncleaned words"
p cypher.words(:clean => true)
puts "\nenglish matches"
p cypher.percentage_of_english_words(cypher.words(:clean => true))
puts "\nletter freq"
p cypher.letter_freq
puts "\nmost common first letter"
p cypher.most_common_first_letter
puts "\nmost_common_single_char_words"
p cypher.most_common_single_char_words
puts "\nword_lengths_with_delimiter"
p cypher.word_lengths_with_delimiter
puts "\nplain_text with current key"
p cypher.plain_text
puts "\nDECRYPTED"
cypher.decrypt
p cypher.plain_text

# ---

# puts "\n\n # of different word lengths based upon where you split"
# cypher.alphabet.each do |char|
#   cypher.delimiter = char
#   p "#{char}: #{cypher.word_lengths_with_delimiter.keys.count}"
# end

# ---










# describe Cryptogram do
#   it "should encrypt" do
#     known_cypher_text = "test"
#     expect(Cryptogram.encrypt({:plain_text => p_text, :seed => 123456})).to eq(known_cypher_text)
#   end
#
#   it "should decrypt" do
#     msg = p_text
#     cypher_text = Cryptogram.encrypt(msg)
#     expect(Cryptogram.decrypt({cypher_text: cypher_text})).to eq(msg)
#   end
# end
