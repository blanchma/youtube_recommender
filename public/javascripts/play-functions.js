
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

function addVideoToChannel(video_id,channel) {
    console.log ("Add video: " +  video_id);
    new Ajax.Request("/users/" + userId + "/channels/" + channel + "/add/",
    {
        method: 'post',
        parameters: {
            vid : video_id
        }
    });    
}

function querySearchVideos() {
    playlistController.querySearchVideos( $('search_field').value  );
}

function showFacebookTabAction(event) {
    var _el = event.element();
    //console.log("showAction = " + _el);
    var target = _el.readAttribute("target");


    $$(".tab").each( function(el) {
        el.hide();
    });

    $(target).show();
}

function showFbLikeTab () {
    $$(".tab").each( function(el) {
        el.hide();
    });

    $('fb_like').show();
}

function clearTextArea(id) {
    $(id).value="";
}

function sendFeed () {
    var textFeed = $("feed_text").value;
    var friendName = $("fb_friend_name").value;
    var friendId = $("fb_friend_id").value;

    new Ajax.Request('/facebook_invitations',
    {
        method:'post',
        parameters: {
            id: friendId,
            msg: textFeed,
            friend_name: friendName
        },
        onLoading:function () {
            toggleLoaderFbTabs();
            $("comment_text").hide();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            toggleLoaderFbTabs();
            $("fb_feed_id").value= response;
            $("delete_feed").show();
            $("feed_text").value= "Invitation successfully sent";
            setTimeout("clearTextArea('feed_text')",2000 );
            $("comment_text").show();

        },
        onFailure: function(){
            $("feed_text").value= "An error ocurred.Try later.";
            toggleLoaderFbTabs();
            $("comment_text").show();
        }
    });
}


function deleteFeed() {
    var feedId =  $("fb_feed_id").value;
    new Ajax.Request('/facebook_invitations/'+feedId,
    {
        method:'delete',
        onLoading:function () {
            toggleLoaderFbTabs();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            toggleLoaderFbTabs();
            $("fb_feed_id").value= "";
            $("delete_feed").hide();
        },
        onFailure: function(){
        }
    });
}
function sendComment () {
    var postId = $("fb_post_id").value;
    var textComment = $("comment_text").value;

    new Ajax.Request('/facebook_comments',
    {
        method:'post',
        parameters: {
            id: postId,
            msg: textComment
        },
        onLoading:function () {
            toggleLoaderFbTabs();
            $("comment_text").hide();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            toggleLoaderFbTabs();
            $("fb_comment_id").value= response;
            $("delete_comment").show();
            $("comment_text").value= "Comment succesfully sent.";
            setTimeout("clearTextArea('comment_text')",2000 );
            $("comment_text").show();
        },
        onFailure: function(){
            $("comment_text").show();
        }
    });
}

function deleteComment() {
    var commentId =  $("fb_comment_id").value;
    new Ajax.Request('/facebook_likes/'+commentId,
    {
        method:'delete',
        onLoading:function () {
            toggleLoaderFbTabs();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            toggleLoaderFbTabs();
            $("fb_comment_id").value= "";
            $("delete_comment").hide();
        },
        onFailure: function(){
            toggleLoaderFbTabs();
        }
    });
}

function toggleLoaderFbTabs() {
    $$("#action_area .fb_tab .facebook_loader").each(function (element) {
        element.toggle();
    });
}

function displayLikes() {
    var likes = parseInt ( $("fb_post_likes").value );
    var liked = $("fb_post_liked").value;
    // console.log ("likes= "+ likes);
    if (liked == "true") {
        $("like_this").hide();
        $("unlike").show();
    }
    else
    {
        $("like_this").show();
        $("unlike").hide();
    }

    if (liked == "true" && likes == 0) {
        $("people_likes").update("You like this.");
    }
    else if (liked == "true" && likes > 1) {
        $("people_likes").update("You and "+likes+ " others like this.");
    }
    else if (liked == "true" && likes == 1) {
        $("people_likes").update("You and other like this.");
    }
    else if (liked == "false" && likes > 0) {
        $("people_likes").update(likes + " people like this.");
    }
    else
    {
    }

}

function toggleLoaderInLikes() {
    $$("#action_area #like_loader").first().toggle();
}


function checkLikes() {
    var postId = $("fb_post_id").value;
    if (postId == '') {
        return;
    }

    new Ajax.Request('/facebook_likes/'+postId,
    {
        method:'get',
        onLoading: function() {
            toggleLoaderInLikes();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            toggleLoaderInLikes();
            var array = transport.responseJSON;
            var liked = array[0];
            $("fb_post_liked").value= liked;
            var likes = array[1];
            $("fb_post_likes").value= likes;
            var comment_likes_id = array[2];
            $("fb_comment_liked_id").value= comment_likes_id;
            displayLikes();
            $("fb_ready_to_like").value=true;
        },
        onFailure: function(){
        }
    });
}


function destroyLike() {
    var postId = $("fb_post_id").value;
    commentId = $("fb_comment_liked_id").value;
    if (postId == '') {
        return;
    }
    new Ajax.Request('/facebook_likes/'+postId,
    {
        method:'delete',
        parameters: {
            comment_id: commentId
        },
        onLoading: function() {
            toggleLoaderInLikes();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            toggleLoaderInLikes();
            $("fb_post_liked").value= "false";
            displayLikes();
        },
        onFailure: function(){
        }
    });
}

