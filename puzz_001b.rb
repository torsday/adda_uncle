# Cryptogram Cypher
#
# Unlike a caesar cypher, the key isn't a rotated alphabet, rather a random monoalphabet key.
# TODO: create decrypter, without knowing the key
# basic implementation: only letters, no numbers, or symbols
# decrypts by going through the 26 possible results, returning the translation
# containing the most engligh (and personal) words

require_relative 'word_list'

class FrequencyAnalysis

  ENGLISH_LETTER_FREQUENCY_OVERALL = {
      A: 8.167,
      B: 1.492,
      C: 2.782,
      D: 4.253,
      E: 12.702,
      F: 2.228,
      G: 2.015,
      H: 6.094,
      I: 6.966,
      J: 0.153,
      K: 0.772,
      L: 4.025,
      M: 2.406,
      N: 6.749,
      O: 7.507,
      P: 1.929,
      Q: 0.095,
      R: 5.987,
      S: 6.327,
      T: 9.056,
      U: 2.758,
      V: 0.978,
      W: 2.360,
      X: 0.150,
      Y: 1.974,
      Z: 0.074
  }

  ENGLISH_LETTER_FREQUENCY_FIRST_LETTER = {
      A: 11.682,
      B: 4.434,
      C: 5.238,
      D: 3.174,
      E: 2.799,
      F: 4.027,
      G: 1.642,
      H: 4.200,
      I: 7.294,
      J: 0.511,
      K: 0.456,
      L: 2.415,
      M: 3.826,
      N: 2.284,
      O: 7.631,
      P: 4.319,
      Q: 0.222,
      R: 2.826,
      S: 6.686,
      T: 15.978,
      U: 1.183,
      V: 0.824,
      W: 5.497,
      X: 0.045,
      Y: 0.763,
      Z: 0.045
  }

  def self.getWordRatios(_string)
    freq_rats_ints = Hash.new
    freq_rats_perc = Hash.new
    total_chars = 0

    _string.split(" ").each do |word|
      total_chars += 1
      if (freq_rats_ints[word])
        freq_rats_ints[word] += 1
      else
        freq_rats_ints[word] = 1
      end
    end

    freq_rats_ints.each do |word, count|
      if (count > 1)
        perc_frequency = (count.to_f / total_chars) * 100
        next unless perc_frequency > 1
        freq_rats_perc[word] = perc_frequency.round(2)
      end
    end

    freq_rats_perc.sort_by {|_key, value| value}.to_h
  end

  def self.getFirstCharOfAllWords(_string)
    _string.split(" ").inject("") do |str_of_chars, word|
      str_of_chars + word[0]
    end
  end

  def self.getCharacterRatios(_string)
    freq_rats_ints = Hash.new
    freq_rats_perc = Hash.new
    total_chars = 0

    _string.split("").each do |char|
      next unless char =~ /[A-Za-z]/
      total_chars += 1
      if (freq_rats_ints[char])
        freq_rats_ints[char] += 1
      else
        freq_rats_ints[char] = 1
      end
    end
    
    freq_rats_ints.each do |char, num_found|
      rat = (num_found.to_f / total_chars) * 100
      freq_rats_perc[char] = rat.round(3)
    end

    freq_rats_perc.sort_by {|_key, value| value}.to_h
  end


end

class Cryptogram
  def self.encrypt(args)
    plain_text = args[:plain_text].upcase
    alphabet = ("A".."Z").to_a
    key = Hash[alphabet.zip(alphabet.shuffle)]
    key[" "] = " "
    key["."] = "."
    cipher_text = plain_text.each_char.inject("") do |encrypted, char|
      if key[char]
        encrypted + key[char]
      else
        encrypted + char
      end
    end
    return {
        :text => cipher_text,
        :key  => key
    }
  end

  def self.decrypt(args)
    text = args[:cypher_text]
    key  = args[:key].invert

    text.each_char.inject("") do |encrypted, char|
        if key[char]
            encrypted + key[char]
        else
            encrypted + char
        end
    end
end

  def self.num_of_english_words(str)
    arr = str.upcase.split(" ")
    count = 0
    arr.each do |w|
      count += 1 if WordList::ALL.include?(w)
    end
    count
  end

  def self.pruneNumAndSymFromString(_string)
    finalStr = _string.upcase
    # finalStr = swapPeriodsWithSpaces(finalStr)
    # finalStr = swapNewlinesWithSpaces(finalStr)
    # finalStr = removeSymbols(finalStr)
    # finalStr = removeNumbers(finalStr)
    finalStr = cleanSpaces(finalStr)

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

