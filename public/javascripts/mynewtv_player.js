
var MynewtvVideoList = Class.create({
    initialize: function(arrayOfAttributes) {
        this.className = 'MynewtvVideoList';
        this._videos = new Hash;
        this._playlistIds = [];
        this._searchlistIds = [];
        this.append(arrayOfAttributes,true);
    },

    ids: function (){
        return this._playlistIds;
    },

    first: function(n) {
        return this.videos().first();
    },

    last: function() {
        return this.videos().last();
    },

    previous: function (videoId) {
        var prevIndex = this._playlistIds.indexOf(videoId) - 1;
        if (prevIndex >= 0) {
            var prevVideoId = this._playlistIds[prevIndex];
            return this.get(prevVideoId);
        }

    },

    next: function (videoId) {
        var nextIndex = this._playlistIds.indexOf(videoId) + 1;
        var nextVideoId = this._playlistIds[nextIndex];
        return this.get(nextVideoId);
    },

    empty: function() {
        if (this._videos) {
            if (!this._videos.size() > 0) {
                return true;
            }
        }
        return false;
    },

    get: function(videoId) {
        return this._videos.get(videoId);
    },

    addToSearchlist: function(arrayOfAttributes) {
        arrayOfAttributes.each(function(attributes){
            var v = new MynewtvVideo(attributes);
            // make sure we're not ahdding a dupe!
            if (!this._searchlistIds.include(v.id) && !this._playlistIds.include(v.id) ) {
                if (!MynewtvVideo.currentVideo || MynewtvVideo.currentVideo.id != v.id) {
                    this._videos.set(v.id, v);
                    this._searchlistIds.push(v.id);
                } else {
           
                }
            }
        }, this);
    },

  

    append: function(arrayOfAttributes) {
        var result = [];
                
        if (typeof arrayOfAttributes.push == "function" ) {
                
            arrayOfAttributes.each(function(attributes){
                var v = new MynewtvVideo(attributes);
                // make sure we're not adding a dupe!
                if (!this._playlistIds.include(v.id)) {
                    if (!MynewtvVideo.currentVideo || MynewtvVideo.currentVideo.id != v.id) {
                        this._videos.set(v.id, v);
                        this._playlistIds.push(v.id);
                        result.push(v);
                    }
                }else{
                    result.push(this.get(v.id) ) 
                }
            }, this);
        }
        else //In case of JSON
        {
            var v = new MynewtvVideo(arrayOfAttributes);
            // make sure we're not adding a dupe!
            if (!this._playlistIds.include(v.id)) {
                this._videos.set(v.id, v);
                this._playlistIds.push(v.id);
                result.push(v);
            }
            else {
                result.push(this.get(v.id) ) ;
            }
        }
        
        return result;
    },

    prepend: function(arrayOfAttributes) {
        var result = [];
        arrayOfAttributes.each(function(attributes){
            var v = new MynewtvVideo(attributes);
            // make sure we're not adding a dupe!
            if (!this._playlistIds.include(v.id)) {
                if (!MynewtvVideo.currentVideo || MynewtvVideo.currentVideo.id != v.id) {
                    this._videos.set(v.id, v);
                    this._playlistIds.unshift(v.id);
                    result.push(v);
                }

            }
        }, this);
        return result;
    },


    clearSearchList: function () {
        for (var i = 0; i < this._playlistIds.length; i++) {
            video = this._videos.get(this._playlistIds[i]);
            //console.log("id= "+ video.id);
        }
        this._searchlistIds = [];
    },

    index: function (videoId) {
        return this._playlistIds.indexOf(videoId);
    },


    unset: function(videoId) {
        this._playlistIds = this._playlistIds.reject(function(id){
            return id == videoId;
        });
        this._searchlistIds = this._searchlistIds.reject(function(id){
            return id == videoId;
        });
        return this._videos.unset(videoId);
    },

    unshift: function(video) {
        this._playlistIds.unshift(video.id);
        this._videos.set(video.id, video);
    },

    _each: function(iterator) {
        var i;
        var length = this._searchlistIds.length;
        for ( i=0; i < length; i++) {
            var id = this._searchlistIds[i];
            var vid = this._videos.get(id);
            iterator(vid);
        }

        var length = this._playlistIds.length;
        for ( i=0; i < length; i++) {
            var id = this._playlistIds[i];
            var vid = this._videos.get(id);
            iterator(vid);
        }

    },

    videosPlayList: function() {
        return this._playlistIds.collect(function(id){
            return this._videos.get(id);
        },this);
    },

    videosSearchList: function() {
        return this._searchlistIds.collect(function(id){
            return this._videos.get(id);
        },this);
    },

    videos: function() {
        var videos = [];
        var index = 0;

        this._searchlistIds.each(function(id){
            videos [index] = this._videos.get(id);
            index++;
        },this);

        this._playlistIds.each(function(id){
            videos [index] = this._videos.get(id);
            index++;
        },this);


        return videos;
    },

    playlistSize: function () {
        return this._playlistIds.size();
    }


});
Object.extend(MynewtvVideoList.prototype, Enumerable);