function likePost() {
    if (! $("fb_ready_to_like").value == true ) {
        //console.log("too soon to likePost... waiting...");
        setTimeout("likePost()", 10000);
        return;
    }
    //console.log("All ready to likePost!");

    var postId = $("fb_post_id").value;
    if (postId == '') {
        return;
    }
    new Ajax.Request('/facebook_likes',
    {
        method:'post',
        parameters: {
            id: postId
        },
        onLoading: function() {
            toggleLoaderInLikes();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            $("fb_comment_liked_id").value=response;
            toggleLoaderInLikes();
            $("fb_post_liked").value= "true";
            displayLikes();
        },
        onFailure: function(){

        }
    });
}

function sendMailInvitation () {
    var friendName = $("fb_friend_name").value;
    var emailAddress = $("friend_mail").value;
    var valid = validateEmail(emailAddress);

    if (valid) {
        $("msg_mail").update("");
        $("msg_mail").removeClassName("good_msg");
        $("msg_mail").removeClassName("error_msg");
    }
    else
    {
        $("msg_mail").addClassName("error_msg");
        $("msg_mail").removeClassName("good_msg");
        $("msg_mail").update("Invalid email");
        return;
    }

    new Ajax.Request('/mail_invitations',
    {
        method:'post',
        parameters: {
            email: emailAddress,
            friend_name: friendName
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            $("msg_mail").addClassName("good_msg");
            $("msg_mail").removeClassName("error_msg");
            $("msg_mail").update("Email successfully sent.");
        },
        onFailure: function(){

        }
    });
}


function validateEmail(mail){
    re=/^[_a-z0-9-]+(.[_a-z0-9-]+)*@[a-z0-9-]+(.[a-z0-9-]+)*(.[a-z]{2,3})$/
    if(!re.exec(mail))    {
        return false;
    }else{
        return true;
    }
}




function followFbUser() {
    var user_id = $("mynewtv_id").value;
    $('follow_fb').hide();
    $('unfollow_fb').show();
    $("status_follow").update("Now you are following ");
}

function unfollowFbUser() {
    var user_id = $("mynewtv_id").value;
    $('follow_fb').show();
    $('unfollow_fb').hide();
    $("status_follow").update("You are no longer following ");
}

function toggleFollow(user_id) {
    var editFollowPath = '/users/toggle_follow';
    new Ajax.Request(editFollowPath,
    {
        method:'post',
        parameters: {
            id: user_id
        }
    });
}

function imgError(source){
    var id = source.id.substring(5);
    source.onerror = "";
    source.src = "/images/icons/broken.png";
     
    video = playlistModel.get(id);
    video.setThumb("/images/icons/broken.png");
    return true;
}


function doubleDigits(x) {
    if (x==0) {
        return "00";
    } else if (x < 10) {
        return "0"+x;
    } else {
        return x;
    }
}

function durationHumanized(secs) {
    /* var hours   = Math.floor(duration/3600);
  var minutes = Math.floor((duration - (hours*3600))/60);
  var seconds = duration - (hours*3600) - (minutes*60);

  hours   = this.doubleDigits(hours);
  minutes = this.doubleDigits(minutes);
  seconds = this.doubleDigits(seconds);

  if (hours != "00") {
    return hours+":"+minutes+":"+seconds;
  } else {
    return minutes+":"+seconds;
  }   */
}


  


/* General Functions */

function setDroppableChannel(id) {
    //alert(id);
    Droppables.add(id, {
        accept: 'video_draggable',
        onDrop: function(drag,drop,event) {
            console.log("drop inside channel");
            new Effect.Puff(drag.id);
            new Effect.Shake(drop.id);
            var drop_id = drop.id;
            var channel_id= drop_id.substring(drop_id.indexOf("item")+ 5, drop_id.length);
            addVideoToChannel(drag.id,channel_id);
        }
    } );

}

function setDraggableVideo(id) {
    new Draggable(id, {
        onEnd: function(video, event) {
            console.log("revert");
        },  
        ghosting: true,
        revert: true

    });
}

function showPlayButton(event) {
    if ( event.element().up(".item_video") != undefined ) {
        event.element().up(".item_video").down(".play_button").show();
    }
}

function hidePlayButton(event) {
    if ( event.element().up(".item_video") != undefined ) {
        event.element().up(".item_video").down(".play_button").hide();
    }
}



function hideAudioRecorder ( ) {
    flv_window = $("rec_audio_window");
    new Effect.SlideUp(flv_window);
    new Effect.SlideDown($('button_to_rec'));
}

function toggleRecorder(event) {
    flv_window = $("rec_audio_window");
    if (flv_window.visible() ) {
        hideAudioRecorder();
    }
    else
    {
        new Effect.SlideDown(flv_window);
        $("video_commented").value = playlistController.currentVideo.id;
        $("video_title").update("");
        $("video_title").update(playlistController.currentVideo.title);
        new Effect.SlideUp($('button_to_rec'));
    }
}



function makeFixed(element) { 
  element = $(element); 
  // Make sure that the element's "offset parent" is the document itself; 
  // i.e., that it has no non-statically-positioned parents 
  element.setStyle({ position: "absolute" }); 
  function adjust() { 
    // Set the element's CSS "top" to the scroll offset of the window 
    element.style.top = window.scrollTop + "px"; 
  } 
  // Re-adjust whenever the window scrolls 
  Event.observe(window, "scroll", adjust); 
  adjust(); 
} 