def printHash(_hash)
  _hash.each do |key, val|
    puts "#{key}: #{val}"
  end
end

# ---

known_words = WordList::ALL

birches = <<-MSG
When I see birches bend to left and right
Across the lines of straighter darker trees,
I like to think some boy's been swinging them.
But swinging doesn't bend them down to stay
As ice-storms do. Often you must have seen them
Loaded with ice a sunny winter morning
After a rain. They click upon themselves
As the breeze rises, and turn many-colored
As the stir cracks and crazes their enamel.
Soon the sun's warmth makes them shed crystal shells
Shattering and avalanching on the snow-crust—
Such heaps of broken glass to sweep away
You'd think the inner dome of heaven had fallen.
They are dragged to the withered bracken by the load,
And they seem not to break; though once they are bowed
So low for long, they never right themselves:
You may see their trunks arching in the woods
Years afterwards, trailing their leaves on the ground
Like girls on hands and knees that throw their hair
Before them over their heads to dry in the sun.
But I was going to say when Truth broke in
With all her matter-of-fact about the ice-storm
I should prefer to have some boy bend them
As he went out and in to fetch the cows—
Some boy too far from town to learn baseball,
Whose only play was what he found himself,
Summer or winter, and could play alone.
One by one he subdued his father's trees
By riding them down over and over again
Until he took the stiffness out of them,
And not one but hung limp, not one was left
For him to conquer. He learned all there was
To learn about not launching out too soon
And so not carrying the tree away
Clear to the ground. He always kept his poise
To the top branches, climbing carefully
With the same pains you use to fill a cup
Up to the brim, and even above the brim.
Then he flung outward, feet first, with a swish,
Kicking his way down through the air to the ground.
So was I once myself a swinger of birches.
And so I dream of going back to be.
It's when I'm weary of considerations,
And life is too much like a pathless wood
Where your face burns and tickles with the cobwebs
Broken across it, and one eye is weeping
From a twig's having lashed across it open.
I'd like to get away from earth awhile
And then come back to it and begin over.
May no fate willfully misunderstand me
And half grant what I wish and snatch me away
Not to return. Earth's the right place for love:
I don't know where it's likely to go better.
I'd like to go by climbing a birch tree,
And climb black branches up a snow-white trunk
Toward heaven, till the tree could bear no more,
But dipped its top and set me down again.
That would be good both going and coming back.
One could do worse than be a swinger of birches.
MSG

message = <<-MSG
I risk it for the freedom, to see what is true, what I really want in the
deepest part of myself. I can make whatever choices I want in my life,
and I will live with the consequences of those choices. But if I want to
live a life close to my deepest desires, I have to risk knowing who I
really am and have always been. Knowing this, then I can choose.
MSG

invitation = <<-MSG
Interested in cryptography? Cryptograms? Come to this thursday's lunch and learn and dive into cryptography from ancient times through the early twentieth century. Find us at Point Hope at three.
MSG

cleaned_plaintext = Cryptogram.pruneNumAndSymFromString(birches.upcase)

encrypted_result = Cryptogram.encrypt({:plain_text => cleaned_plaintext, :rot => 11})

puts "\nPLAIN TEXT"
p cleaned_plaintext
puts "---"

puts "\nCYPHER TEXT"
puts encrypted_result[:text]
puts "---"

puts "\nFrequency Analysis: All Characters"
printHash(FrequencyAnalysis.getCharacterRatios(encrypted_result[:text]))
puts "---"

puts "\nFrequency Analysis: First Char of words"
printHash(FrequencyAnalysis.getCharacterRatios(FrequencyAnalysis.getFirstCharOfAllWords(encrypted_result[:text])))
puts "---"

puts "\nFrequency Analysis: Word counts"
printHash(FrequencyAnalysis.getWordRatios(encrypted_result[:text]))
puts "---"

puts "\nCIPHER Key"
printHash(encrypted_result[:key])
puts "---"

puts "\nDeCIPHER Key"
decipher_key = encrypted_result[:key].invert
printHash(decipher_key.sort_by {|_key, value| _key}.to_h)


puts "---"

decrypted_msg = Cryptogram.decrypt({:cypher_text => encrypted_result[:text], :key => encrypted_result[:key]})

puts "\nDECRYPTED"
puts decrypted_msg