var MynewtvVideo = Class.create({
    initialize: function(attributes) {
        this.id          = "";
        this.youtube_id  = "";
        this.title       = "";
        this.keywords    = "";
        this.views       = 0;
        this.rating      = null;
        this.favorites   = 0;
        this.scores      = {};

        this.from     = "";

        this.more = "";

        this.phrases_score = 0.0;
        this.score         = 0.0;


        $H(attributes).each(function(pair) {
            this[pair.key] = pair.value;
        }, this);

    },

    linkToPlay: function() {
        var _function = "Mynewtv.cueAlternateVideoId("+this.id+");return false;"
        return _function;
    },

    linkToSkipVideo: function () {
        var _function = "Mynewtv.skipVideo("+this.id+");$('li_"+this.id+"').remove();return false;";
        return _function; //escape(_function);
    },

    setThumb: function (img) {
        this.thumb_url=img;
    },

    linkToThumb: function() {
        var click = linkToPlay();
        var thumb = this.thumbnailImg();
        var a = new Element('a', {
            'href':'#',
            'onClick': click
        }).update(thumb);
        return a;
    },

    titleP: function() {
        titlerized = this.title.length > 40 ? this.title.substring(0,40) + '...' : this.title;
        return "<p class='title' title='"+this.title+"'>"+ titlerized +"</p>";
        //return new Element('p', {'class': 'title'}).update(this.title);
    },

    authorP: function() {
        return "<p class='author'>By: "+ this.author +"</p>";
        //return new Element('p', {'class': 'author'}).update("By: "+this.author);
    },

    thumbnailImg: function() {
        //  var img = new Element('img', {'src': this.thumb_url, 'width':'106', 'height':'89'});
        var img = "<img id='img_v"+this.id+"' src='"+ this.thumb_url+"' width='130' height='100' onerror='imgError(this);' />";
        return img;
    },


    friendImg: function() {
        var img = "<img title='"+ this.more.friend_username +"' src='"+ this.more.friend_pic_url+"' width='50' heigh='50'/>";
        return img;
    },


    youtubeUrl: function() {
        return "http://youtube.com/watch?v="+this.youtube_id;
    },

    mynewtvUrl: function() {
        if (userId) {
            return "http://mynew.tv/v/" + this.id +"?user_id=" + userId;
        }
        else if (this.more && this.more.user_id) {
            return "http://mynew.tv/v/" + this.id +"?user_id=" + this.more.user_id;
        }
        else
        {
            return "http://mynew.tv/v/" + this.id;
        }
    },

    durationHumanized: function(duration) {
        var hours   = Math.floor(duration/3600);
        var minutes = Math.floor((duration - (hours*3600))/60);
        var seconds = duration - (hours*3600) - (minutes*60);

        hours   = this.doubleDigits(hours);
        minutes = this.doubleDigits(minutes);
        seconds = this.doubleDigits(seconds);

        if (hours != "00") {
            return hours+":"+minutes+":"+seconds;
        } else {
            return minutes+":"+seconds;
        }
    },

    doubleDigits: function(x) {
        if (x==0) {
            return "00";
        } else if (x < 10) {
            return "0"+x;
        } else {
            return x;
        }
    },

    setPageFields: function() {
        this.setTitle();
        this.setDuration();
        if ( userOnDebug == true) {
            this.setKeywords();
            this.setCategory();        
            this.setExplanation();
            this.setQuery();
            this.setPostForm();
            this.addDebugTable();
            this.addDebugPhraseScores();
        }
    },


    setPostForm: function() {
        if ($('post_form')) {
            this.setPostFormVideoId();
            $('post_form_message').update('Share this video on Facebook!');
            $('post_submit').enable();
            $('post_message').value="Check this out!";
            $('new_post').show();
        }
    },

    setPostFormVideoId: function() {
        if ($('post_video_id')) {
            $('post_video_id').value = this.id;
        }
    },

    setTitle: function() {
        this.setField('title', this.title);
    },

    setKeywords: function() {
        this.setField('keywords', 'Keywords: '+this.keywords);
    },

    setCategory: function() {
        this.setField('category', 'Category: '+this.categories);
    },

    setDescription: function() {
        this.setField('description', 'Description: '+this.keywords);
    },

    setDuration: function(currentTime, totalTime) {
        currentTime = typeof(currentTime) != 'undefined' ? currentTime : 0;
        var current = this.durationHumanized(currentTime);


        var total   = this.durationHumanized(this.duration);
        this.setField('duration', current+" / "+total);
    },

    setExplanation: function() {
        this.setField('explanation', '<b>'+this.title + '</b><br/>score= '+ this.score + '<br/>category_score= ' + this.category_score + '('+this.categories+ ') <br/>rating_score= ' + this.rating_score + '<br/>views_score= ' + this.rating_score + '<br/>avg_phrase_score= ' + this.phrases_score + ' <br/> tags <div id="tags">'+ this.words_debug + '</div>');

    },

    setQuery: function() {
        queryWords = "";
        if (this.queryWords != undefined || this.queryWords != null) {
            this.queryWords.each (function(phrase) {
                queryWords += phrase.text;
            });
        }
        this.setField('query', queryWords);

    },

    setField: function(fieldName, value) {
        var elem = $(fieldName);
        if (elem) {
            elem.update(value);
        }
    },

    addDebugTable: function() {
        var tbody  = $('debug_table_rows');

        if (tbody) {
            // clear it
            tbody.update();
            this.debugTableRows().each(function(row){
                tbody.insert(row);
            });
        }
    },

    debugTableRows: function() {
        if (this.debug_result_rows) {

            trs = this.debug_result_rows.collect(function(row){
                tr = new Element('tr');
                [ //new Element('td').update(row.ferret_rank),
                    new Element('td').update(row.title),
                    new Element('td').update("<a href='"+row.youtube+"' target='_target'>link</a>" ),
                    new Element('td').update(row.score),
                    new Element('td').update(row.views_score + " (" + row.views_score_c + ")" ),
                    new Element('td').update(row.rating_score + " (" + row.rating_score_c + ")" ),
                    new Element('td').update(row.category_score + " (" + row.category_score_c + ") - " + row.category ),
                    new Element('td').update(row.phrases_score  + " (" + row.phrases_score_c + ")" ),
                    new Element('td').update("<div id='tags'>" + row.tags + "</div>")
                ].each(function(td){
                    tr.insert(td);
                });
                return tr;
            });
            return trs;
        } else {
            return [];
        }
    },

    addDebugPhraseScores: function() {
        var parent = $('phrase_scores_searched');
        if (parent && this && this.phrase_scores_searched) {
            parent.update('');
            var elems = [];
            var phrase_score;
            this.phrase_scores_searched.each(function(phrase_score) {
                elems.push(this.debugPhraseScore(phrase_score));
            }.bind(this));
            elems.each(function(el) {
                parent.insert(el);
            });
        }
    },

    debugPhraseScore: function(phrase_score) {
        var div = new Element('div', {
            id: "phrase_score_"+phrase_score.phrase_id
        });

        var toggle_link = new Element('a', {
            'href':'#',
            'onclick':'$("phrase_score_hits_'+phrase_score.phrase_id+'").toggle();return false;'
        });
        var count = phrase_score.top_hits.size();
        toggle_link.update(count+" top hits");
        div.insert(toggle_link);
        // if (phrase_score.top_hits.size() > 0) {
        //   div.insert("&nbsp;&nbsp;&nbsp;("+phrase_score.top_hits.first().score+" highest)");
        // }
        div.insert("&nbsp;&nbsp;&nbsp; "+ phrase_score.label   );


        var table = new Element('table', {
            'id': "phrase_score_hits_"+phrase_score.phrase_id,
            'class':'phrase_score_hits'
        });
        var tbody = new Element('tbody');

        var thead = "<thead><th>Score</th><th>Title</th><th>Category</th><th>Tags</th></thead>";

        phrase_score.top_hits.each(function(hit) {
            var row = new Element('tr');
            var score = new Element('td', {
                'class': 'score'
            }).update(hit.score);
            var category = new Element('td', {
                'class': 'score'
            }).update(hit.category);
            var title = new Element('td', {
                'class': 'title'
            }).update(hit.title);
            var words = new Element('td', {
                'class': 'phrases'
            }).update(hit.keywords.join("<br/>"));
            row.insert(score);
            row.insert(title);
            row.insert(category);
            row.insert(words);
            tbody.insert(row);
        });
        table.update(thead);
        table.insert(tbody);
        table.hide();
        div.insert(table);
        return div;
    },

    inspect: function() {
        return '#<MynewtvVideo:{id:'+this.id+', title: '+this.title+'}>';
    }
});

