# direct ASCII translation
# purpose being to expose the viewer to ASCII, as a hint of what's to come.

class AsciiCrypto
  def self.encrypt(args)
    plaintext = args[:plaintext]
    crypt_text = []
    plaintext.split("").map do |c|
      ascii_num = "#{c.ord}"
      ascii_num = "0#{ascii_num}" if ascii_num.length == 2
      crypt_text << "#{ascii_num}"
    end
    crypt_text.join(" ")
  end

  def self.decrypt(args)
    cyphertext = args[:cyphertext]
    plaintext  = []
    cyphertext.split(" ").map do |o|
      the_char = o.sub(/^00/, "").to_i.chr
      plaintext << the_char
    end
    plaintext.join("")
  end

end

# ---

# plaintext = <<-PLAIN
# This is a pretty cool location to view from above,
# something a bit ironic in that...
# 32 08'59.96\" N, 110 50'09.03\" W
# PLAIN

plaintext = "message to encrypt!"

# plaintext = "https://www.google.com/maps/place/32%C2%B008%2760.0%22N+110%C2%B050%2709.0%22W/@32.1494121,-110.8332022,581m/data=!3m1!1e3!4m2!3m1!1s0x0:0x0"

puts "\nMESSAGE"
puts plaintext
puts "---"

cyphertext = AsciiCrypto.encrypt(:plaintext => plaintext)

# cyphertext = '067 104 114 105 115 032 084 111 114 115 116 101 110 115 111 110'

puts "\nCYPHER"
puts cyphertext
puts "---"

decrypted_msg = AsciiCrypto.decrypt({:cyphertext => cyphertext})

puts "\nDECRYPTED"
puts decrypted_msg
