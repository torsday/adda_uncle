
module WordList

  PERSONAL_LIST = %w[
    alexandra
    christopher
    craig
    dorothea
    elsa
    faye
    francisco
    is
    jeffrey
    message
    nicholas
    peter
    san
    secret
    tanya
    torstenson
  ]

  BIG_LIST = []
  txt_file = "word_list"
  File.readlines("words.txt").map do |line|
    BIG_LIST << line.strip
  end

  ALL = PERSONAL_LIST + BIG_LIST

end