var MynewtvPlayerController = Class.create({

    initialize: function() {
        this.videos = null;
        this.currentVideo = null;
        this.requestingId = [];
        this.requestNextCounter = 0;
        this.requestPrevCounter = 0;
        this.lastIdRequestNext = null;
        this.lastIdRequestPrev = null;
        
        this.requestingTimeouts = new Hash;

        this.userSignedIn = true;
        this.userId = null;

        this.publish_facebook = false;
        this.publish_twitter = false;

        this.requestingTopVideo = false;


        this.lastRatingAction = '';
        this.lastRatingId = '';
        this.lastCheckIntervalTimeoutId = null;

        this.searching = null;
        this.playlistCapacity = 4;
        this.playlistSize = 0;
        this.docHeight = document.viewport.getHeight();
        this.docWidth = document.viewport.getWidth();
        this.player_width = 600;
        this.player_height = 400;
        

        this.nextVideoPath = '/next_video/';
        this.prevVideoPath = '/prev_video/';
        
        this.config = false;
    },

    getChannelInfo: function () {        
        if (channelId) {
            controller = this;
            new Ajax.Request('channels/' + channelId + '/info',
            {
                method:'get',
                onSuccess: function(transport){
                    var response = transport.responseJSON || "no response text";
                   
                      controller.channel_id = response.id;
                      $("channel_likes").update( response.likes );
                      $("channel_hates").update( response.hates );
                      if (response.following == true) {
                          $("follow_current_channel").src="/images/icons/channel/follow.png";
                          $("follow_current_channel").title="Click to stop following this channel";
                          $("follow_current_channel").observe("click", unfollowCurrentChannel);
                      }
                      else
                      {
                          $("follow_current_channel").src="/images/icons/channel/unfollow.png";
                          $("follow_current_channel").title="Click to start following this channel";
                          $("follow_current_channel").observe("click", followCurrentChannel);
                      }
                      $("rate_channel").show();
                 
                },
                onFailure: function(){
                     setErrorMessage("This channel doesn't exist");
                      setTimeout("location.href='/'",4000); 
                }
            });                
                   
        }
        else
        {
            $("rate_channel").hide();
        }
    },

    configMynewtvMode: function() {
        /* To stop double configuration bug in Firefox/Ubuntu */
        if (this.config == true) {
            return;
        }
        var controller = this;
        vid = hashtrack.get("vid");        
        
        if (channelSlug == "public") {
                  var initialVideosPath = '/public';
                  this.prevVideoPath = '/public/prev/';
                  this.nextVideoPath = '/public/next/';
                  setInfoMessage("You are watching MyNew.Tv channel. Please, Sign In to get your own personalized channel.");
        }
        else if (userId && channelId) {
                   var initialVideosPath = '/channels/'+channelId;
                  this.prevVideoPath = '/channels/'+channelId+'/prev/';
                  this.nextVideoPath = '/channels/'+channelId+'/next/';
                  setTimeout("setInfoMessage('You are watching ' + channelName + ' channel.')",4000);
        }
        else if (userSignedIn == true) {

                  var initialVideosPath = '/user_playlist/';
                  this.prevVideoPath = '/prev_video/';
                  this.nextVideoPath = '/next_video/';                
        }
        else 
        {
               console.log("Disoriented");
                 
        }
        
        this.getChannelInfo();
        
        new Ajax.Request(initialVideosPath,
        {
            method:'get',
            parameters: {
                vid: vid
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                var array = transport.responseJSON;
                controller.videos = new MynewtvVideoList(array);
                $("video_list").update("");
                controller.videos.each (function(video) {
                    controller.addVideoThumbs(video);//VER DE USAR FOR?
                });

                controller.cueVideo(controller.videos.first() ) ;
            },
            onFailure: function(){ 
                console.log("failInitial: " + initialVideosPath);
            }
        });
        
      
        /* To stop double configuration bug in Firefox/Ubuntu */
        this.config = true;
    },

    resizePlayer: function () {
        /* Player Resize */
        console.log ("resize player");
        this.calculatePlayerSize();
        getPlayer().resize(this.player_width, this.player_height);
    },

    resizeUI: function () {
        //this.adjustRatingActionsButtons();
        this.adjustPlaylist();
        this.adjustHeader();
        this.adjustPlayerWrapper();
    },

    calculatePlayerSize: function () {
        var non_wide_width = (4 * this.docHeight) / 3;

        if ( this.docWidth > non_wide_width ) {
            HEIGHT_RATIO = 9;
            WIDTH_RATIO = 16;
        }
        else
        {
            HEIGHT_RATIO = 3;
            WIDTH_RATIO = 4;
        }
        
        var left_column = 0;
        if (this.docWidth > 1000) {
            left_column = 190;
        }

        var percent = (23 * this.docWidth ) / 100;

        this.player_width = this.docWidth - left_column - percent;
        this.player_height = (HEIGHT_RATIO * this.player_width) / WIDTH_RATIO;

        return [this.player_width, this.player_height];
    },

    adjustPlaylist: function() {
        $("video_list").setStyle({
            width : this.docWidth - 140 + 'px'
        });
        this.playlistCapacity = parseInt(this.docWidth/200) ;
    },

    adjustHeader: function () {
        if (this.docWidth - $("logo_section").getWidth() - $("header_buttons").getWidth() < 20) {
            $("user_name").hide();
        }
    },

    adjustPlayerWrapper: function() {
        var left_column = 0;
        if (this.docWidth > 1000) {
            left_column = 190;
        }
    
        $("player").setStyle({
            width: this.docWidth + 'px'
        });
        $("player_wrapper").setStyle({
            width: this.player_width + 'px'
        });

        var video_mask_length = this.docWidth - left_column;
        
        $("video_mask").setStyle({
            width:  video_mask_length + 'px'
        });
        

        $("player_mask").setStyle({
            width: video_mask_length + 'px'
        });
        /*
        if (left_column > 0) {
    
            $("player_mask").removeClassName("player_mask_center");
            $("player_mask").addClassName("player_mask_right");
        }
        else
        {
            $("player_mask").addClassName("player_mask_center");
            $("player_mask").removeClassName("player_mask_right");
        } */
        $("player_mask").addClassName("player_mask_center");
            $("player_mask").removeClassName("player_mask_right");
    },


    adjustRatingActionsButtons: function () {
        var left_column = 0;
        if (this.docWidth > 1000) {
            left_column = 190;
        }

        var left = this.player_width + left_column - 30;
        $("rating_actions").setStyle({
            left : left + 'px'
        });
    },

    visiblizeUI: function () {
          $("bottom_section").show();
          $("sidebar").show();
          $("playlist").show();
},


    addVideoLoading: function (_position, url) {
        var playlist = $('video_list');

        var li = new Element('li', {
            'id': url
        }).update("<div num='"+ counter++ +"'class='container'><img src='/images/icons/ajax-loader.gif' class='video_loader' /></div>");
        if (_position == "top") {
            playlist.insert( {
                top : li
            });
        }
        else
        {
            playlist.insert( {
                bottom : li
            });
        }

        return li;
    },

    addVideoThumbs: function(video, _li, _position) {
        var controller = this;
        var sizeVisible = $$("#video_list li").size();
                
        var playlist = $('video_list');
        var img    = video.thumbnailImg();
        var titleP  = video.titleP();
        //var author = video.authorP();
        var content = "<div class='container'><div class='item_video'><div class='head'>"+titleP + "</div><div class='middle'><div onclick='"+video.linkToPlay()+"' class='thumb'>"+img+"<img class='play_button'  src='/images/player/play_white.png'></div></div></div><div class='footer'>";
        if (userId) {
            content+="<div id='rates_"+video.id+"'class='video_rates'>";
            if (video.rating == "liked") {
                content+="<img src='/images/icons/btn_smile_on.png' alt='liked' state='on' /><img src='/images/icons/btn_angry_off.png' alt='hated' state='off' />";
            }
            else if (video.rating == "hated") {
                content+="<img src='/images/icons/btn_smile_off.png' state='off' alt='liked'/><img src='/images/icons/btn_angry_on.png' alt='hated' state='on' />";
            }
            else {
                content+="<img src='/images/icons/btn_smile_off.png' alt='liked' state='off'/><img src='/images/icons/btn_angry_off.png' alt='hated' state='off' />";
            }
            content+="<img src='/images/icons/ajax-loader.gif' height='16' width='16' class='rating-loader' id='rate_loader_"+video.id+"' style='display: none'/></div>";
        }
        content+="</div></div>";
        
        if (_li == undefined ) {
            _li = new Element('li');
            var li = _li.update(content);     
        
        
            if (_position == "top") {
        
                if (sizeVisible < this.playlistCapacity) {
                    playlist.insert({
                        top : li
                    });;
                }
                else
                {
        
                    var last = $$("#video_list li").last();
                    new Effect.Move(last, {
                        x: 400,
                        y: 0,
                        mode: 'relative',
                        transition: Effect.Transitions.linear,
                        afterFinish: function () {
 if (last) {
                            last.remove();
}
                            playlist.insert({
                                top : li
                            });;
                        }
                    });
        
                }
            }
            else //bottom
            {
                if (sizeVisible < this.playlistCapacity) {
                    playlist.insert({
                        bottom : li
                    });
                            
                }
                else
                {
                    var first = $$("#video_list li").first();
                    new Effect.Move(first, {
                        x: -400,
                        y: 0,
                        mode: 'relative',
                        transition: Effect.Transitions.linear,
                        afterFinish: function () {
if (first) {
                            first.remove();
}
                            playlist.insert({
                                bottom : li
                            });
                        }
                    });
                }

            }
            
        }
        else
        {
            var li = _li.update(content);
        }
        li.addClassName("video_draggable");
        li.writeAttribute("id", video.id);
        li.observe("mouseover",showPlayButton );
        li.observe("mouseout", hidePlayButton );  
        if (userId) {
            $("rates_"+video.id).observe("click", changeVideoRates);
        }
        setDraggableVideo(li.id);
    },


    playOrPause: function() {
        var state = getPlayer().getState();
        // states from: http://code.google.com/apis/youtube/js_api_reference.html#Playback_controls
        // unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5)
        if (state != "PAUSE") {
            getPlayer().pause();
            //pauseEffect();

        } else {
            getPlayer().play();
            //playEffect();
        }
    },


    cueNextVideo: function(toRate) {
        if (this.videos.last().id == this.currentVideo.id) {
            this.nextVideo();
        }
        else
        {
            this.cueVideo( this.videos.next(this.currentVideo.id) );
        }
    },
    
    

    cueAlternateVideoId: function(videoId) {
        //this.skipCurrentVideoWithoutCueNext();
        var video = this.videos.get(videoId);
        this.cueVideo(video, false);
        //hideAudioRecorder();
        //if the video is an item of the playlist
        //if (!video.from == "search") {
        //  this.requestNextVideo();
        //}
    },

    cueExternal: function (id) {
        var videoAsJson = MynewtvEvents.videos().get(id);

        if(videoAsJson == null) {
            //console.log("Something goes wrong... an external Cue have id null");
            return;
        }
        if(this.currentVideo != null && this.currentVideo.id != videoAsJson.id) {
            /* var results = this.videos.append(videoAsJson);
            if (!isVideoInVisualPlaylist (videoAsJson.id) ) {
                this.addVideoThumbs(results.first() ) ;
            }
             */
            var video =  new MynewtvVideo(videoAsJson);
            this.cueVideo(video, false);
            
            //hideAudioRecorder();
        }
       
    },

    enqueueExternal: function (id) {
        var videoAsJson = MynewtvEvents.videos().get(id);
        if(this.currentVideo.id != videoAsJson.id) {
            var results = this.videos.append(videoAsJson);
            if (!isVideoInVisualPlaylist (videoAsJson.id) ) {
                this.addVideoThumbs(results.first() ) ;
            }
        }
        else
        {
            //console.log("same video");
        }
    },
    
        
    refreshVideo: function(value) {
        console.log(value);
    },
        
    skipCurrentVideoWithoutCueNext: function(id) {
        pageTracker._trackPageview('/enqueued');
    },

    cueVideo: function(video, toRate) {

        if (this.userSignedIn && toRate ) {
            this.watchedCurrentVideo();
        }
        
        if (!video.id) {
            return;
        }       
        this.currentVideo = video;
        
        var newVideo = {
            file: video.youtubeUrl(),
            image: '/images/layout/logo.png',
            title: video.title
        };
        getPlayer().load(newVideo);

        
        this.setVisualChanges(video);
        
        hashtrack.set("vid",video.id);
        
        if (this.videos.last().id == video.id) {
            this.nextVideo();
        }
        
        this.currentVideo.setPageFields();
        //this.addVideoThumbs();
        replaceDataForTwitterButton(this.currentVideo.title, this.currentVideo.mynewtvUrl() );
        //clearTimeout(this.lastCheckIntervalTimeoutId);
        this.lastCheckIntervalTimeoutId = setTimeout("Mynewtv.checkIfPlaying()", 15000);
        //retrieveAudioComments(video.id, userId);
    },

    checkIfPlaying: function () {
        if (getPlayer().getPosition() == 0 && getPlayer().getState() == 'BUFFERING') {
            //console.log("Delaying too much");
            onPlayerError();
        }

    },
    
    setVisualChanges: function (video) {
        if (this.currentVideo.from == 'post' && !this.userSignedIn) {
            replaceDataForTwitterButton(this.currentVideo.title, this.currentVideo.mynewtvUrl() );
            this.currentVideo.setPageFields();
            return;
        }
        if (userId) {
          $("btn_mtv_like").src="/images/player/btn_smile_light.png";
          $("btn_mtv_hate").src="/images/player/btn_angry_light.png";
        }
        //console.log ("CueVideo from "+ this.currentVideo.from);

        if (this.currentVideo.from == 'facebook') {
            $$(".fb_hidden").each (function(element) {
                element.value="";
            });

            $("fb_friend_pic").src =this.currentVideo.more.friend_pic_url ;
            $("fb_friend_pic").title= this.currentVideo.more.friend_username ;
            var friend_name = this.currentVideo.more.friend_username;
            $("fb_friend_name").value= friend_name ;
            $("fb_friend_id").value= this.currentVideo.more.friend_id ;
            $("mynewtv_id").value= this.currentVideo.more.mynewtv_id ;

            $$(".friend_name").each (function(element) {
                element.update(friend_name);
            });

            $("fb_post_id").value= this.currentVideo.more.post_id ;
            checkLikes();

            $("fb_rec_box").show();

            if (this.currentVideo.more.mynewtv_id == null  ) {
                $('unfollow_fb').hide();
                $('follow_fb').hide();
                $('channel_or_invite').writeAttribute("target", "no_channel" );
                $("no_channel").show();
            }
            else
            {
                $('channel_or_invite').writeAttribute("target","channel") ;
                $$('go_to_channel').each (function(element) {
                    element.value= "/channels/" + this.currentVideo.more.mynewtv_id ;
                });

                $("fb_mynewtv_user").update(this.currentVideo.more.friend_username);

                following = this.currentVideo.more.following;
                //console.log("You are following this Fb Friend? " + following);
                if (following == true) {
                    $('unfollow_fb').show();
                    $('follow_fb').hide();
                    $("status_follow").update("You are following ");
                }
                else
                {
                    $('follow_fb').show();
                    $('unfollow_fb').hide();
                    $("status_follow").update("You not are following ");
                }


            }
        }
        else
        {
            $("fb_rec_box").hide();
            $("fb_post_id").value= "";
            $("mynewtv_id").value= "";

        }
        
        // $("rating_actions").show();
        // setTimeout("$('rating_actions').hide()", 4000);
    },


    removeFromPlaylist: function () {
        new Ajax.Request('/videos/' + this.currentVideo.id,
        {
            method:'delete'
        });

        this.videos.unset(this.currentVideo.id);
        $(this.currentVideo.id).remove();

    },

    shareOnFacebook:function()   {
        FB.ui(
        {
            method: 'feed',
            display: 'popup',
            name: this.currentVideo.title,
            link: this.currentVideo.mynewtvUrl(),
            picture: this.currentVideo.thumb_url,
            caption: 'http://MyNew.TV',
            description: this.currentVideo.description,
            message: 'Check this out!'
        },
        function(response) {
            if (response && response.post_id) {

            } else {
                //alert('Post was not published.');
            }
        }
    );
    },

    publishAllLikedOnFacebook: function (event) {
        var publish = $("publish_fb").readAttribute("publish");
        if (publish  == "true") {
            $("publish_fb").src="/images/icons/light/btn_facebook.png";
            //  $("publish_fb").height=25;$("publish_fb").width=25;
            $("publish_fb").writeAttribute("publish", "false");
        }
        else
        {
            $("publish_fb").src="/images/icons/btn_facebook_color.png";
            // $("publish_fb").height=32;$("publish_fb").width=32;
            $("publish_fb").writeAttribute("publish", "true");
        }

        new Ajax.Request('/user/publish_fb',
        {
            method:'post'
        });
    },

    publishAllLikedOnTwitter: function (event) {
        new Ajax.Request('/user/publish_tw',
        {
            method:'post' ,
            onSuccess: function (transport) {
                refreshPublishTw();
            }
        });
    },

   

    nextVideo: function (reprod) {

        var controller = this;
        var playlist = this.videos;
        var last = $$("#video_list li[id]").last();
    
        var lastVisibleId = parseInt(last.id);
        var sizeVisible = $$("#video_list li").size();


        var next = playlist.next(lastVisibleId);

        if (next == undefined) {
            if (lastVisibleId != this.lastIdRequestNext) {
                if (sizeVisible < this.playlistCapacity) {
                    controller.requestNextVideo(true, lastVisibleId);
                }
                else
                {
                    var first = $$("#video_list li").first();
                    new Effect.Move(first, {
                        x: -400,
                        y: 0,
                        mode: 'relative',
                        transition: Effect.Transitions.linear,
                        afterFinish: function () {
                            first.remove();
                            controller.requestNextVideo(true, lastVisibleId);
                        }
                    });
                }
            }
        }
        else
        {
            if (sizeVisible < this.playlistCapacity) {
                this.addVideoThumbs( next, null, 'bottom' );
            }
            else
            {
                var first = $$("#video_list li").first();
                new Effect.Move(first, {
                    x: -400,
                    y: 0,
                    mode: 'relative',
                    transition: Effect.Transitions.linear,
                    afterFinish: function () {
                        first.remove();
                        controller.addVideoThumbs( next, null, 'bottom' );
                    }
                });
            }
        }
    },


    previousVideo: function () {

        var controller = this;
        var playlist = controller.videos;
        var firstVisibleId = parseInt($$("#video_list li[id]").first().id);
        var sizeVisible = $$("#video_list li").size();

        var prev = playlist.previous(firstVisibleId);

        if (prev == undefined) {
            if (firstVisibleId != this.lastIdRequestPrev) {
                if (sizeVisible < this.playlistCapacity) {
                    controller.requestPreviousVideo(true, firstVisibleId);
                }
                else
                {
                    var last = $$("#video_list li").last();
                    new Effect.Move(last, {
                        x: 400,
                        y: 0,
                        mode: 'relative',
                        transition: Effect.Transitions.linear,
                        afterFinish: function () {
                            last.remove();
                            controller.requestPreviousVideo(true, firstVisibleId);
                        }
                    });
                }
            }
        }
        else
        {
            if (sizeVisible < this.playlistCapacity) {
                this.addVideoThumbs( prev, null, 'top' );
            }
            else
            {
                var last = $$("#video_list li").last();
                new Effect.Move(last, {
                    x: 400,
                    y: 0,
                    mode: 'relative',
                    transition: Effect.Transitions.linear,
                    afterFinish: function () {
                        last.remove();
                        controller.addVideoThumbs( prev, null, 'top' );
                    }
                });
            }
        }
    },


    requestPreviousVideo: function (visible_loading, id) {
        controller = this;

        var path = this.prevVideoPath + id;
        if (this.existRequest(path) ) {
            return;
        }
        var arrayIds = this.videos.ids().toArray();
        var _ids = arrayIds.inspect();
        var _element = null;
        //        var lastIndexRequest=10;
        var lastRequest = new Ajax.Request(path,
        {
            method:'get',
            parameters: {
                ids : _ids
            },
            onLoading: function () {
                if (visible_loading == true) {
                    _element = controller.addVideoLoading('top', path );
                    prevPlaylistOff("Searching for previous video...");
                }
                controller.requestPrevCounter++;
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";

                if (response != "false") {                   
                
                    var video_json = transport.responseJSON;
                    result = controller.videos.prepend(video_json);
                      
                    if (result.length > 0) {
                        if (visible_loading && existElement(_element) ) {
                            controller.addVideoThumbs(result.first(), _element, 'top' );
                        }
                        else {
                            _element.remove();
                        }
                    }
                } 
            },
            onFailure: function(response){
                alert("fail request Prev Video");
                console.log(response);
                if (_element) {
                    _element.remove();
                }
            },
            onComplete: function(response){
                controller.requestPrevCounter--;
                controller.removeRequest(lastRequest.url);
                //alert("prev: onComplete: " + lastRequest.url );
                controller.lastIdRequestPrev = null;

                if (response.responseText == "false") {
                    _element.remove();
                    prevPlaylistOn("No previous videos.");

                } else { 
                    prevPlaylistOn("");
                }
            }
        });
        this.lastIdRequestPrev = id;
        lastIndexRequest = this.addRequest (lastRequest);

    },


    requestNextVideo: function (visible_loading, id) {
        controller = this;

        
        var path = this.nextVideoPath + id;
        if (this.existRequest(path) ) {
            return;
        }
        var arrayIds = this.videos.ids().toArray();
        var _ids = arrayIds.inspect();
        var _element = null;

        var lastRequest = new Ajax.Request(path,
        {
            method:'get',
            parameters: {
                ids : _ids
            },
            onLoading: function () {
                if (visible_loading == true) {
                    _element = controller.addVideoLoading('bottom', path);
                    nextPlaylistOff("Searching for next video...");
                }
                controller.requestNextCounter++;
            },
            onSuccess: function(transport){

                var response = transport.responseText || "no response text";                
                
                if (response != "false") {
                    var video_json = transport.responseJSON;
                    result = controller.videos.append(video_json);
                    
                    if (result.length > 0) {
                        if (visible_loading && existElement(_element) ) {
                            controller.addVideoThumbs(result.last(), _element, 'bottom' );
                        }
                        else {
                            _element.remove();
                        }
                    }
                } 
            },           
            onFailure: function(response){
                alert("fail requestNextVideo");
                console.log(response);
                if (_element) {
                    _element.remove();
                }
            },
            onComplete: function(response){
                controller.requestNextCounter--;
                controller.removeRequest(lastRequest.url);
                // alert("next: onComplete: " + lastRequest.url );
                controller.lastIdRequestNext = null;
                
                if (response.responseText == "false") {
                    nextPlaylistOn("No more videos.");
                    _element.remove();

                }
                else {                    
                    nextPlaylistOn("");
                }
            }
        });
        this.lastIdRequestNext = id;
        lastIndexRequest = this.addRequest (lastRequest);

    },
    
    abortRequest: function (url) {
        console.log("abortRequest: " +  url);
        var request = this.getRequest(url);
        if (request) {
            request.abort();
            this.removeRequest(request);
        }
        url = url.substring(0, url.indexOf("?"));
        $(url).remove();
        
        if (url.indexOf("next") > -1 )  {
            this.lastIdRequestNext = null;
            $("next_playlist").removeClassName("hidden");
            this.requestNextCounter--;
        }
        else
        {
            this.lastIdRequestPrev = null;
            $("prev_playlist").removeClassName("hidden");
            this.requestNextCounter--;
        }
    },

    addRequest: function (lastRequest) {
        this.requestingId = this.requestingId.concat([lastRequest]);
        var timeoutId = setTimeout("Mynewtv.abortRequest('"+lastRequest.url+"')", 35000);
        this.requestingTimeouts.set(lastRequest.url,  timeoutId);
        return this.requestingId.size() -1;
    },

    removeRequest: function (url) {
        this.requestingId = this.requestingId.reject(function (element) {
            if (element.url == url) {
                return true;
            }
            else
            {
                return false;
            }
        });
        var timeoutId = this.requestingTimeouts.unset(url);
        clearTimeout(timeoutId);
    },
    
    getRequest: function (url) {
        return this.requestingId.detect(function (element) {
            if (element.url == url) {
                return element;
            }
            else
            {
                return null;
            }
        });
    },
    
    existRequest: function (request) {
        return this.requestingId.any(function (element) {
            if (element.url == request.url) {
                return true;
            }
            else
            {
                return false;
            }
        });
    },


    /* Unused */
    requestPostVideo: function(videoId) {
        var path = '/v/'+videoId;
        new Ajax.Request(path,
        {
            method: 'get',
            onSuccess: function(transport) {
                var array = transport.responseJSON;
                if (!array) {
                    // having weirdness w/ json response sometimes.
                    array = transport.responseText.evalJSON();
                }
                controller.videos = new MynewtvVideoList(array);
                controller.cueNextVideo();
            },
            onFailure: function() {}
        });


    },

    querySearchVideos: function(query) {
        if (this.videos != null) {
            this.videos.clearSearchList();
        }

        if (query == "") {
            return;
        }

        if (this.searching != null) {
            this.searching.abort();
        }

        this.searchVideos(query, 1);
        $("search_field").value="";

    },

    searchVideos: function(words, count) {
        var searchVideosPath = '/videos/search';
        var controller = this;

        this.searching = new Ajax.Request(searchVideosPath,
        {
            method:'get',
            parameters: {
                query: words,
                count: count
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                //console.log ("response="+response);
                if (response == 'false') {
                    $('loader').setStyle({
                        visibility: 'hidden'
                    });
                    $('btn_search').removeClassName('searching');

                    throw $break;
                }
                else
                {

                    var array = transport.responseJSON;
                    controller.videos.addToSearchlist(array);
                    controller.addVideoThumbs();
                    count+=1;
                    //Agregar más a la cola
                    if (count < 6) {
                        controller.searchVideos(words, count);
                        //console.log("Search another...");
                    }
                    else
                    {
                        $('loader').setStyle({
                            visibility: 'hidden'
                        });
                        $('btn_search').removeClassName('searching');
                    }
                }


            },
            onLoading: function () {
                $('loader').setStyle({
                    visibility: 'visible'
                });
                $('btn_search').addClassName('searching');

            },
            onFailure: function(){
                $('loader').setStyle({
                    visibility: 'hidden'
                });
                $('btn_search').removeClassName('searching');
            }
        });

    },

    cueJsonVideo: function (array) {
        controller.videos = new MynewtvVideoList(array);
        controller.cueNextVideo();
    },

    postAboutCurrentVideo: function(form) {
        $('post_submit').disable();
        var method = form.method;
        new Ajax.Request(form.action,
        {
            method: method,
            parameters: form.serialize(true),
            onSuccess: function(transport) {
                $('new_post').hide();
                $('post_form_message').update("This video has been posted to Facebook!");
            },
            onFailure: function() {}
        });
    },


    watchedCurrentVideo: function() {
        this.rateCurrentVideo('watched');
    },

    likeCurrentVideo: function() {
        //log('liking: this',this);
        //log('liking: publish_facebook',this.publish_facebook);
        //log('liking: publish_twitter',this.publish_twitter);
        if (this.publish_facebook || this.publish_twitter) {
            setInfoMessage("You liked it! We'll publish it!");
        } else {
            setInfoMessage('You liked it!');
        }
        if (this.currentVideo.from == "facebook") {
            likePost();
            showFbLikeTab();
        }

        this.rateCurrentVideo('liked');
        $("btn_mtv_like").src="/images/player/btn_smile_dark.png";
        pageTracker._trackPageview('/liked');
    },

    hateCurrentVideo: function() {
        setInfoMessage("OK, no good...Here's another video!");
        this.rateCurrentVideo('hated');

        this.cueNextVideo(false);
        pageTracker._trackPageview('/hated');
    },
    
    
    skipCurrentVideo: function() {
        setInfoMessage("Next video!");
        this.rateCurrentVideo('enqueued');
        this.cueNextVideo(false);
        pageTracker._trackPageview('/enqueued');
    },

    skipVideo: function(id) {
        this.rateVideo('enqueued',id);
        this.videos.unset(id);
        Mynewtv.requestMoreVideos(1);
        pageTracker._trackPageview('/enqueued');
    },

    rateCurrentVideo: function(action) {
        this.sendRate(action, this.currentVideo);
    },


    rateVideo: function(action, id) {
        var video = this.videos.get(id);
        this.sendRate(action, video);
    },

    sendRate: function (action, video) {
        var path = '/ratings/';
        var params = "rating[action]="+action +
            "&rating[video_id]="+ video.id +
            "&rating[video_score]="+ video.score +
            "&rating[source]="+ video.from;
        if (channelId) {
            params+="&rating[channel_id]="+channelId;
        }
        if (video.from == "facebook") {
            params += "&rating[rec_id]="+video.more.id;
        }

      

        new Ajax.Request(path,
        {
            method:     'post',
            parameters: params,
            onLoading: function (){
                $("rate_loader_"+video.id).show();
            },
            onSuccess: function(transport) {
                var response = transport.responseJSON || "no response text";
                console.log("send response:" + response.action);
                changeVisualVideoRate(video.id, response.action);
                return true;
            },
            onComplete: function() {
                $("rate_loader_"+video.id).hide();
            }
        }
    );
    },
    
    destroyRate: function(action, video) {
      
        var path = '/ratings/'+video.id+"/destroy";
        var params = "rating[action]="+action +
            "&rating[video_id]="+ video.id +
            "&rating[video_score]="+ video.score +
            "&rating[source]="+ video.from;
        if (video.from == "facebook") {
            params += "&rating[rec_id]="+video.more.id;
        }
        if (channelSlug) {
            params+="&channel="+channelSlug;
        }
      

        new Ajax.Request(path,
        {
            method:     'post',
            parameters: params,
            onLoading: function () {
                $("rate_loader_"+video.id).show();
            },
            onSuccess: function(transport) {
                var response = transport.responseJSON || "no response text";
                console.log("send response:" + response);
                if(response == true) {
                    changeVisualVideoRate(video.id, null);
                }
                
                return true;
            },
            onComplete: function() {
                $("rate_loader_"+video.id).hide();
            }
        }
    );
        
    },

    popupPostForm: function(video_id) {
        var video_id = this.currentVideo.id;
        var url = "";
        if (location.port == "80") {
            url = location.protocol+"//"+location.host+"/posts/new?video_id="+video_id;
        } else {
            url = location.protocol+"//"+location.host+"/posts/new?video_id="+video_id;
        }

        window.open(url, '','width=650,height=500,toolbar=no,location=no,menubar=no,scrollbars=no,resizable=yes');
    }

});


