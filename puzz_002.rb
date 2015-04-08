# direct ASCII translation
# purpose being to expose the viewer to ASCII, as a hint of what's to come.

class AsciiCrypto
  def self.encrypt(args)
    plain_text = args[:plain_text]
    crypt_text = []
    plain_text.split("").map do |c|
      ascii_num = "#{c.ord}"
      ascii_num = "0#{ascii_num}" if ascii_num.length == 2
      crypt_text << "#{ascii_num}"
    end
    crypt_text.join(" ")
  end

  def self.decrypt(args)
    cypher_text = args[:cypher_text]
    plain_text  = []
    cypher_text.split(" ").map do |o|
      the_char = o.sub(/^00/, "").to_i.chr
      plain_text << the_char
    end
    plain_text.join("")
  end

end

# ---

# plain_text = <<-PLAIN
# This is a pretty cool location to view from above,
# something a bit ironic in that...
# 32 08'59.96\" N, 110 50'09.03\" W
# PLAIN

plain_text = "message to encrypt!"

# plain_text = "https://www.google.com/maps/place/32%C2%B008%2760.0%22N+110%C2%B050%2709.0%22W/@32.1494121,-110.8332022,581m/data=!3m1!1e3!4m2!3m1!1s0x0:0x0"

puts "\nMESSAGE"
puts plain_text
puts "---"

cypher_text = AsciiCrypto.encrypt(:plain_text => plain_text)

# cypher_text = '067 104 114 105 115 032 084 111 114 115 116 101 110 115 111 110'

puts "\nCYPHER"
puts cypher_text
puts "---"

decrypted_msg = AsciiCrypto.decrypt({:cypher_text => cypher_text})

puts "\nDECRYPTED"
puts decrypted_msg
