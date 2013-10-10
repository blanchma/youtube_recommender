var Mynewtv = {
  Version:        1.0,
  videos:          {},
  current_id:      '',
  current_title:   '',
  player:        null,
  
  createTitleList: function() {
    // log('making title list');
    ul = new Element('ul', {'id': 'mynewtv_titles'});
    title_li = new Element('li');
    title_li.update('Other videos you might enjoy:');
    lis = [title_li];
    Mynewtv.videos.each(function(pair) {
      // log('hi:', pair.value);
      a = new Element('a', {'onclick':"Mynewtv.cueVideoId('"+pair.key+"');return false;"}).update(pair.value);
      li = new Element('li', {'id': pair.key}).update(a);
      lis.push(li);
    });
    Mynewtv.player.insert({'after': ul});
    lis.each(function(li) {
      ul.insert({'bottom': li});
    });
  },
  
  setTitleHeader: function(title) {
    // log('making title header');
    if ($('mynewtv_title')) {
      h2 = $('mynewtv_title');
    } else {
      h2 = new Element('h2', {'id': 'mynewtv_title'});
      Mynewtv.player.insert({'after': h2});
    }
    h2.update(title);
  },
  
  createControls: function() {
    // log('making controls');
    var next = new Element('a', {'class':'mynewtv_button','href': '',  'onclick': 'Mynewtv.cueRandomVideo();return false;'   });
    next.update('NEXT VIDEO');
    if (Mynewtv.player) {
      Mynewtv.player.insert({'after': next});
      // Mynewtv.player.insert({'after': new Element('br')});
      Mynewtv.player.insert({'after': new Element('br')});
    } else {
      // log("no: ytplayer to add controls after!");
    }
  },
  
  embedYouTubePlayer: function(swfUrl) {
    // log("swfUrl:",swfUrl);

    // allowScriptAccess must be set to allow the Javascript from one 
    // domain to access the swf on the youtube domain
    var params = { allowScriptAccess: "always", bgcolor: "#cccccc" };

    // This sets the ID of the DOM object or embed tag to 'ytplayer'.
    // You can use this ID to access the swf and call the player's API
    var atts = { id: "ytplayer" };
    var flashvars = {};
    // log('about to embed', swfUrl);
    // swfobject.embedSWF(swfUrl, "ytapiplayer", "297", "167", "9", null, flashvars, params, atts);
    swfobject.embedSWF(swfUrl, "ytapiplayer", "640", "480", "9", null, flashvars, params, atts);
    // swfobject.embedSWF(swfUrl, "ytapiplayer", "320", "240", "9", null, flashvars, params, atts);
  }, 
  
  cueRandomVideo: function() {
    // log('grabbing next from: ', Mynewtv.videos);
    i = Math.floor(Math.random()*(Mynewtv.videos.size()+1));
    next_id = Mynewtv.videos.keys()[i];
    Mynewtv.cueVideoId(next_id);
  },
  
  
  cueVideoId: function(videoId) {
    // log('playing now: ', videoId);
    title = Mynewtv.videos.get(videoId);
    Mynewtv.videos.unset(videoId);
    $(videoId).hide();
    Mynewtv.setTitleHeader(title);
    Mynewtv.player.loadVideoById(videoId,0);
  }
};

function onYouTubePlayerReady(playerId) {
  // log('player ready!', playerId);
  Mynewtv.player = $(playerId);
  $(playerId).addEventListener('onStateChange', 'onYouTubePlayerStateChange');
  // log('added listeners');
  Mynewtv.videos.unset(Mynewtv.current_id);
  Mynewtv.createTitleList();
  Mynewtv.createControls();
  Mynewtv.setTitleHeader(Mynewtv.current_title);
}

function onYouTubePlayerStateChange(newState) {
  // log('new state: ', newState);
  ended = 0;
  error = -1;
  if (newState == ended || newState == ended) {
    // log('ended, queue next!');
    Mynewtv.cueRandomVideo();
  }
}
