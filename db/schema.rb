# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111031194432) do

  create_table "audio_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.string   "location"
    t.string   "title"
    t.string   "description"
    t.integer  "rating",       :default => 0
    t.float    "size"
    t.integer  "listen_count", :default => 0
    t.integer  "hates",        :default => 0
    t.integer  "likes",        :default => 0
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audio_comments", ["video_id"], :name => "index_audio_comments_on_video_id"

  create_table "audio_ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "audio_comment_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audio_ratings", ["audio_comment_id"], :name => "index_audio_ratings_on_audio_comment_id"

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "category_ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.string   "action"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_scores", :force => true do |t|
    t.integer  "scoreable_id"
    t.integer  "category_id"
    t.integer  "likes",          :default => 0
    t.integer  "hates",          :default => 0
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scoreable_type"
  end

  create_table "channeled_videos", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "video_id"
    t.integer  "rating"
    t.string   "comment"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "channeled_videos", ["channel_id"], :name => "index_channeled_videos_on_channel_id"
  add_index "channeled_videos", ["video_id"], :name => "index_channeled_videos_on_video_id"

  create_table "channels", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.string   "category"
    t.integer  "category_id"
    t.integer  "score",       :default => 0
    t.integer  "likes",       :default => 0
    t.integer  "hates",       :default => 0
    t.integer  "visits",      :default => 0
    t.integer  "privacy",     :default => 2
    t.string   "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "channels", ["slug"], :name => "index_channels_on_slug", :unique => true

  create_table "communities", :force => true do |t|
    t.string   "name"
    t.boolean  "public"
    t.datetime "crawled_at", :default => '2011-08-25 19:29:17'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "event_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.string   "from"
    t.integer  "from_mtv_id"
    t.string   "from_external_id"
    t.string   "to"
    t.integer  "to_mtv_id"
    t.string   "to_external_id"
    t.integer  "video_id"
    t.string   "from_name"
    t.string   "to_name"
    t.integer  "recommendation_id"
  end

  add_index "events", ["from_mtv_id"], :name => "index_events_on_from_mtv_id"
  add_index "events", ["to_mtv_id"], :name => "index_events_on_to_mtv_id"

  create_table "facebook_recommendations", :force => true do |t|
    t.integer  "user_id"
    t.string   "post_id"
    t.string   "friend_id"
    t.string   "friend_username"
    t.string   "friend_pic_url"
    t.string   "youtube_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "watched",         :default => false
    t.string   "mynewtv_id"
    t.string   "friend_email"
  end

  create_table "favourites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follow_channels", :force => true do |t|
    t.integer  "user_id"
    t.string   "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", :id => false, :force => true do |t|
    t.integer "followed_id"
    t.integer "follower_id"
  end

  create_table "mail_invitations", :force => true do |t|
    t.integer  "from"
    t.string   "to"
    t.string   "to_email"
    t.string   "body"
    t.boolean  "sended"
    t.datetime "created_at"
    t.datetime "sended_at"
  end

  create_table "mynewtv_recommendations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", :force => true do |t|
    t.integer  "priority"
    t.string   "message"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phrase_scores", :force => true do |t|
    t.integer  "scoreable_id"
    t.string   "text"
    t.integer  "likes",            :default => 0
    t.integer  "hates",            :default => 0
    t.integer  "total",            :default => 0
    t.float    "p_like",           :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "p_weighted_cache", :default => 0.0
    t.float    "p_tanh_cache",     :default => 0.0
    t.float    "weight",           :default => 0.0
    t.integer  "phrase_id"
    t.string   "scoreable_type"
    t.float    "p_rare_cache"
    t.string   "source"
  end

  add_index "phrase_scores", ["phrase_id"], :name => "index_phrase_scores_on_phrase_id"
  add_index "phrase_scores", ["scoreable_id"], :name => "update_token_index"

  create_table "phrases", :force => true do |t|
    t.string   "text"
    t.integer  "videos_count",      :default => 0
    t.float    "idf",               :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_crawled_at"
    t.integer  "last_crawled_page", :default => 0
    t.boolean  "is_category"
  end

  add_index "phrases", ["text"], :name => "index_phrases_on_text"
  add_index "phrases", ["text"], :name => "index_video_words_on_text", :unique => true
  add_index "phrases", ["videos_count"], :name => "index_phrases_on_videos_count"

  create_table "phrases_videos", :id => false, :force => true do |t|
    t.integer "video_id"
    t.integer "phrase_id"
  end

  add_index "phrases_videos", ["phrase_id"], :name => "index_phrases_videos_on_phrase_id"
  add_index "phrases_videos", ["phrase_id"], :name => "index_video_words_videos_on_video_word_id"
  add_index "phrases_videos", ["video_id"], :name => "index_phrases_videos_on_video_id"
  add_index "phrases_videos", ["video_id"], :name => "index_video_words_videos_on_video_id"

  create_table "playlists", :force => true do |t|
    t.integer  "user_id"
    t.float    "avg_score"
    t.integer  "lifecount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.string   "message"
    t.string   "external_id"
    t.string   "service"
    t.boolean  "published",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",       :default => 0
  end

  create_table "rating_channels", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.integer  "channel_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "video_id"
    t.string   "action"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "video_score",     :default => 0.0
    t.string   "source"
    t.integer  "user_channel_id"
    t.integer  "category_id"
  end

  create_table "relations", :id => false, :force => true do |t|
    t.integer "parent_id"
    t.integer "child_id"
  end

  create_table "user_rates", :force => true do |t|
    t.integer  "scoreable_id"
    t.integer  "likes",          :default => 0
    t.float    "avg_liked",      :default => 0.0
    t.integer  "hates",          :default => 0
    t.float    "avg_hated",      :default => 0.0
    t.integer  "views",          :default => 0
    t.float    "avg_watched",    :default => 0.0
    t.integer  "skips",          :default => 0
    t.float    "avg_skipped",    :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scoreable_type"
  end

  create_table "user_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",                    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",                    :null => false
    t.string   "password_salt",                       :default => "",                    :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "old_crypted_password"
    t.string   "old_password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                               :default => false
    t.boolean  "debug",                               :default => false
    t.integer  "fb_uid",               :limit => 8
    t.string   "fb_token",             :limit => 149
    t.boolean  "publish_to_fb",                       :default => true
    t.datetime "activated_at"
    t.string   "custom_nickname"
    t.boolean  "private_channel",                     :default => false
    t.datetime "crawled_at",                          :default => '2011-08-25 19:29:15'
    t.datetime "raked_at",                            :default => '2011-08-25 19:29:20'
    t.datetime "search_recs_at"
    t.string   "tw_uid"
    t.string   "tw_token"
    t.string   "tw_secret"
    t.boolean  "publish_to_tw"
    t.string   "slug"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["custom_nickname"], :name => "index_users_on_custom_nickname", :unique => true
  add_index "users", ["fb_uid"], :name => "index_users_on_oauth2_uid", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

  create_table "videos", :force => true do |t|
    t.string   "youtube_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "keywords"
    t.integer  "keywords_count"
    t.integer  "duration"
    t.boolean  "racy"
    t.time     "published_at"
    t.string   "categories"
    t.string   "author"
    t.string   "thumb_url"
    t.string   "thumb_big_url"
    t.integer  "rating_min",     :default => 1
    t.integer  "rating_max",     :default => 5
    t.float    "rating_avg"
    t.integer  "rating_count"
    t.integer  "view_count"
    t.integer  "favorite_count"
    t.float    "rating_score"
    t.float    "views_score"
    t.integer  "category_id"
    t.boolean  "delta",          :default => true, :null => false
    t.string   "slug"
  end

  add_index "videos", ["category_id"], :name => "index_videos_on_category_id"
  add_index "videos", ["created_at"], :name => "index_videos_on_created_at"
  add_index "videos", ["description"], :name => "index_videos_on_description"
  add_index "videos", ["keywords"], :name => "index_videos_on_keywords"
  add_index "videos", ["slug"], :name => "index_videos_on_slug", :unique => true
  add_index "videos", ["title"], :name => "index_videos_on_title"
  add_index "videos", ["youtube_id"], :name => "index_videos_on_youtube_id", :unique => true

  create_table "videos_youtube_users", :id => false, :force => true do |t|
    t.integer "youtube_user_id"
    t.integer "video_id"
  end

  add_index "videos_youtube_users", ["video_id"], :name => "index_videos_youtube_users_on_video_id"
  add_index "videos_youtube_users", ["youtube_user_id"], :name => "index_videos_youtube_users_on_youtube_user_id"

  create_table "youtube_users", :force => true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