function onPlayerError(error) {

    if (error != undefined && error.message ) {
        console.log("onPlayerError: " +  error.message);
        if (error.message == "The requested video could not found, or has been marked as private.") {
            Mynewtv.removeFromPlaylist();
            Mynewtv.cueNextVideo();    
        }
        if (error.message.indexOf("embedded players") > 0 ) {
            Mynewtv.removeFromPlaylist();
            Mynewtv.cueNextVideo();    
        }
    }
    else
    {
        console.log("onPlayerError: "+  error);
        setErrorMessage("Something goes wrong. Please, reload the page");
    }

    
}

function isVideoInVisualPlaylist(id) {
    var items = $$("#video_list li[id]");
    var len = items.length;
    var count = len;
    var ids = [];
    while (len--) {
        ids.push( parseInt(items[len].id) );
    }
    if (ids.indexOf(id) > -1) {
        return true;
    }
    else
    {
        return false;
    }
}

function existElement(el) {
    if (el.getWidth() > 0) {
        return true;
    }
    else
    {
        return false;
    }
}

function retrieveAudioComments(video_id, user_id) {

    new Ajax.Request("/audio_comments",
    {
        method:'get',
        parameters: {
            user_id : user_id,
            video_id : video_id
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            var audio_comments = transport.responseJSON;
            ul_audios = $("results_audios");
            ul_audios.update();
            //console.log("Audio comments: " + audio_comments);
            if (audio_comments.length > 0 ) {
                new Effect.Pulsate('audios_mark', {
                    pulses: 8,
                    duration: 4.0
                })
                audio_comments.each(function(audio) {
                    var player_id = "player_" + audio.id;
                    var li = createPlayerBox(audio, player_id);
                    ul_audios.insert ({
                        bottom: li
                    });
                    if (audio.action == 'hated') {
                        hatedAudio(audio.id);
                    }
                    if (audio.action == 'liked') {
                        likedAudio(audio.id);
                    }
                    createAudioPlayer(player_id, audio.location)

                });
            }
            else
            {
                ul_audios.update("<div id='no_audios'>No audio comments</div>")
            }

        },
        onFailure: function(){
        }
    });

}

