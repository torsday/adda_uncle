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

  attr_accessor :plain_text, :cyphertext, :key, :seed

  def initialize(args={})
    @plain_text  = args[:plain_text].downcase || nil
    @cyphertext = args[:cyphertext]         || nil
    @key         = args[:key]                 || nil
    @seed        = args[:seed]                || 1234
  end

  def encrypt
    alphabet      = ("a".."z").to_a
    crypto_seed   = Random.new(seed) if seed
    crypto_seed ||= Random.new
    key           = Hash[alphabet.zip(alphabet.shuffle(random: crypto_seed))]

    self.cyphertext = plain_text.each_char.inject("") do |encrypted, char|
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

  attr_reader :cyphertext, :key
  attr_accessor :delimiter, :plain_text

  def initialize(args)
    @cyphertext = args[:cyphertext]
    @plain_text
    @delimiter   = args[:delimiter] || most_common_char
    @key         = args[:key] || Hash[alphabet.zip(alphabet.rotate(0))]
  end

  def alphabet
    alphabet = []
    cyphertext
      .each_char{|c| alphabet << c}
    alphabet.uniq.sort
  end

  def plain_text
    cyphertext
      .each_char
      .map {|char| key[char]}
      .join()
  end

  # output {character => percentage}
  def letter_freq
    results = {}
    cypher_char_count = cyphertext.length
    alphabet.each {|char| results[char] = 0} # initialize hash keys
    cyphertext.each_char {|cypher_char| results[cypher_char] += 1}
    percentage_results = {}
    results.each do |char,num|
      perc = (num * 100.0 / cypher_char_count).round(2)
      # puts "#{char}: #{num}: #{perc}"
      percentage_results[char] = perc
    end
    # results.sort_by {|key,value| value}.reverse.to_h
    percentage_results.sort_by{|key,value|value}.reverse.to_h
  end

  def most_common_char
    chars = {}
    cyphertext.each_char do |c|
      chars[c] ||= 0
      chars[c] += 1
    end
    chars.sort_by{|key,value| value}.reverse.first[0]
  end

  def double_chars
    doubles = {}
    (0..(cyphertext.length - 1)).each do |n|
      if cyphertext[n] == cyphertext[n + 1]
        doubles[cyphertext[n]] ||= 0
        doubles[cyphertext[n]] += 1
      end
    end
    doubles
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

    def most_common_words_of_length(args={})
    length = args[:length]
    results = {}

    word_pool = cyphertext.split(delimiter)

    words_of_x_length = word_pool.select {|word| word.length == length}
    words_of_x_length.each {|w| results[w] = 0}
    words_of_x_length.each {|w| results[w] += 1}
    results.sort_by{|key,value|value}.reverse.to_h
  end

  def words(args={})
    clean = args[:clean] || false
    str   = args[:str] || cyphertext

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
    frequency_ordered_hash_of_chars = cy_letter_freq.sort_by{|key,value| key}.to_h
    frequency_ordered_hash_of_chars.each do |c,val|
      perc_count = val.round(1)
      if perc_count > 9
        title_bar_a += "|#{perc_count}".red
      else
        if perc_count > 4
          title_bar_a += "| #{perc_count}".red
        else
          title_bar_a += "| #{perc_count}"
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
      neighbors_of_char = neighbors_of_char.sort_by{|key,value| key}.to_h
      neighbors_of_char.each do |neighbor,count|
        perc_count = count * 100.0/self.cyphertext.length
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
    (0..cyphertext.length).each do |n|
      target = cyphertext[n]
      before = nil
      after  = nil

      if n == 0
        before = nil
      else
        before = cyphertext[n - 1]
      end

      if n == cyphertext.length
        after = nil
      else
        after = cyphertext[n + 1]
      end

      neighbors[before]  ||= 0
      neighbors[after]   ||= 0

      if cyphertext[n] == char
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
      self.cyphertext.each_char do |c|
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
    self.cyphertext.split(self.delimiter).map {|c| temp_key[c]}.join()
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
The White House confirmed that Obama had notified Congress of his intention to remove Cuba from the list, reversing a designation that has been in place since 1982. The announcement came days after a historic meeting between Obama and Cuban president Raúl Castro on the sidelines of the Summit of the Americas in Panama, in the first formal talks between the two countries’ leaders in more than 50 years.
In his letter to Congress, Obama wrote that the Cuban government “has not provided any support for international terrorism” in the past six months, and has “provided assurances that it will not support acts of international terrorism in the future”.
White House press secretary Josh Earnest said the US would continue to have differences with the Cuban government, “but our concerns over a wide range of Cuba’s policies and actions fall outside the criteria that is relevant to whether to rescind Cuba’s designation as a State Sponsor of Terrorism.
“That determination is based on the statutory standard – and the facts – and those facts have led the President to declare his intention to rescind Cuba’s State Sponsor of Terrorism designation,” Earnest said in a statement.
Obama’s decision was made after a State Department review of Cuba’s presence on the terror list – one of several steps the president announced in December as part of his administration’s new policy toward the island nation. The slow pace of the review had been one of several sticking points among Cuban diplomats, thus holding up diplomatic progress and the possibility of reopening embassies in Havana and Washington after a 50-year estrangement.
The long read: In the 1960s, Fidel Castro created Coppelia – a state-run ice‑cream parlour that came to embody Cuba’s revolutionary ideals. As relations with the US begin to thaw, can it survive?
Cuba was placed on the list in 1982 for training and supporting communist rebels in Latin America and Africa, but the country has long since renounced direct military support for foreign militants and the US has not accused the island nation of actively supporting terrorism for years.
Recent State Department reports have criticised Cuba for offering safe haven to members of the Revolutionary Armed Forces of Colombia, Farc, and the Basque separatist group ETA. But Cuba has distanced itself from ETA, and is currently hosting peace talks between Farc and the Colombian government.
The only countries that will now remain on the US terror list are Iran, Sudan and Syria.
Cuba’s removal from the list will also alleviate some of the economic sanctions on the island, thus opening up avenues to access US banking facilities that Cuban officials have said are necessary to reopen an embassy in Washington.
Ben Rhodes, the US deputy national security adviser, tweeted: “Put simply, POTUS is acting to remove Cuba from the State Sponsor of Terrorism list because Cuba is not a State Sponsor of Terrorism.”
Secretary of state John Kerry said the department’s review focused on whether Cuba provided any support for international terrorism over the past six months, and whether the US has received assurances from the Cuban government that it will not support future acts of international terrorism.
“Circumstances have changed since 1982 … Our Hemisphere, and the world, look very different today than they did 33 years ago,” Kerry said in a statement. “Our determination, pursuant to the facts, including corroborative assurances received from the Government of Cuba and the statutory standard, is that the time has come to rescind Cuba’s designation as a State Sponsor of Terrorism.”
Lawmakers on Capitol Hill have 45 days to respond to Obama’s action, but it is unlikely they will seek to block the president from taking Cuba off the list. The move does not end other commercial, economic and financial restrictions under the US embargo on Cuba, as only Congress has the authority to end the freeze.
Senior administration officials told reporters in a conference call Tuesday that they remain optimistic about opening an embassy in Cuba, but acknowledged that obstacles remain. “We’re still not quite there yet,” one official said.
Although Republicans have sharply criticized Obama’s overtures to Cuba, polls show that nearly two-thirds of Americans support the reestablishing of ties. A broad majority of Americans are also in favor of lifting travel restrictions and ending the trade embargo, according to several surveys over the last few months.
Specialists on Latin America agreed that lifting the terror designation was a major step in the normalisation of relations between Washington and Havana.
Richard Feinberg, a senior fellow at the Brookings Institution – and an architect of the first Summit of the Americas – said that the move was part of a process which would culminate in the re-opening of embassies in the the two capitals. Feinberg added: “It also suggests that the White House now sees the opening to Cuba as a political winner.”
Dr. Gregory Weeks, a Latin America expert who heads the political science department at the University of North Carolina at Charlotte, said that removing Cuba from the list was “symbolically a demonstration that the two countries were moving beyond the Cold War.”
“It’s a common sense move given the changing realities of global terrorism -- that’s just not something that Cuba’s involved in,” he said. “It was obviously also a major obstacle to normalization of relations. Cuba has not been a security threat to the United States for many years.”
The news had not yet filtered out to the public in Havana, where the vast majority of people have little or not access to the Internet. But hopes in the Cuban capital had already been raised by Saturday’s meeting between President Raul Castro and Barack Obama.
“The relationship is getting better. I think it will take more time, but in one or two years I feel improved ties will make a big difference in our lives,” said fencing coach Eduardo Delgado, as he chatted with friends in a suburb of the city.
The group of youngsters were quick to credit Obama for the improvement in relations. “He is very intelligent, a real source of hope,” said 22-year-old legal student Dyron Hernandez. “Among Cubans, I think Obama is the most popular world leader right now.”
That view was widely echoed. “Obama is the best US president of my lifetime,” said 67-year-old Fria Nieve. “We must not expect too much because presidents alone do not make decisions, but we can hope for change once trade and travel picks up with a country that less than 100 miles away.”
The benefits of the rapprochement are already apparent. Foreign tourist numbers this year are already at the level of the whole of 2014. In Havana, local say almost all the hotels were booked out for the Easter holiday.

