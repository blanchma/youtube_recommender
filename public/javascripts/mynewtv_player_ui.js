
/* Event binding */
var channel_modal = null;


//CLOSE WINDOW FUNCA
//Event.observe(window, "unload", function () { /*alert("close")*/ });

Event.observe(document.onresize ? document : window, "resize", function (event) {

    var height = document.viewport.getHeight();
    var width = document.viewport.getWidth();


    var change = false;
    if (width != playlistView.docWidth) {
        playlistView.docWidth = width;
        change = true;
    }

    if (height != playlistView.docHeight) {
        playlistView.docHeight = height;
        change = true
    }

    if (change == true && playlistView != null) {
      if (player_ready == true) {
        playlistView.resizePlayer();
        playlistView.resizeUI();
      }
    }


});

document.observe("dom:loaded", function() {

    channel_modal = new Control.Window($("create_channel"),{
        className: 'channel_modal',
        draggable: $("channel_draggable"),
        closeOnClick: $("close_channel_modal"),
        afterOpen: function () {
            $("channel_message").update("");
            $("channel_input_name").focus();
        }
    });

/*
    var lastTimeoutHideRating = null;
    $("playlistView_player").observe("mouseover", function (event) {
        $("rating_actions").show();
        clearTimeout(lastTimeoutHideRating);
    //lastTimeoutHideRating = setTimeout("$('rating_actions').hide();",4000);
    });

    $("rating_actions").observe("mouseover", function (event) {
        clearTimeout(lastTimeoutHideRating);
        $("rating_actions").show();
    });

    $("playlistView_player").observe("mouseout", function (event) {
        lastTimeoutHideRating = setTimeout("$('rating_actions').hide()",2000);
    }); */

    $("global_message").observe("click", function(event) {
        hideGlobalMessage();

    });

    shortcut.add("Space",function() {
        playlistView.playOrPause();
    },
    {
        'disable_in_input':true
    }
    );
    shortcut.add("Up",function() {
        playlistView.likeCurrentVideo()
    }
    );
    shortcut.add("Down",function() {
        playlistView.hateCurrentVideo()
    }
    );
    shortcut.add("Right",function() {
        playlistView.cueNextVideo();
    }
    );
    shortcut.add("Left",function() {
        playlistView.cuePreviousVideo();
    }
    );

    $('btn_search_user').observe('click', searchUsers);
    $('search_users_input').observe('keyup', searchUsers);

    if (userSignedIn == true) {
        $('btn_search_followers').observe('click', searchFollowers);
        $('search_followers_input').observe('keyup', searchFollowers);


        $('btn_search_following').observe('click', searchFollowing);
        $('search_following_input').observe('keyup', searchFollowing);
    }

    $$('.show_button').each (function(element) {
        Event.observe(element.id,'click', showFacebookTabAction);
    });

    $$('.title_section').each (function(element) {
        Event.observe(element,'click', toggleBar );
    });
  
    
    $$(".channel_thumb").each(function(el) {
        setDroppableChannel(el.id);
    });

    $("global_message").observe("click", hideGlobalMessage);
    
    nextPlaylistOn("");
    
    prevPlaylistOn("");

});


