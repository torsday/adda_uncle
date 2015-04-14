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

# Colorize strings
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end

# Given a word, this creates an object that:
# spells the word out as numbers
# returns number:letter relationship hashes
class VerbumNumerus
  attr_accessor :key_by_num, :key_by_char, :text, :num
  def initialize(args={})
    @text        = args[:text]
    @num
    @key_by_char = {}
    @key_by_num  = {}
    populate_variables
  end

  private

  def populate_variables
    count = 1
    self.text.split("").each do |char|
      count_base_36 = count.to_s(36)
      raise "#{count} is too high for ruby's radix max" if count > 35
      unless self.key_by_char.has_key?(char)
        self.key_by_char[char] ||= count_base_36
        count += 1
      end
    end
    self.num = text.each_char.map{|c| self.key_by_char[c]}.join()
    self.key_by_char.each { |char,num| self.key_by_num[num] = char }
  end

end

class Cryptogram

  attr_accessor :plain_text, :cypher_text, :key, :seed

  def initialize(args={})
    @plain_text  = args[:plain_text].downcase || nil
    @cypher_text = args[:cypher_text]         || nil
    @key         = args[:key]                 || nil
    @seed        = args[:seed]                || 1234
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
    @delimiter   = args[:delimiter] || most_common_char
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

  def most_common_char
    chars = {}
    cypher_text.each_char do |c|
      chars[c] ||= 0
      chars[c] += 1
    end
    chars.sort_by{|key,value| value}.reverse.first[0]
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

  # super header: frequency percentage
  # header: character, ordered by freq. percentage
  # content: how often they are neighbors with x char
  def character_relationship_chart
    min_perc = 2.0
    title_bar_a = "   "
    title_bar_b = "   "
    cy_alphabet = self.alphabet
    cy_letter_freq = self.letter_freq
    frequency_ordered_hash_of_chars = cy_letter_freq.sort_by{|key,value| key}.reverse.to_h
    frequency_ordered_hash_of_chars.each do |c,val|
      perc_count = val * 100.0/self.cypher_text.length
      perc_count = perc_count.round(0)
      if perc_count > 9
        title_bar_a += "|#{perc_count} ".red
      else
        if perc_count > 4
          title_bar_a += "| #{perc_count} ".red
        else
          title_bar_a += "| #{perc_count} "
        end
      end
    end
    frequency_ordered_hash_of_chars.each_key do |c|
      c =~ /\n/ ? title_bar_b += "|\\n " : title_bar_b += "| #{c} "
    end
    puts "ignoring %'s below #{min_perc}'"
    puts title_bar_a
    puts title_bar_b
    puts "=" * title_bar_b.length
    frequency_ordered_hash_of_chars.delete(nil)
    frequency_ordered_hash_of_chars.each_key do |char|
      char =~ /\n/ ? row = "\\n|" : row = "#{char} |"
      neighbors_of_char = self.neighbor_chars_of(char)
      neighbors_of_char.delete(nil)
      neighbors_of_char = neighbors_of_char.sort_by{|key,value| key}.reverse.to_h
      neighbors_of_char.each do |neighbor,count|
        perc_count = count * 100.0/self.cypher_text.length
        perc_count = perc_count.round(1)
        if perc_count > min_perc
          if perc_count > 2.3
            row += "|#{perc_count}".red
          else
            row += "|#{perc_count}"
          end
        elsif perc_count > 0
          row += "| X "
        else
          row += "|   "
        end
        # neighbor =~ /\n/ ? row += "| \\n " : row += "| #{neighbor} " # debugging
      end
      neighbor_total = neighbors_of_char.select{|char,value| value > 0}.count
      if neighbor_total > 15
        row += "| #{neighbor_total}".red
      else
        row += "| #{neighbor_total}"
      end
      puts row
    end


  end

  def neighbor_chars_of(char)
    neighbors = {}
    (0..cypher_text.length).each do |n|
      target = cypher_text[n]
      before = nil
      after  = nil

      if n == 0
        before = nil
      else
        before = cypher_text[n - 1]
      end

      if n == cypher_text.length
        after = nil
      else
        after = cypher_text[n + 1]
      end

      neighbors[before]  ||= 0
      neighbors[after]   ||= 0

      if cypher_text[n] == char
        neighbors[before]   += 1
        neighbors[after]    += 1
      end
    end
    return neighbors
  end

  def decrypt

    # translate words to number alphabet + hash key
    # {number_version => ..., :num_to_char =>...}
    cypher_words_num_and_key = []
    words(:clean => true).each do |word|
      verbum_numerus = VerbumNumerus.new(:text => word)
      cypher_words_num_and_key << {:translation => verbum_numerus.num, :num_to_char => verbum_numerus.key_by_num}
    end

    # translate dictionary into positional hash
    # {position => [num_to_char hashes]}
    dictionary_of_order_alphabet = {}
    WordList::ALL.each do |word|
      verbum_numerus = VerbumNumerus.new(:text => word)
      verbum_numerus.text
      dictionary_of_order_alphabet[verbum_numerus.num] ||= []
      dictionary_of_order_alphabet[verbum_numerus.num] << verbum_numerus.key_by_num
    end
    # p dictionary_of_order_alphabet.keys

    # go through each cypher word
    # collect the possible matching english words based upon num_alphabet pttrn
    cyphers_which_translated_words_to_english = []
    possible_keys = []
    cypher_words_num_and_key.each do |cypher_word|
      char_to_char         = {}
      numbered_cypher_word = cypher_word[:translation]
      cypher_num_to_char   = cypher_word[:num_to_char]

      # using the matching dictionary cypher,
      # for each possible cypher
      # translate the cypher's number version into the possible plaintext
      dictionary_of_order_alphabet[numbered_cypher_word].each do |possible_cypher|
        temp_arr = []
        numbered_cypher_word.each_char{|c| temp_arr << possible_cypher[c]}
        possible_plaintext = temp_arr.join("")

        # if the words is an actual word in the dictionary...if
        if WordList::ALL.include?(possible_plaintext)
          # puts "#{possible_cypher}: #{possible_plaintext}"
          cyphers_which_translated_words_to_english << possible_cypher
        end

      end

      # puts "#{numbered_cypher_word}: #{cypher_num_to_char}"
      puts " matching_keys for #{numbered_cypher_word}:#{cypher_num_to_char}: #{dictionary_of_order_alphabet[numbered_cypher_word].length}"
      # (1..cypher_word.length).each do |n|
      #   c_char = cypher_word[:num_to_char][n]
      #   p_char =
      #
      #   dictionary_of_order_alphabet[]
      #
      #
      #   {c_char => p_char}
      #   pchar_to_char[cypher_word[:num_to_char][n]]
      # end
      # possible_keys += dictionary_of_order_alphabet[word]
    end

    # possible keys down to 172954
    p "cyphers_which_translated_words_to_english: #{cyphers_which_translated_words_to_english.length}"

    # apply remaining cypher keys to entire cyphertext,
    # getting their score,
    # returning the top scorers
    english_scores_for_entire_plaintext = {} # score => cypher
    cyphers_which_translated_words_to_english.sort_by{|x| x.length }.each do |possible_cypher|

      # get plaintext
      possible_plaintext_arr = []
      self.cypher_text.each_char do |c|
        p c
        p possible_cypher
        if possible_cypher[c]
          possible_plaintext_arr << possible_cypher[c]
        else
          possible_plaintext_arr << c
        end
      end
      possible_plaintext = possible_plaintext_arr.join("")

      # calculate score, and save
      eng_score = non_class_percentage_of_english_words(possible_plaintext)
      p possible_cypher
      puts "#{eng_score}: #{possible_plaintext}"
      english_scores_for_entire_plaintext[eng_score] ||= []
      english_scores_for_entire_plaintext[eng_score] << possible_cypher
    end

    p "english_scores_for_entire_plaintext scores: #{english_scores_for_entire_plaintext.keys}"


    # ...cyphers are yet incomplete at this point

    # for n in (80..100).to_a.reverse
    #   p n
    # end


    # p possible_keys.count # 32086, still high, but not 26! high

    # rank keys in terms of score
    # key_scores = []
    # possible_keys.each do |possible_key|
    #   p possible_key
    #   possible_plain_text = translate_with_key(:key => possible_key)
    #   p possible_plain_text
    #   list_of_words = words(:clean => true, :str => possible_plain_text)
    #   p list_of_words
    #   score = percentage_of_english_words(list_of_words) # list of words
    #   key_scores << {:score => score, :key => possible_key}
    # end
    # p key_scores
    # return true
  end

  # ---

  def translate_with_key(args={})
    temp_key = args[:key]
    self.cypher_text.split(self.delimiter).map {|c| temp_key[c]}.join()
  end

  # ---