function createPlayerBox (audio, player_id){
    var li = "<li><div class='audio_comment_box' id='audio_box_"+audio.id+"'><div class='icons'>";
    li += "<a id='like_audio' href='#' title='I Like this' onclick='likeAudioComment("+audio.id+")'><img src='/images/icons/thumbs_up_light.png' height='15' width='15'/></a>";
    li+="<a id='hate_audio' href='#' title='I Hate it' onclick='hateAudioComment("+audio.id+")'><img src='/images/icons/thumbs_down_light.png' height='15' width='15'/></a>"
    if (audio.user_id == userId) {
        li += "<a href='#' title='Remove' onclick='destroyAudiocomment("+audio.id+")'><img src='/images/icons/trash_light.png' height='15' width='15'/></a>";
    }
    li += "</div>";
    li += "<p class='comment_title'>"+audio.title+"</p>"+
        "<p class='comment_from'> by: " + audio.from + "</p>"+
        "<div class='audio_player'><div id='" + player_id + "' class='rtmp_player' ></div></div>"+
        "<div class='comment_duration'>" + audio.duration + "</div>";
    if (audio.description) {
        li += "<p class='comment_desc'>" + audio.description + "</p>";
    }

    li += "<div class='bottom_audio_box'><ul class='status_audio'><li><a id='likes' title='Likes' href='#' >"+
        "<img src='/images/icons/thumbs_up.png' height='14' width='14'/><span id='likes_count'>"+audio.likes+"</span></a></li><li><a title='Hates' href='#' id='hates'>"+"<img src='/images/icons/thumbs_down.png' height='14' width='14'/><span id='hates_count'>"+audio.hates+"</span></a></li><li><a href='#' id='listens' title='Listens'><img src='/images/icons/play.png' height='14' width='14'/><span id='listens_count'>"+audio.listen_count+"</span></a></li></ul></div>";
    li += "</div></li>";

    return li;
}

