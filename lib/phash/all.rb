%w[audio image text video].each do |type|
  require "phash/#{type}"
end
