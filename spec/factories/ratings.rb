# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :rating do |f|
  f.user_id 1
  f.video_id 1
  f.action "MyString"
end
