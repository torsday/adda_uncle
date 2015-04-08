# direct ASCII translation
# with the ability to set the radix (e.g. base 2, 10, 16... up to 35)
# goal: don't take base 10 for granted with numbers

require_relative 'word_list'

class AsciiCrypto
  def self.encrypt(args)
    plain_text = args[:plain_text]
    radix = args[:radix].to_i || 10
    crypt_text = []
    plain_text.split("").map do |c|
      ascii_num = c.ord
      ascii_num = ascii_num.to_i # make sure it's a num, because ruby
      ascii_num = ascii_num.to_s(radix)

      # puts ascii_num
      crypt_text << "#{ascii_num}"
    end
    self.equilize_num_length(crypt_text.join(" "))
  end

  # given an ascii translation, but not the radix
  def self.decrypt(args)
    cypher_text = args[:cypher_text]
    cypher_alphabet = self.used_chars(:text => cypher_text)
    cypher_alphabet.delete(" ")
    min_radix = cypher_alphabet.length

    decrypted_msgs = []

    (min_radix..36).each do |radix|
      plain_text  = []
      cypher_arr = cypher_text.split(" ")
      cypher_arr.map do |o|
        o = o.sub(/^00/, "") # remove leading zeros
        o = o.to_s # make into string, because we need it there for radix trans
        o = o.to_i(radix) # adjust for radix
        if o > 255
          # "o out of bounds! #{o} with radix #{radix}"
          break
        end
        begin
          the_char = o.chr
        rescue
          raise "char too high? #{o}"
        end
        plain_text << the_char
      end
      decrypted_msgs << plain_text.join("")
    end

    highest_num_of_eng_words(decrypted_msgs)
  end

  def self.used_chars(args)
    text = args[:text]
    results = {}
    text.split("").each do |x|
      results[x] ||= 1
      results[x] += results[x]
    end
    results.keys.sort
  end

  def self.num_of_english_words(str)
    arr = str.downcase.split(" ")
    count = 0
    arr.each do |w|
      count += 1 if WordList::ALL.include?(w)
    end
    count
  end

  def self.highest_num_of_eng_words(arr_of_potential_answers)
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

  def self.equilize_num_length(crypto_text)
    greatest_length = 0
    crypto_text.split(" ").each do |x|
      l = x.length
      if l > greatest_length
        greatest_length = l
      end
    end

    equalized_arr = []
    crypto_text.split(" ").each do |x|
      l_diff = greatest_length - x.length
      equalized_arr << "#{'0' * l_diff}#{x}"
    end
    equalized_arr.join(" ")
  end

end

# ---

MY_RADIX = 2 + rand(34)

plain_text = <<-PLAIN
Set thy heart upon thy work, but never on its reward.
Work not for a reward; but never cease to do thy work.
PLAIN

puts "\nMESSAGE"
puts plain_text
puts "---"

cypher_text = AsciiCrypto.encrypt(:plain_text => plain_text, :radix => MY_RADIX)

puts "\nCYPHER"
puts cypher_text
puts "---"

puts "\nCYPHER ALPHABET"
cypher_alphabet = AsciiCrypto.used_chars(:text => cypher_text)
cypher_alphabet.delete(" ")
p cypher_alphabet
p cypher_alphabet.length
puts "---"

puts "\nDECRYPTED"
decrypted_msg = AsciiCrypto.decrypt({:cypher_text => cypher_text})
puts "#{decrypted_msg}"
