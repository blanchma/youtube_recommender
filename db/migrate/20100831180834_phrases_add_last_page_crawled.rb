class PhrasesAddLastPageCrawled < ActiveRecord::Migration
  def self.up
    add_column :phrases, :last_crawled_page, :integer, :default => 0
  end

  def self.down
    remove_column :phrases, :last_crawled_page
  end
end
