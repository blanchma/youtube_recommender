class Relation < ActiveRecord::Base    
    belongs_to :parent, :class_name => 'Phrase', :foreign_key => 'parent_id'
    belongs_to :child, :class_name => 'Phrase', :foreign_key => 'child_id'
end