end

def num_of_english_words(str)
  arr = str.downcase.split(" ")
  count = 0
  arr.each do |w|
    count += 1 if WordList::ALL.include?(w)
  end
  count
end

def highest_num_of_eng_words(arr_of_potential_answers)
  highest_count = 0
  highest_string = ""
  arr_of_potential_answers.each do |possible|
    the_count = num_of_english_words(possible)
    if the_count > highest_count
      highest_count = the_count
      highest_string = possible
    end
  end
  highest_string
end

def non_class_percentage_of_english_words(str)
  cleaned_words = non_class_words({:clean => true, :str => str})
  total_word_count = cleaned_words.length
  eng_words = 0
  cleaned_words.each do |w|
    eng_words += 1 if WordList::ALL.include?(w)
  end
  percentage_eng_words = (eng_words * 1.0) / total_word_count
  percentage_eng_words = percentage_eng_words.round(2) * 100
  return percentage_eng_words
end

def non_class_words(args={})
  clean = args[:clean] || false
  str   = args[:str]

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
cy_alphabet = cypher.alphabet
p cy_alphabet
puts "\ncleaned words"
p cypher.words(:clean => true)
puts "\nenglish matches"
p cypher.percentage_of_english_words(cypher.words(:clean => true))
puts "\nletter freq"
cy_letter_freq = cypher.letter_freq
cy_letter_freq.each do |char, num|
  t_str = ''
  # unless char =~ /[a-zA-Z0-9]/
  #   char = char.gsub(/\\/,'\\')
  #   p char
  # end
  if char =~ /\n/
    char = "\\n"
  else
    char = " #{char}"
  end
  if num > 20
    t_str += " #{char}: #{num}".red
  else
    t_str += " #{char}: #{num}"
  end
  puts t_str
end
puts "\ncharacter relationships: neighbors"
cypher.character_relationship_chart
# title_bar_a = ""

# p title_bar_a
# cy_letter_freq.sort_by{|key,value| value}.reverse.to_h.each_key do |char|
#   #  p cypher.neighbor_chars_of(char)
# end
# puts "\nmost common first letter"
p cypher.most_common_first_letter
puts "\nmost_common_single_char_words"
p cypher.most_common_single_char_words
puts "\nword_lengths_with_delimiter"
p cypher.word_lengths_with_delimiter
puts "\nplain_text with current key"
p cypher.plain_text
# puts "\nDECRYPTED"
# cypher.decrypt
# p cypher.plain_text






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
