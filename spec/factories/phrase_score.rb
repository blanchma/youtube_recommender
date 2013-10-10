# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :phrase_score do |f|
  f.user_id 1
  f.text "MyString"
  f.likes 1
  f.hates 1
  f.total 1
  f.p_like 1.5
  f.suppress_until "2010-05-07 17:31:16"
  f.p_unseen_cache 1.5
end
