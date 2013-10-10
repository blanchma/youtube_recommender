document.observe("dom:loaded", function() {

  $("global_message").observe("click", hideGlobalMessage);    

    shortcut.add("Space",function() {
        player.playOrPause();
    },{
        'disable_in_input':true  } );

    $('btn_search_user').observe('click', searchUsers);
    $('search_users_input').observe('keyup', searchUsers);

    if (userSignedIn == true) {
        $('btn_search_followers').observe('click', searchFollowers);
        $('search_followers_input').observe('keyup', searchFollowers);


        $('btn_search_following').observe('click', searchFollowing);
        $('search_following_input').observe('keyup', searchFollowing);
    }



    $$('.title_section').each (function(element) {
        Event.observe(element,'click', toggleBar );
    });


});

var Player = Class.create ({
    initialize: function () {
        this.player = null;
        this.view = null;
        this.height = 0;
        this.width = 0;       
        this.build(true);
        this.ready = false;  
        this.currentVideo = null;
    },

    build: function(onLoad) {
        _this = this;
        console.log("initPlayer");
        this.calculateSize();

        jwplayer('mynewtv_player').setup({
            'flashplayer': '/jwplayer/player.swf',
            'id': 'ytplayer',
            'autostart': 'true',
            'allowScriptAccess': "always",
            'allowFullScreen': 'true',
            'screencolor': "#000000",
            'width': _this.width,
            'wmode': "opaque",
            'height': _this.height, //'480',
            'image': '/images/layout/logo.png',
            'controlbar': 'bottom',
            'logo.file': '/images/layout/logo_square.jpg',
            'skin': "/jwplayer/dangdang.swf",
            'events': {
                onComplete: _this.onVideoComplete.bindAsEventListener(_this),
                onError: _this.onError.bindAsEventListener(_this),
                onReady: function() {
                    _this.ready = true;
                    _this.onReady(onLoad);
                },
                onTime: _this.updatePlayerInfo.bindAsEventListener(_this)
            },
            'modes': [
                {
                    type: 'html5'
                },
                {
                    type: 'flash',
                    src: 'player.swf'
                },
                {
                    type: 'download'
                }
            ]
        });

        Event.observe(document, "view:resize", this.resize.bindAsEventListener(this));
    },

    rebuild: function () {
        console.log("rebuild");
        if ($('ytplayer') != null) {
            $('ytplayer').remove();
        }
        $('player_wrapper').insert("<div id='mynewtv_player'></div>", {
            position: 'bottom'
        });

        this.build(false);
    },

    get: function () {
        try {
            var state = this.player.getState();
            if (state == null) {
              _this.rebuild();
            }
        }
        catch (e) {
            _this.rebuild();
        }

        return this.player;
    },

    load: function (video) {
       var newVideo = {
            file: video.youtubeUrl(),
            image: '/images/layout/logo.png',
            title: video.title
        };

      this.player.load(newVideo);
      this.currentVideo = video;
    },

    getState: function() {      
      if (this.player) {
          return this.player.getState();
      }
      else
      {
        return null;
      }
    },

    getPosition: function() {
      return this.player.getPosition();    
    },

    play: function () {
      return this.player.play();
    },

    pause: function () {
      return this.player.pause();
    },

    onReady: function (onLoad) {
        console.log("jwplayer = " + jwplayer().getState() );
        this.player = jwplayer('mynewtv_player') ;
        if (onLoad == true) {      
            Event.fire(document, "player:ready").delay(2);
        }
        else
        {
            Event.fire(document, "player:recover");
        }
      //this.player.addModelListener("STATE", this.stateChange.bindAsEventListener.bind(this) );

    },


  stateChange: function (change) {
	  currentState = change.newstate; 
	  previousState = change.oldstate; 
    console.log ("change state from " + previousState + " to " + currentState);
  },

    updatePlayerInfo: function (callback) {
      
            //currentVideo.setDuration(Math.floor(callback.position), Math.floor(callback.duration));
        

    },

    onVideoComplete: function(event) {
        console.log("onVideoComplete");
        Event.fire(document, "player:complete").delay(1);
    },
    onError: function (error) {
        console.log("onPlayerError");
        if (error != undefined && error.message ) {
            console.log("onPlayerError: " +  error.message);
            if (error.message == "The requested video could not found, or has been marked as private.") {
                Event.fire(document, "player:error");
            }
            if (error.message.indexOf("embedded players") > 0 ) {
                Event.fire(document, "player:error");
            }
        }
        else
        {
            console.log("onPlayerError: "+  error);
            setErrorMessage("Something goes wrong. Please, reload the page");
        }

      
    },

   calculateSize: function () {
        var docHeight = document.viewport.getHeight();
        var docWidth = document.viewport.getWidth();
      
        var non_wide_width = (4 * docHeight) / 3;

        if ( docWidth > non_wide_width ) {
            var HEIGHT_RATIO = 9;
            var WIDTH_RATIO = 16;
        }
        else
        {
            var HEIGHT_RATIO = 3;
            var WIDTH_RATIO = 4;
        }
        
        var left_column = 0;
        if (docWidth > 1000) {
            left_column = 190;
        }

        var percent = (23 * docWidth ) / 100;

        this.width = docWidth - left_column - percent;
        this.height = (HEIGHT_RATIO * this.width) / WIDTH_RATIO;
    },

    resize: function (event) {   
      //console.log ("resize player");
      this.calculateSize();
      this.player.resize(this.width, this.height);
    }


});




var PlayerView =  Class.create({
    initialize: function() {
        this.docHeight = 0;
        this.docWidth = 0;
        this.player_width = 600;
        this.player_height = 400;      

        Event.observe(document.onresize ? document : window, "resize", this.resize.bindAsEventListener(this) );
        Event.observe(document, "player:ready", this.resize.bindAsEventListener(this));

    },
    resize: function (event) {
       var height = document.viewport.getHeight();
          var width = document.viewport.getWidth();

          var change = false;
          if (width != this.docWidth) {
              this.docWidth = width;
              change = true;
          }

          if (height != this.docHeight) {
              this.docHeight = height;
              change = true
          }

          if (change == true) {
            if (player && player.ready == true) {
              Event.fire(document, "view:resize");                 
                 this.adjustPlayerWrapper();
                  this.adjustPlayerControls();  
            }
          }
  
    },

    playOrPause: function() {
        var state = this.player.getState();
        // states from: http://code.google.com/apis/youtube/js_api_reference.html#Playback_controls
        // unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5)
        if (state != "PAUSE") {
            this.player.pause();
        //pauseEffect();

        } else {
            this.player.play();
        //playEffect();
        }
    },

    adjustPlayerControls: function () {
        $("controls").setStyle({
            width: player.width + 'px'
        });
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

       
    }
});