function addAudioComment (audio_as_string) {
    var audio = audio_as_string.evalJSON();
    ul_audios = $("results_audios");
    if ( $('no_audios') != null) {
        $('no_audios').remove();
    }
    var player_id = "player_" + audio.id;
    var li = createPlayerBox(audio, player_id);
    ul_audios.insert ({
        top: li
    });
    createAudioPlayer(player_id, audio.location);
    var title = $$('#audio_box_' + audio.id + ' p.comment_title').first();
    new Effect.Pulsate(title,{
        pulses: 4,
        duration: 3.0
    });
}

function createAudioPlayer(element_id, location) {
    jwplayer(element_id).setup({
        'flashplayer': '/jwplayer/player-non-viral.swf',
        'id': 'play_'+element_id,
        'allowScriptAccess': "always",
        'controlbar': 'bottom',
        'screencolor': "#000000",
        'wmode':'opaque',
        'width': '320',
        'skin' : "/jwplayer/simple.zip",
        'height': '20',
        'class': 'flv_audio',
        events: {
            onComplete: function() {
                // alert("onComplete");
                //   jwplayer('audio_player_1').stop();
                //  setTimeout("jwplayer('audio_player_1').stop()",500);
            }
        }
    });

    var audioComment = {
        file: location,
        streamer: RTMP_SERVER,//'rtmp://localhost/audiorecorder/_definst_',
        provider: 'rtmp',
        title: 'prueba'
    };
    jwplayer(element_id).load(audioComment);
}