WASHINGTON — The White House relented on Tuesday and said President Obama would sign a compromise bill giving Congress a voice on the proposed nuclear accord with Iran as the Senate Foreign Relations Committee, in rare unanimous agreement, moved the legislation to the full Senate for a vote.
An unusual alliance of Republican opponents of the nuclear deal and some of Mr. Obama’s strongest Democratic supporters demanded a congressional role as international negotiators work to turn this month’s nuclear framework into a final deal by June 30. White House officials insisted they extracted crucial last-minute concessions. Republicans — and many Democrats — said the president simply got overrun.
“We’re involved here. We have to be involved here,” said Senator Benjamin L. Cardin of Maryland, the committee’s ranking Democrat, who served as a bridge between the White House and Republicans as they negotiated changes in the days before the committee’s vote on Tuesday. “Only Congress can change or permanently modify the sanctions regime.”
Mr. Kerry left a classified briefing with senators at the Capitol. Credit Stephen Crowley/The New York Times
The essence of the legislation is that Congress will have a chance to vote on whatever deal emerges with Iran — if one is reached by June 30 — but in a way that would be extremely difficult for Mr. Obama to lose, allowing Secretary of State John Kerry to tell his Iranian counterpart that the risk that an agreement would be upended on Capitol Hill is limited.
As Congress considers any accord on a very short timetable, it would essentially be able to vote on an eventual end to sanctions, and then later take up the issue depending on whether Iran has met its own obligations. But if it rejected the agreement, Mr. Obama could veto that legislation — and it would take only 34 senators to sustain the veto, meaning that Mr. Obama could lose upward of a dozen Democratic senators and still prevail.
The bill would require that the administration send the text of a final accord, along with classified material, to Congress as soon as it is completed. It also halts any lifting of sanctions pending a 30-day congressional review, and culminates in a possible vote to allow or forbid the lifting of congressionally imposed sanctions in exchange for the dismantling of much of Iran’s nuclear infrastructure. It passed 19 to 0.
Why Mr. Obama gave in after fierce opposition was the last real dispute of what became a rout. Josh Earnest, the White House spokesman, said Mr. Obama was not “particularly thrilled” with the bill, but had decided that a new proposal put together by the top Republican and Democrat on the Senate Foreign Relations Committee made enough changes to make it acceptable.
“We’ve gone from a piece of legislation that the president would veto to a piece of legislation that’s undergone substantial revision such that it’s now in the form of a compromise that the president would be willing to sign,” Mr. Earnest said. “That would certainly be an improvement.”
Senator Bob Corker, Republican of Tennessee and the committee’s chairman, had a far different interpretation. As late as 11:30 a.m., in a classified briefing at the Capitol, Mr. Kerry was urging senators to oppose the bill. The “change occurred when they saw how many senators were going to vote for this, and only when that occurred,” Mr. Corker said.
Mr. Cardin said that the “fundamental provisions” of the legislation had not changed.
But the compromise between him and Mr. Corker did shorten a review period of a final Iran nuclear deal and soften language that would make the lifting of sanctions dependent on Iran’s ending support for terrorism.
The agreement almost certainly means Congress will muscle its way into nuclear negotiations that Mr. Obama sees as a legacy-defining foreign policy achievement.
The Senate is expected to vote on the legislation this month, and House Republican leaders have promised to pass it shortly after.
“Congress absolutely should have the opportunity to review this deal,” the House speaker, John A. Boehner of Ohio, said Tuesday. “We shouldn’t just count on the administration, who appears to want a deal at any cost.”
White House officials blitzed Congress in the days after the framework of a nuclear deal was announced, making 130 phone calls to lawmakers, but quickly came to the conclusion that the legislation could not be blocked altogether.
Moreover, officials increasingly worried that an unresolved fight could torpedo the next phase of negotiations with Iran.
“Having this lingering uncertainty about whether we could deliver on our side of the deal was probably a deal killer,” said a senior administration official, who asked for anonymity to describe internal deliberations.
Under the compromise legislation, a 60-day review period of a final nuclear agreement in the original bill was in effect cut in half, to 30 days, starting with its submission to Congress. But tacked on to that review period potentially would be the maximum 12 days the president would have to decide whether to accept or veto a resolution of disapproval, should Congress take that vote.
The formal review period would also include a maximum of 10 days Congress would have to override the veto. For Republicans, that would mean the president could not lift sanctions for a maximum of 52 days after submitting a final accord to Congress, along with all classified material.
And if a final accord is not submitted to Congress by July 9, the review period will snap back to 60 days. That would prevent the administration from intentionally delaying the submission of the accord to the Capitol. Congress could not reopen the mechanics of a deal, and taking no action would be the equivalent of allowing it to move forward.
Mr. Corker also agreed to a significant change on the terrorism language.
Initially, the bill said the president had to certify every 90 days that Iran no longer was supporting terrorism against Americans. If he could not, economic sanctions would be reimposed.
Under the agreement, the president would still have to send periodic reports to Congress on Iran’s activities regarding ballistic missiles and terrorism, but those reports could not trigger another round of sanctions.
The measure still faces hurdles. Senator Marco Rubio of Florida, fresh off the opening of his campaign for the Republican presidential nomination, dropped plans to push for an amendment to make any Iran deal dependent on the Islamic Republic’s recognition of the State of Israel, a diplomatic nonstarter.
But he hinted that he could try on the Senate floor.
“Not getting anything done plays right into the hands of the administration,” Mr. Rubio said.
Senator Ron Johnson, Republican of Wisconsin, abandoned an amendment to make any Iran accord into a formal international treaty needing two-thirds of the Senate for its ratification, but he, too, said it could be revived before the full Senate.
Mr. Earnest said the president also wanted no more changes. “We’re asking for a commitment that people will pursue the process that’s contemplated in this bill,” he said.
Democrats had implored Mr. Obama to embrace the legislation.
“If the administration can’t persuade 34 senators of whatever party that this agreement is worth proceeding with, then it’s really a bad agreement,” Senator Chris Coons of Delaware, a Democrat on the Foreign Relations Committee, said. “That’s the threshold.”
To temper opposition to the deal, Mr. Kerry, Treasury Secretary Jacob J. Lew and Energy Secretary Ernest J. Moniz gathered with senators Tuesday morning in a classified briefing, after a similar briefing on Monday for the House.
But the administration met firm opposition in both parties.
The agreement “puts Iran, the world’s worst state sponsor of terrorism, on the path to a nuclear weapon,” said Senator Tom Cotton, Republican of Arkansas, as he emerged from the briefing. “Whether that’s a matter of months or a matter of years, that’s a dangerous outcome not just to United States and allies like Israel but to the entire world.”
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
puts cryptogram.cyphertext

