

class Encryptor
  attr_reader :plaintext
  def initialize(args)
    @plaintext = args[:plaintext].downcase
  end
  def cyphertext
    alphabet      = ("a".."z").to_a
    alphabet      += [" "]
    crypto_seed   = Random.new(1234)
    # crypto_seed ||= Random.new
    key           = Hash[alphabet.zip(alphabet.shuffle(random: crypto_seed))]

    c_text = plaintext.each_char.inject("") do |encrypted, char|
      if key[char]
        encrypted + key[char]
      else
        encrypted + char
      end
    end
    return c_text
  end
end

class Decryptor
  attr_reader :cyphertext
  attr_accessor :key
  def initialize(args)
    @cyphertext = args[:cyphertext].upcase
    @key = Hash.new
  end

  def plaintext
    decrypt_with_key(cyphertext)
  end

  def generate_key
    # set most common char to " "
    first_most_common_char = most_common_chars[0]
    key[first_most_common_char] = " "

    # set second most common char to e
    second_most_common_char = most_common_chars[1]
    key[second_most_common_char] = "e"

    # set most common single char word to a
    c = most_common_words_of_length(1)[0]
    key[c] = "a"

    # # set second most common single char word to i
    # c = most_common_words_of_length(1)[1]
    # key[c] = "i"

    # look at most common 3 letter words
    # now that we have a and e set, we should be able to find "the" and "and"
    top_5_most_common_3_letter_words = most_common_words_of_length(3)[0..5]
    the_var = top_5_most_common_3_letter_words.select{|w| decrypt_with_key(w)[2] == 'e'}.first
    key[the_var[0]] = "t"
    key[the_var[1]] = "h"
    and_var = top_5_most_common_3_letter_words.select{|w| decrypt_with_key(w)[0] == 'a'}.first
    key[and_var[1]] = "n"
    key[and_var[2]] = "d"

    # Look for special words...

    # get "w" from "t*eeted"
    word_pool = most_common_words_of_length(7)
    word_pool += most_common_words_of_length(8) # account for symbols
    tweeted_var = word_pool.select do |w|
      p_word = decrypt_with_key(w)
      # p_word[0] == 't' && p_word[2..6] == 'eeted'
      p_word =~ /t.eeted/
    end
    if tweeted_var = tweeted_var.first
      key[tweeted_var[1]] = 'w'
    end

    # get "s" from "*enate"
    word_pool = most_common_words_of_length(6)
    word_pool += most_common_words_of_length(7) # account for symbols
    senate_var = word_pool.select do |w|
      p_word = decrypt_with_key(w)
      # p_word[1..5] == 'enate'
      p_word =~ /.enate/
    end
    if senate_var = senate_var.first
      key[senate_var[0]] = 's'
    end

    # get "i" from "wh*te"
    word_pool = most_common_words_of_length(5)
    word_pool += most_common_words_of_length(6) # account for symbols
    white_var = word_pool.select do |w|
      p_word = decrypt_with_key(w)
      # p_word[0..1] == 'wh' && p_word[3..4] == 'te'
      p_word =~ /wh.te/
    end
    if white_var = white_var.first
      key[white_var[2]] = 'i'
    end

    # get 'b' from '*etween'
    word_pool = most_common_words_of_length(7)
    word_pool += most_common_words_of_length(8) # account for symbols
    wrd_var = word_pool.select do |w|
      p_word = decrypt_with_key(w)
      p_word =~ /.etween/
    end
    if wrd_var = wrd_var.first
      key[wrd_var[0]] = 'b'
    end

    # r w/ whethe.
    word_pool = most_common_words_of_length(7)
    word_pool += most_common_words_of_length(8) # account for symbols
    wrd_var = word_pool.select do |w|
      p_word = decrypt_with_key(w)
      p_word =~ /whethe./
    end
    if wrd_var = wrd_var.first
      key[wrd_var[6]] = 'r'
    end

    # l w/ is.and
    word_pool = most_common_words_of_length(6)
    word_pool += most_common_words_of_length(7) # account for symbols
    wrd_var = word_pool.select do |w|
      p_word = decrypt_with_key(w)
      p_word =~ /is.and/
    end
    if wrd_var = wrd_var.first
      key[wrd_var[2]] = 'l'
    end


  end

  # INPUT: a cypher string
  # OUTPUT: a string, with what can be decrypted with the current key
  def decrypt_with_key(c_str)
    c_str = c_str.upcase
    p_text = c_str.each_char.inject("") do |decrypted, char|
      if key[char]
        decrypted + key[char]
      else
        decrypted + char
      end
    end
    return p_text
  end

  # ---

  def most_common_chars
    chars = {}
    cyphertext.each_char do |c|
      chars[c] ||= 0
      chars[c] += 1
    end
    sorted_arr = chars.sort_by{|key,value| value}.reverse.to_h.keys
    sorted_arr
  end

  def most_common_words_of_length(l_int)
    length = l_int
    results = {}
    delimiter = most_common_chars[0]

    word_pool = cyphertext.split(delimiter)

    words_of_x_length = word_pool.select {|word| word.length == length}
    words_of_x_length.each {|w| results[w] = 0}
    words_of_x_length.each {|w| results[w] += 1}
    results.sort_by{|key,value|value}.reverse.to_h.keys
  end

  def temp
    most_common_words_of_length(4).each{|x| p decrypt_with_key(x)}
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


# ---

cyphertext = Encryptor.new(
  :plaintext => p_text
).cyphertext

decryptee = Decryptor.new(
  :cyphertext => cyphertext
)

decryptee.generate_key
key             = decryptee.key
decyphered_text = decryptee.plaintext


# puts "\nPLAINTEXT"
# p p_text.downcase
puts "\nKEY"
p key
puts "\nPLAINTEXT"
p decyphered_text
puts "\nTRIPLE CHAR WORDS DECRYPTED"
p decryptee.temp