function destroyAudiocomment(id) {

    new Ajax.Request("/audio_comments/destroy/"+id,
    {

        method : 'post',
        onSuccess: function(transport) {
            $("audio_box_"+id).remove();
        }
    });

}


function likeAudioComment(id) {

    new Ajax.Request("/audio_comments/like",
    {
        method:'post',
        parameters: {
            audio_id : id
        },
        onLoading: function (transport) {
            likedAudio(id);
        },
        onSuccess: function(transport) {
            likedAudio(id);
            var audio_comment = transport.responseJSON;
            updateAudioRatings(audio_comment);
        }
    });

}

function hateAudioComment(id) {

    new Ajax.Request("/audio_comments/hate",
    {
        method:'post',
        parameters: {
            audio_id : id
        },
        onLoading: function (transport) {
            hatedAudio(id);
        },
        onSuccess: function(transport) {
            hatedAudio(id);
            var audio_comment = transport.responseJSON;
            updateAudioRatings(audio_comment);

        }
    });

}

function updateAudioRatings(audio) {
    $$("#audio_box_"+audio.id +" #hates_count").first().update(audio.hates);
    $$("#audio_box_"+audio.id +" #likes_count").first().update(audio.likes);
    $$("#audio_box_"+audio.id +" #listens_count").first().update(audio.listen_count);
}

