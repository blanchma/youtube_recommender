
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

    linkToPlay: function() {
        var _function = "playlistController.cueAlternateVideoId("+this.id+");return false;"
        return _function;
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
        this.setField('explanation', '<b>'+this.title + '</b><br/>source='+ this.from + '<br/>score= '+ this.score + '<br/>category_score= ' + this.category_score + '('+this.categories+ ') <br/>rating_score= ' + this.rating_score + '<br/>views_score= ' + this.rating_score + '<br/>avg_phrase_score= ' + this.phrases_score + ' <br/> tags(score=weight*rare*unseen)<div id="tags">'+ this.words_debug + '</div>');

    },

    setField: function(fieldName, value) {
        var elem = $(fieldName);
        if (elem) {
            elem.update(value);
        }
    }
});


var WatchController = Class.create({

    initialize: function(video_id) {  
        this.video_id = video_id;
        this.video = null;
        Event.observe(document, "player:ready", this.startPlaying.bindAsEventListener(this));        
        this.startPlayingThread = new PeriodicalExecuter(this.startPlaying.bindAsEventListener(this), 2 );

    this.synchronize();
    },

    synchronize: function() {
        var _this = this;
        new Ajax.Request('/videos/' + this.video_id ,
        {
            method:'get',
            onSuccess: function(transport){   
                var video_json = transport.responseJSON;
                _this.video = new Video(video_json);
                _this.startPlaying(); 

            }
        });

    },

    startPlaying: function (event) {
        console.log("start playing");
        if (this.video && player.ready ) {
            this.playVideo();      
            if (this.startPlayingThread) {
                this.startPlayingThread.stop();
          }
        }
    },


 playVideo: function() {

        player.load(this.video);
        this.video.setPageFields();

        //this.addVideoThumbs();
        replaceDataForTwitterButton(this.video.title, this.video.mynewtvUrl() );
        //retrieveAudioComments(video.id, userId);
        
    }
    

});