# cypher = CypherAnalysis.new(cyphertext: cryptogram.cyphertext, delimiter: " ")
cypher = CypherAnalysis.new(cyphertext: p_text.upcase, delimiter: " ")

puts "\nalphabet"
cy_alphabet = cypher.alphabet
p cy_alphabet
puts "\ncleaned words"
p cypher.words(:clean => true)
puts "\nenglish matches"
p cypher.percentage_of_english_words(cypher.words(:clean => true))
puts "\nletter freq"
cy_letter_freq = cypher.letter_freq
cy_letter_freq.each do |char, perc|
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
  if perc > 5
    t_str += " #{char}: #{perc}".red
  else
    t_str += " #{char}: #{perc}"
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
puts "\nmost common first letter"
p cypher.most_common_first_letter
puts "\ndouble_chars"
p cypher.double_chars
puts "\nmost_common_words_of_length(:length => 1)" # english: only "a" and "I"
p cypher.most_common_words_of_length(:length => 1)
puts "\nmost_common_words_of_length(:length => 2)"
p cypher.most_common_words_of_length(:length => 2)
puts "\nmost_common_words_of_length(:length => 3)"
p cypher.most_common_words_of_length(:length => 3)
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
#     known_cyphertext = "test"
#     expect(Cryptogram.encrypt({:plain_text => p_text, :seed => 123456})).to eq(known_cyphertext)
#   end
#
#   it "should decrypt" do
#     msg = p_text
#     cyphertext = Cryptogram.encrypt(msg)
#     expect(Cryptogram.decrypt({cyphertext: cyphertext})).to eq(msg)
#   end
# end
