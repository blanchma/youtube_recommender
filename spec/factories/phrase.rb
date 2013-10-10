# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :phrase do |f|
  f.text "MyString"
  f.videos_count 1
end
