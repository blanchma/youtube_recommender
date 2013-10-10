class PhraseAddLastCrawledAt < ActiveRecord::Migration
  def self.up
    add_column :phrases, :last_crawled_at, :datetime
    Phrase.connection.update_sql("update phrases set last_crawled_at='2010-07-01 00:00:00'")
  end

  def self.down
    remove_column :phrases, :last_crawled_at
  end
end
