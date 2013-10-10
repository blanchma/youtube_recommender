var MynewtvChannelPlayerController = Class.create({

  initialize: function() {
    this.playerId = 'ytplayer';
    // this.embedPlayer('http://www.youtube.com/apiplayer?enablejsapi=1&version=3');
    this.initPlayer(true);
    this.initController();
    this.player = null;
    this.videos = null;
    this.currentVideo = null;
    this.requestNum = 0;

    this.playlistEnded = false;

    this.userId = null;

    this.userSignedIn = true;
    this.publish_facebook = false;

    this.requesting = false;
    this.requestingId = null;
    this.requestsPending = [];

    this.lastCheckIntervalTimeoutId = null;
  },


  initPlayer: function(onLoad) {

    controller = this;
    jwplayer('mynewtv_player').setup({
      'flashplayer': '/jwplayer/player.swf',
      'id': 'ytplayer',
      'autostart': 'true',
      'allowScriptAccess': "always",
      'allowFullScreen': 'true',
      'screencolor': "#000000",
      'width': '610',
      'wmode': "transparent",
      'height': '458',
      'image': 'images/layout/logo.png',
      'controlbar': 'bottom',
      'logo.file': '/images/layout/logo_square.jpg',
      'skin': "/jwplayer/dangdang.swf",
      events: {
        onComplete: function() {
          Mynewtv.cueNextVideo(true);
        },
        onError: onChannelPlayerError,
        onReady: function () {
          //console.log("jwplayer = " + jwplayer().getState() );
          controller.player = jwplayer();
          if (onLoad == true) {
            MynetvPlayerReady();
          }

        },
        onTime: function (callback) {
          controller.updatePlayerInfo(callback);
        }
      }
    });



  },

  initController: function () {
    setTimeout("setInterval('Mynewtv.requestNextVideo(1)',60000)", 20000);
  },

  isRequesting: function() {
    return this.requesting ;
  },

  requestingOn: function () {
    this.requesting = true;
    this.requestId = setTimeout("Mynewtv.requestingOff(1)", 90000);
  },

  requestingOff: function (num) {
    this.requesting = false;
  },

  abortRequesting: function () {
    clearTimeout(this.requestingId);
  },

  getPlayer: function () {
    controller = this;

    try {
      controller.player.getState();
      if (controller.player.getState() == null) {
        controller.reInitPlayer();
      }
    }
    catch (e) {
      controller.reInitPlayer();
    }

    return controller.player;
  },

  reInitPlayer: function () {
    if ($('ytplayer') != null) {
      $('ytplayer').remove();
    }
    $('absolute_container').insert("<div id='mynewtv_player' > </div>");
    controller.initPlayer(false);
    controller.load(this.currentVideo.youtubeUrl() );

  },

  updatePlayerInfo: function(callback) {
    try {
      if (this.currentVideo) {
        this.currentVideo.setDuration(Math.floor(callback.position), Math.floor(callback.duration));
      }
    }
    catch (e) {

    }
    /* try {
      if (this.currentVideo) {
        this.currentVideo.setDuration(Math.floor(Mynewtv.getPlayer().getCurrentTime()));
      }
    }
    catch (e) {

    } */
  },

  playOrPause: function() {
    var state = this.getPlayer().getState();
    // states from: http://code.google.com/apis/youtube/js_api_reference.html#Playback_controls
    // unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5)
    if (state != "PAUSE") {
      this.getPlayer().pause();
      //pauseEffect();

    } else {
      this.getPlayer().play();
      //playEffect();
    }
  },

  toggleSound: function () {
    if (this.getPlayer().isMuted() ) {
      $("btn_mute_unmute").src="/images/player/btn_mute_light.png";
      $("btn_mute_unmute").title="Mute";
      this.getPlayer().unMute();
    }
  else
    {
      $("btn_mute_unmute").src="/images/player/btn_volume.png";
      $("btn_mute_unmute").title="Unmute";
      this.getPlayer().mute();
    }
  },


  cueNextVideo: function() {
    if (!this.videos.empty()) {
      this.cueVideo(this.videos.first());
      if (this.videos.size() > 1) {
        this.requestNextVideo(this.videos.last().rating_id);
      }
    } else {
      //log("cant cue, vid list empty! this.videos:", this.videos);

    }
  },

  cueAlternateVideoId: function(videoId) {
    var video = this.videos.get(videoId);
    this.cueVideo(video);
    this.requestNextVideo(this.videos.last().rating_id);
  },

  cueVideo: function(video) {
    var newVideo = {
      file: video.youtubeUrl(),
      image: '/images/layout/logo.png',
      title: video.title
    };
    Mynewtv.getPlayer().load(newVideo);

    this.currentVideo = Mynewtv.videos.unset(video.id);
    this.currentVideo.setPageFields();
    replaceDataForTwitterButton(this.currentVideo.title, this.currentVideo.youtubeUrl() );
    this.addVideoThumbs();
    clearTimeout(this.lastCheckIntervalTimeoutId);
    this.lastCheckIntervalTimeoutId = setTimeout("Mynewtv.checkIfPlaying()", 15000);
  },


  checkIfPlaying: function () {
    if (this.getPlayer().getPosition() == 0 && 
    this.getPlayer().getState() == 'BUFFERING' && 
    this.getPlayer().getBuffer() == 0 ) {
      //console.log("Delaying too much");
      onChannelPlayerError();
    }

  },

  requestUserChannelPlaylist: function() {
    var path = '/channels/'+this.userId;
    //log('channel playlist...path:'+path);
    new Ajax.Request(path,
    {
      method: 'get',
      onSuccess: function(transport) {
        //log("channelplaylist transport:",transport);
        var array = transport.responseJSON;
        if (!array) {
          array = transport.responseText.evalJSON();
        }
        //log("array:", array);
        Mynewtv.videos = new MynewtvVideoList(array);
        Mynewtv.cueNextVideo();
      }
    });
  },

  requestNextVideo: function(last_rating_id) {
    if (!Mynewtv.playlistEnded && !Mynewtv.isRequesting() ) {
      Mynewtv.requestingOn();
      var path = '/channels/'+this.userId+'/next/'+last_rating_id;
      //log('next video path:', path);
      new Ajax.Request(path,
      {
        method: 'get',
        onSuccess: function(transport) {
          var array = transport.responseJSON;
          if (!array) {
            array = transport.responseText.evalJSON();
          }
          //log("got array",array);
          if (array.size()<1) {
            //log("array empty! not more requests!");
            // playlist is done!
            Mynewtv.playlistEnded = true;
          }
          Mynewtv.videos.add(array);
          Mynewtv.addVideoThumbs();
        },
        onComplete: function() { Mynewtv.requestingOff(); }
      });
    } else {
      //log("playlist done or doing a request...not requesting. req?:", Mynewtv.isRequesting(), " list:", Mynewtv.playlistEnded);
    }
  },

  shareOnFacebook: function () {
    FB.ui(
    {
      method: 'feed',
      display: 'popup',
      name: this.currentVideo.title,
      link: this.currentVideo.mynewtvUrl(),
      picture: this.currentVideo.thumb_url,
      caption: 'http://MyNew.Tv',
      description: this.currentVideo.description,
      message: 'Check this out!'
    },
    function(response) {
      if (response && response.post_id) {
        //alert('Post was published.');
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
    { method:'post'  });
  },

  publishAllLikedOnTwitter: function (event) {
    new Ajax.Request('/user/publish_tw',
    { method:'post' ,
      onSuccess: function (transport) {
        refreshPublishTw();
      }
    });
  },


  addVideoThumbs: function() {
    var count = 0;
    var max = 4;
    if (Mynewtv.userSignedIn) {
      max = 5;
    }

    var playlist = $('video_thumbs');
    playlist.update('');
    Mynewtv.videos.each(function(video){
      count++;
      if (count > max) {
        throw $break;
      }
      var img    = video.thumbnailImg();
      var title  = video.titleP();
      var author = video.authorP();
      var right = "<div class='float right'><p class='legend'>&nbsp;&nbsp;MyNew.TV</p><img title='MyNew.TV' src='/images/layout/logo_square_transparent.png' height='50' width='50'></div>";
      var li = new Element('li',{'id': 'li_'+video.id });
      var divs ="<div class='float left' onclick="+video.linkToPlay()+" >" + img + " </div>" +
      "<div class='float middle' onclick="+video.linkToPlay()+" >" + title + author + "</div>" +
      right + "<div style='float: right; width: 12px; height: 12px; position: absolute; margin-left: 385px; margin-top: -5px;'><a  class='close' href='#' onclick="+video.linkToSkipVideo()+"> <img src='/images/icons/light/20/btn_cerrar.png' heigh='12' width='12'></a></div>";

      li.update(divs);
      playlist.insert(li);
    });

    if (!Mynewtv.userSignedIn) {
      /*  var li = new Element('li', {'class': 'signup'});
      var h2 = new Element('h2').update('Sign up to discover the videos YOU love!');
      var button = new Element('a', {'href':'/users/sign_up/', 'class':'awesome orange'}).update('Sign Up!');
      li.insert(h2);
      li.insert(button);
      playlist.insert(li);*/

    }
  },

  watchedCurrentVideo: function() {
    if (this.userSignedIn) {
      this.rateCurrentVideo('watched');
    }
  },

  likeCurrentVideo: function() {
    if (this.userSignedIn) {
      if (this.publish_facebook || this.publish_twitter) {
        this.displayRatingMessage("You liked it! We'll publish it!");
      } else {
        this.displayRatingMessage('You liked it!');
      }
      this.rateCurrentVideo('liked');
      pageTracker._trackPageview('/liked');
    }
  },

  hateCurrentVideo: function() {
    if (this.userSignedIn) {
      this.displayRatingMessage("OK, not so good...Here's another video!");
      this.rateCurrentVideo('hated');
      this.cueNextVideo();
      pageTracker._trackPageview('/hated');
    }
  },

  skipCurrentVideo: function() {
    if (!this.videos.empty()) {
      this.displayRatingMessage("Next video!");
      if (this.userSignedIn) {
        this.rateCurrentVideo('enqueued');
      }
      this.cueNextVideo();
      pageTracker._trackPageview('/enqueued');
    } else {
      //log("CANT SKIP NO VIDS!");
    }
  },

  skipVideo: function(id) {
    this.rateVideo('enqueued',id);
    this.videos.unset(id);
    if (!this.videos.empty()) {
      this.cueVideo(this.videos.first());
      if (this.videos.size() > 1) {
        this.requestNextVideo(this.videos.last().rating_id);
      }
    }
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
    if (video.from == "facebook") {
      params += "&rating[rec_id]="+video.more.id;
    }

    if (this.lastRatingId == video.id && this.lastRatingAction == action) {
      return false;
    }
  else
    {
      this.lastRatingId = video.id;
      this.lastRatingAction = action;
    }

    new Ajax.Request(path,
    {
      method:     'post',
      parameters: params,
      onSuccess: function(transport) {
        var response = transport.responseText || "no response text";
        return true;
      },
      onFailure: function() {}
    }
    );
  },

  displayRatingMessage: function(message) {
    var elem = $('rating_message');
    elem.update(message);
    elem.appear();
    window.setTimeout(function() {
      // $('rating_message').fade();
      $('rating_message').update('&nbsp;');
    }, 4000);
  },

  popupPostForm: function(video_id) {

    var url = "";
    if (location.port == "80") {
      url = location.protocol+"//"+location.hostname+"/posts/new?video_id="+video_id;
    } else {
      url = location.protocol+"//"+location.hostname+":"+location.port+"/posts/new?video_id="+video_id;
    }

    window.open(url, '','width=650,height=500,toolbar=no,location=no,menubar=no,scrollbars=no,resizable=yes');
  }
});

function onYouTubeChannelStateChange(newState) {
  var ended = 0;
  var error = -1;
  if (newState == ended || newState == ended) {
    Mynewtv.cueNextVideo();
  }
}

function onChannelPlayerError(error) {
  if (error != null) {
    //console.log("onPlayerError = " + error.message);
  }
  Mynewtv.cueNextVideo();
}



function toggleFollowState(id) {
  var editFollowPath = '/user/toggle_follow';
  new Ajax.Request(editFollowPath,
  {
    method:'post',
    parameters: {
      id: id
    }
  });
  var follow_img = $$("#user_"+id+" img.stateF").first();
  var state = follow_img.alt;
  if (state == "follow") {
    follow_img.src="/images/icons/light/20/btn_unfollow.png";
    follow_img.alt="unfollow";
    follow_img.title="Unfollow";
  }
else
  {
    follow_img.src="/images/icons/light/20/btn_follow.png";
    follow_img.alt="follow";
    follow_img.title="Follow";
  }

}


function searchChannelFollowers(event,arg2) {
  var channelFollowersPath = '/channels/followers/'+userChannel;
  var query = $("search_followers_input").value;
  var page = arg2;
  if (page == undefined) {
    page = 1;
  }
  this.searching = new Ajax.Request(channelFollowersPath,
  {
    method:'get',
    parameters: {
      query: query,
      page: page
    },
    onSuccess: function(transport){
      var response = transport.responseText || "no response text";
      var results = transport.responseJSON;
      displayChannelFollowers(results[0], results[1], page, results[2]);
    }
  });
}

function displayChannelFollowers(previous, next, page, users) {

  /* Show each user */
  ul_followers = $("results_followers");
  ul_followers.update("");
  users.each(function(element, index) {
    var name = element[1];
    if (name.length > 22) {
      name = name.substring(0,22) + "...";
    }
    /* Insert name */
    li = "<li id='user_"+element[0]+"' title='"+element[1]+"' >"+name;

    /*Insert follow/unfollow and channel link */
    if (userSignedIn == true) {
      if (element[2] == true) {
        action = "unfollow";
      }
    else
      {
        action = "follow";
      }

      li += "<div><a href='#' onclick='toggleFollowState("+element[0]+")'><img class='stateF' src='/images/icons/light/20/btn_"+action+".png' height='13'widht='13' alt='"+action+"' title='"+action.capitalize()+"'/></a>";
    }

    if (element[3] == false) {
      li += "<a href='/channels/"+element[0]+"' target='_blank' style='float:right'><img src='/images/icons/light/20/btn_tv.png' height='13' widht='13' title='Go to channel'/></a>";
    }
    li+="</div></li>";


    ul_followers.insert ({bottom: li});
  });
  var strPaginate = "";
  if (previous || next) {
    if (previous) {
      strPaginate += "<li><img src='/images/icons/light/20/btn_back.png' width='12' height='12'  onclick='searchFollowing(null,"+previous+")'/></li>";
    }
    //strPaginate+= page;
    if (next) {
      strPaginate += "<li><img src='/images/icons/light/20/btn_forward.png' width='12' height='12'  onclick='searchFollowing(null,"+next+")'/></li>";
    }
  }
  $$("#paginate_followers ul").first().update(strPaginate);


}

