var User = Class.create({

    initialize: function(userName, userId, userSlug) {
        this.name = userName;
        this.id = userId;
        this.slug = userSlug;
   
    }
   
});

var SnoopModel = Class.create({
    initialize: function() {
        this.className = 'SnoopModel';
        this._videos = new Hash;
        this._videoIds = [];
        this.synchronize();
        this.currentPosition = 0;
         
    },

    synchronize: function() {        
        var _this = this;
        new Ajax.Request("/snoops/"+userId+"/retrieve",
        {
            method:'get',           
            onSuccess: function(transport){                
                var response = transport.responseJSON;
                if (response == false) {
                    Event.fire(document, "snoop:stop");                  
                }
                else
                {
                    var result = _this.append(response[0],true);
                    if (result.length > 0) {
                        //fireEvent
                        Event.fire(document, "snoop:video:change", {
                            video: result[0]
                        });
                    }
                    else if (Math.abs(this.currentPosition - response[1]) > 200) {
                        Event.fire(document, "snoop:position:change", {
                            position: response[1]
                        });

                    }
                    else
                    {
                        console.log("Nothing change");
                    }

                }
            },
            onFailure: function(){ 
                console.log("failTrack");
                Event.fire(document, "snoop:fail");
            }
        });
    },
    ids: function (){
        return this._videoIds;
    },
    first: function(n) {
        return this.videos().first();
    },
    last: function() {
        return this.videos().last();
    },
    previous: function (videoId) {
        var prevIndex = this._videoIds.indexOf(videoId) - 1;
        if (prevIndex >= 0) {
            var prevVideoId = this._videoIds[prevIndex];            
        }
        return this.get(prevVideoId);        
    },
    next: function (videoId) {
        var nextIndex = this._videoIds.indexOf(videoId) + 1;
        var nextVideoId = this._videoIds[nextIndex];
       
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
  

    append: function(arrayOfAttributes,notifyView) {
        var result = [];
                
        if (typeof arrayOfAttributes.push == "function" ) {
                
            arrayOfAttributes.each(function(attributes){
                var v = new Video(attributes);
                // make sure we're not adding a dupe!
                if (!this._videoIds.include(v.id)) {                   
                    this._videos.set(v.id, v);
                    this._videoIds.push(v.id);
                    result.push(v);
                } 
            }, this);
        }
        else //In case of JSON
        {
            var v = new Video(arrayOfAttributes);
            // make sure we're not adding a dupe!
            if (!this._videoIds.include(v.id)) {
                this._videos.set(v.id, v);
                this._videoIds.push(v.id);
                result.push(v);
            }
             
        }

        if (result.length > 0 && notifyView == true ) {
            Event.fire(document, "snoop:append", {
                videos : result
            });
        }

        return result;
    },

    prepend: function(arrayOfAttributes,notifyView) {
        var result = [];
        if (typeof arrayOfAttributes.push == "function" ) {
                
            arrayOfAttributes.each(function(attributes){
                var v = new Video(attributes);
                // make sure we're not adding a dupe!
                if (!this._videoIds.include(v.id)) {                   
                    this._videos.set(v.id, v);
                    this._videoIds.unshift(v.id);
                    result.push(v);
                } else {
                    result.push(this.get(v.id) ) 
                }
            }, this);
        }
        else //In case of JSON
        {
            var v = new Video(arrayOfAttributes);
            // make sure we're not adding a dupe!
            if (!this._videoIds.include(v.id)) {
                this._videos.set(v.id, v);
                this._videoIds.unshift(v.id);
                result.push(v);
            }
            else {
                result.push(this.get(v.id) ) ;
            }
        }

        if (result.length > 0 && notifyView == true ) {
            Event.fire(document, "snoop:prepend", {
                videos : result
            });
        }

        return result;
    },


    
    index: function (videoId) {
        return this._videoIds.indexOf(videoId);
    },


    unset: function(videoId) {
        this._videoIds = this._videoIds.reject(function(id){
            return id == videoId;
        });
     
        return this._videos.unset(videoId);
    },

    unshift: function(video) {
        this._videoIds.unshift(video.id);
        this._videos.set(video.id, video);
    },

    _each: function(iterator) {
        var i;
      

        var length = this._videoIds.length;
        for ( i=0; i < length; i++) {
            var id = this._videoIds[i];
            var vid = this._videos.get(id);
            iterator(vid);
        }

    },


    videos: function() {
        var videos = [];
        var index = 0;

        this._videoIds.each(function(id){
            videos [index] = this._videos.get(id);
            index++;
        },this);

        return videos;
    },

    size: function () {
        return this._videoIds.size();
    }    

});
Object.extend(SnoopModel.prototype, Enumerable);


var Video = Class.create({
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
            return "http://mynew.tv/watch/" + this.id +"?user_id=" + userId;
        }
        else if (this.more && this.more.user_id) {
            return "http://mynew.tv/watch/" + this.id +"?user_id=" + this.more.user_id;
        }
        else
        {
            return "http://mynew.tv/watch/" + this.id;
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
  
    setField: function(fieldName, value) {
        var elem = $(fieldName);
        if (elem) {
            elem.update(value);
        }
    }

   
});


var SnoopController = Class.create({

    initialize: function(model) {
        this.model = model;       
        this.currentVideo = null;
        Event.observe(document, "player:ready", this.startPlaying.bindAsEventListener(this));
        Event.observe(document, "snoop:video:change", this.cueLastUpdate.bindAsEventListener(this) );
        Event.observe(document, "snoop:stop", this.noMoreSnoop.bindAsEventListener(this) );

        this.startPlayingThread = new PeriodicalExecuter(this.startPlaying.bindAsEventListener(this), 2 );
        this.snoopThread = new PeriodicalExecuter(this.updateSnoop.bindAsEventListener(this), 30 );
    },

    updateSnoop: function (event) {
        console.log("updateSnoop");
        this.model.synchronize();

    },

    startPlaying: function (event) {
        console.log("start playing");
        if (this.model.ids().length > 0 && player.ready && this.currentVideo == null) {
            this.cueVideo(this.model.first() );      
            if (this.startPlayingThread) {
                this.startPlayingThread.stop();
            }
           
        }
        else
        {
            if (player.getState() == "PLAYING" && this.startPlayingThread.timer) {
                this.startPlayingThread.stop();
            }
          
        }
    },

    noMoreSnoop: function (event) {
        console.log("user is not connected");
        //this.snoopThread.stop();
        setWarningMessage("User is not visible at this time");
    },

    saveError: function (event) {
       

    },

    continuePlaying: function (event) {
        this.cueVideo(this.currentVideo);
    },

    cueLastUpdate: function (event) {
        if (player && player.ready ) {
            this.cueVideo(event.memo.video, false);
        }
    },

    cueVideo: function(video, toRate) {
      
        if (!video.id) {
            return;
        }       

        if (this.currentVideo && this.currentVideo.id == video.id ) {
            console.log("repeated video!!!!!");
            return;
        }
        this.currentVideo = video;
        player.load(video);
       
        this.setVisualChanges(video);
        //hashtrack.set("vid",video.id);

        this.currentVideo.setPageFields();
        //this.addVideoThumbs();
        replaceDataForTwitterButton(this.currentVideo.title, this.currentVideo.mynewtvUrl() );
        //retrieveAudioComments(video.id, userId);
        
    },
    
    setVisualChanges: function (video) {

    }
});




var SnoopView = Class.create({
    initialize: function(model) {
        this.className = 'SnoopView';        
        this.model = model;
        this.maxSize = 6;

        this.docHeight = document.viewport.getHeight();
        this.docWidth = document.viewport.getWidth();
        this.player_width = 600;
        this.player_height = 400;      

        this.bindingEvents();
    },

    bindingEvents: function () {
        Event.observe(document, "view:resize", this.resize.bindAsEventListener(this));
    },

    resize: function () {
        this.adjustHeader();
        this.visiblizeUI();          
    },

    adjustPlayerControls: function () {
        $("controls").setStyle({
            width: player.width + 'px'
        });
    },

    adjustPlaylist: function() {
        /*  $("video_list").setStyle({
            width : this.docWidth - 140 + 'px'
        }); */
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
    // $("playlist").show();
    }

});
