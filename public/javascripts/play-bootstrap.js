
/* Event binding */
var channel_modal = null;


//CLOSE WINDOW FUNCA
//Event.observe(window, "unload", function () { /*alert("close")*/ });

document.observe("dom:loaded", function() {
    Control.Window.baseZIndex= 500;
    channel_modal = new Control.Window($("create_channel"),{
        className: 'channel_modal',
        draggable: $("channel_draggable"),
        closeOnClick: $("close_channel_modal"),
        afterOpen: function () {
            $("channel_message").update("");
            $("channel_input_name").focus();
        }        
    });
    
if ( $("create_channel") ) {
  var channelVideoThumb = new Template('<div id="seed_#{id}"class="container"><div class="item_video" ><div class="head">#{title}</div>'+
'<div class="middle"><div class="thumb">#{image}'+
'<img class="play_button" src="/images/player/cancel.png" id="cancel_#{id}"></div></div></div></div>');


        Droppables.add("create_channel", {
          accept: 'video_draggable',
          onDrop: function(drag,drop,event) {
            console.log("seed " + drag.id);
            //$("seed_channel_image").shake();
            var video_id = drag.id;
            var seeds = $("seed_id").value.split(",");
            seeds = seeds.without("");
            if ( (video_id != NaN || video_id != "") && seeds.indexOf(""+video_id) == -1) {
                var video = playlistModel.get(video_id);
                var data_video = {  id: video.id, title: video.titleP(), image: video.thumbnailImg() };
                var videoThumb = channelVideoThumb.evaluate(data_video);
                console.log(videoThumb);
                $("seeds").insert ({
                            bottom: videoThumb
                        });              
               seeds.push(video_id);
               $("seed_id").value = seeds;  
               var seeds_width = seeds.length * 150;
                $("seeds").setStyle({width: seeds_width + 'px'});
               $("cancel_"+video_id).observe("click", function(event) {
                  $("seed_"+video_id).remove();
                  var seeds = $("seed_id").value.split(",");
                  seeds = seeds.without("");
                   $("seed_id").value = seeds.without(video_id);    
                }, {id: video_id});
            }
        } });
    
}

    $$('.show_button').each (function(element) {
        Event.observe(element.id,'click', showFacebookTabAction);
    });

    $$(".channel_thumb").each(function(el) {
        setDroppableChannel(el.id);
    });

      $("hide_playlist").observe("click", function(event) {
        Effect.BlindUp('playlist', { duration: 1.0, queue: 'end' });
   
     });

    $("show_playlist").observe("click", function(event) {
       if ($("playlist").visible() ) {
          Effect.BlindUp('playlist', { duration: 1.0, queue: 'end' });
        } 
        else
        {
              Effect.BlindDown('playlist', { duration: 1.0, queue: 'end' });
        }
    });

    if (userSignedIn == true && owner == true) {
        $("hide_create_channel").observe("click", function(event) {            
            channel_modal.close();
        });

        $("show_create_channel").observe("click", function(event) {
            if (!$("playlist").visible() ) {
                 Effect.BlindDown('playlist');
            }
            if (!$("create_channel").visible() ) {
              channel_modal.open();
            }
        });

    } 

});