function hatedAudio(id) {
    $$("#audio_box_"+ id +" #like_audio img").first().src='/images/icons/thumbs_up_light.png';
    $$("#audio_box_"+ id +" #like_audio").first().writeAttribute("onclick","likeAudioComment("+id+")");
    $$("#audio_box_"+ id +" #hate_audio img").first().src='/images/icons/thumbs_down_red.png';
    $$("#audio_box_"+ id +" #hate_audio").first().writeAttribute("onclick","destroyAudioRating("+id+")");
}


function likedAudio(id) {
    $$("#audio_box_"+ id +" #like_audio img").first().src='/images/icons/thumbs_up_green.png';
    $$("#audio_box_"+ id +" #like_audio").first().writeAttribute("onclick","destroyAudioRating("+id+")");
    $$("#audio_box_"+ id +" #hate_audio img").first().src='/images/icons/thumbs_down_light.png';
    $$("#audio_box_"+ id +" #hate_audio").first().writeAttribute("onclick","hateAudioComment("+id+")");
}

function resetRatingActions(id) {
    $$("#audio_box_"+ id +" #like_audio img").first().src='/images/icons/thumbs_up_light.png';
    $$("#audio_box_"+ id +" #like_audio").first().writeAttribute("onclick","likeAudioComment("+id+")");
    $$("#audio_box_"+ id +" #hate_audio img").first().src='/images/icons/thumbs_down_light.png';
    $$("#audio_box_"+ id +" #hate_audio").first().writeAttribute("onclick","hateAudioComment("+id+")");
}

function destroyAudioRating (id) {

    new Ajax.Request("/audio_comments/destroy_rating/"+id,
    {
        method: 'post',
        onSuccess: function(transport) {
            resetRatingActions(id);
            var audio_comment = transport.responseJSON;
            updateAudioRatings(audio_comment);
        }
    });
}



function clearCreateAudioForm(){
    $("flv_form").reset();
    $("audio_location").value = null;
    $("audio_duration").value = null;
}

var audio_comment_to_add = null;
function waitForAddAudioComment (audio) {
    audio_comment_to_add = audio;
    setTimeout("addAudioComment(audio_comment_to_add)", 1000) ;
}

var counter = 0;

function addVideoToChannel(video,channel) {
    console.log ("Add video: " +  video);
    new Ajax.Request("/users/" + userId + "/channels/" + channel + "/add/",
    {
        method: 'post',
        parameters: {
            vid : video
        }
    });
 
}

function unfollowCurrentChannel () {
    console.log ("unfollow current channel");
    new Ajax.Request("/channels/" + Mynewtv.channel + "/unfollow",
    {
        method: 'post',
        onSuccess: function (transport){
            var response = transport.responseJSON;
            if (response == true) {
                $("follow_current_channel").src="/images/icons/channel/unfollow.png";
                $("follow_current_channel").title="Click to start following this channel";
                $("follow_current_channel").stopObserving("click", unfollowCurrentChannel);
                $("follow_current_channel").observe("click", followCurrentChannel);
            }
        }
    });
}

function followCurrentChannel () {
    console.log ("follow current channel");
    new Ajax.Request("/channels/" + Mynewtv.channel + "/follow",
    {
        method: 'post',
        onSuccess: function (transport){
            var response = transport.responseJSON;
            if (response == true) {
                $("follow_current_channel").src="/images/icons/channel/follow.png";
                $("follow_current_channel").title="Click to stop following this channel";
                $("follow_current_channel").stopObserving("click", followCurrentChannel);
                $("follow_current_channel").observe("click", unfollowCurrentChannel);
            }
        }
    });
}

