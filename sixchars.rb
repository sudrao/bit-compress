#!/usr/local/bin/ruby
def plain(inp)
  result = ""
  inp.each do |ch|
    b = ch.chr
    if ((b >= 'A') && (b <= 'Z')) || ((b >= 'a') && (b <= 'z'))
      result += b
    else
      result += ((ch & 0xf) | 'a'.ord).chr
    end
  end
  result
end

def rand_url
srand
xx = rand * 100.0
six_chars = []
ipart = xx.to_i
six_chars << ipart
xx = (xx - ipart) * 100.0
ipart = xx.to_i
six_chars << ipart
xx = (xx - ipart) * 100.0
ipart = xx.to_i
six_chars << ipart
xx = (xx - ipart) * 100.0
ipart = xx.to_i
six_chars << ipart
xx = (xx - ipart) * 100.0
ipart = xx.to_i
six_chars << ipart
xx = (xx - ipart) * 100.0
ipart = xx.to_i
six_chars << ipart

plain(six_chars)
end

