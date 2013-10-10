function popupCenter(url, width, height, name) {
  var left = (screen.width/2)-(width/2);
  var top = (screen.height/2)-(height/2);
  return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);
}



 var Cookie = {  
    
  key: 'cookies',  
    
  set: function(key, value) {  
   var cookies = this.getCookies();  
   cookies[key] = value;  
   var src = Object.toJSON(cookies).toString();  
   this.setCookie(this.key, src);  
  },  
    
  get: function(key){  
   if (this.exists(key)) {  
    var cookies = this.getCookies();  
    return cookies[key];  
   }  
   if (arguments.length == 2) {  
    return arguments[1];  
   }  
   return;  
  },  
    
  exists: function(key){  
   return key in this.getCookies();  
  },  
    
  clear: function(key){  
   var cookies = this.getCookies();  
   delete cookies[key];  
   var src = Object.toJSON(cookies).toString();  
   this.setCookie(this.key, src);  
  },  
    
  getCookies: function() {  
   return this.hasCookie(this.key) ? this.getCookie(this.key).evalJSON() : {};  
  },  
    
  hasCookie: function(key) {  
   return this.getCookie(key) != null;  
  },  
   
  setCookie: function(key,value) {  
   var expires = new Date();  
   expires.setTime(expires.getTime()+1000*60*60*24*365)  
   document.cookie = key+'='+escape(value)+'; expires='+expires+'; path=/';  
  },  
   
  getCookie: function(key) {  
   var cookie = key+'=';  
   var array = document.cookie.split(';');  
   for (var i = 0; i < array.length; i++) {  
    var c = array[i];  
    while (c.charAt(0) == ' '){  
     c = c.substring(1, c.length);  
    }  
    if (c.indexOf(cookie) == 0) {  
     var result = c.substring(cookie.length, c.length);  
     return unescape(result);  
    };  
   }  
   return null;  
  }  
 }

Ajax.Request.prototype.abort = function() {
    // prevent and state change callbacks from being issued
    this.transport.onreadystatechange = Prototype.emptyFunction;
    // abort the XHR
    this.transport.abort();
    // update the request counter
    Ajax.activeRequestCount--;
    if (Ajax.activeRequestCount < 0) {
        Ajax.activeRequestCount = 0;
    }
};



window.console||(console={log:function(){}});

var thread_message_id = null;

function setChannelMessage(message, error) { 
    //console.log("channel error: " + error);
    if (error == true) {
        $("channel_message").update(message);
        //$("channel_message").appear();
    }
    else {
        setSuccessMessage(message);
    }
} 

function setInfoMessage(message) {
    showGlobalMessage(message, "info");
}

function setWarningMessage(message) {
    showGlobalMessage(message, "warning");
}

function setSuccessMessage(message) {
    showGlobalMessage(message, "success");
}

function setErrorMessage(message) {
    showGlobalMessage(message, "error");  
}

function showGlobalMessage(message, cssclass) {
    if ( thread_message_id == null) {
        displayGlobalMessage(message, cssclass);
    }
    else
    {
        displayGlobalMessage.delay(5,message,cssclass);
    }
}

function displayGlobalMessage(message, cssclass) {
    var down = $("global_message").down("div");        
    
   
    $("global_message").writeAttribute("class", cssclass);
    if (message != "") {
        down.update(message);
        Effect.BlindDown("global_message", {duration: 0.5 });
        down.writeAttribute("class",cssclass);        
        thread_message_id = setTimeout("hideGlobalMessage(); thread_message_id=null", 4000);
    }
}

function hideGlobalMessage () {
    Effect.Fade('global_message', {duration: 0.4 });
}


function replaceDataForTwitterButton (title, mynewtv_url) {
    var decoded = $$("#share_tweet_button iframe").first().src;
    var to_replace = decoded.substring(decoded.indexOf("text")+5,decoded.indexOf("url") -1);
    decoded = decoded.replace(to_replace, encode("Check this out: " + title));

    to_replace = decoded.substring(decoded.indexOf("url")+4,decoded.indexOf("via") -1);
    decoded = decoded.replace(to_replace, encode( mynewtv_url));
    //console.log("New TwitterButton src="+decoded);
    $$("#share_tweet_button iframe").first().src = decoded;
}

function encode(string) {
    return encodeURIComponent(string);
}

function decode(string) {
    return decodeURIComponent(string.replace(/\+/g,  " "));
}



var lastSearch = null;


function searchUsers(event,arg2) {
    var searchUsersPath = '/users/search';
    var query = $("search_users_input").value;
    var page = arg2;
    if (query.length < 4) {
        if (lastSearch != null) {
            lastSearch.abort();
        }
        return;
    }
        
    if (page == undefined) {
        page = 1;
    }

    if (lastSearch != null) {
        lastSearch.abort();
    }

    lastSearch = new Ajax.Request(searchUsersPath,
    {
        method:'get',
        parameters: {
            query: query,
            page: page
        },
        onLoading: function () {
            $("users_search_loader").show();
        },
        onComplete: function () {
            $("users_search_loader").hide();
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            var results = transport.responseJSON;
            displayResultsUsers(results[0], results[1], page, results[2]);
        }
    });
}

function displayResultsUsers(previous, next, page, users) {

    /* Show each user */
    ul_users = $("results_user");
    ul_users.update("");
    users.each(function(element, index) {
        var name = element[1];
        if (name.length > 40) {
            name = name.substring(0,40) + "...";
        }
        /* Insert name */
        li = "<li id='user_"+element[0]+"'title='"+element[1]+"' >";
        li += "<a class='name' href='/play/"+element[5]+"' target='_blank'>"+name+"</a>";

        /*Insert follow/unfollow and channel link */
        if (element[2] == true) {
            action = "unfollow";
        }
        else
        {
            action = "follow";
        }

        li += "<div>";
        if (userSignedIn) {
            li += "<a href='#' onclick='toggleFollowState("+element[0]+")'><img class='stateF' src='/images/icons/light/20/btn_"+action+".png' height='13'widht='13' alt='"+action+"' title='"+action.capitalize()+"'/></a>";
        }

        if (element[3] == false) {
            li += "<a href='/play/"+element[5]+"' target='_blank'><img src='/images/icons/light/20/btn_tv.png' height='13' widht='13' title='Go to channel'/></a>";
        }

        if (element[6] == true) {
            li += "<a href='/snoop/"+element[5]+"'><img src='/images/icons/btn_eye.png' height='13' widht='13' title='Snoop "+ name +"'/></a>";
        }

        li+="</div></li>";

        ul_users.insert ({
            bottom: li
        });
    });

    var strPaginate = "";
    if (previous || next) {
        if (previous) {
            strPaginate += "<li><img src='/images/icons/light/20/btn_back.png' width='12' height='12' onclick='searchUsers(null,"+previous+")'/></li>";
        }
        //strPaginate+= page;
        if (next) {
            strPaginate += "<li><img src='/images/icons/light/20/btn_forward.png' width='12' height='12' onclick='searchUsers(null,"+next+")'/></li>";
        }
    }
    $$("#paginate_users ul").first().update(strPaginate);
    if (users.length == 0) {
        ul_users.update("No results for this query");
    }

}


function toggleFollowState(id,remove) {
    var editFollowPath = '/users/toggle_follow';
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
    searchFollowing();
}

var lastSearchFollowers = null;

function searchFollowers(event,arg2) {
    var followersPath = '/users/followers';
    var query = $("search_followers_input").value;
    if (query.length < 4 && query.length > 0) {
        return;
    }
    var page = arg2;
    if (page == undefined) {
        page = 1;
    }

    if (lastSearchFollowers != null) {
        lastSearchFollowers.abort();
    }

    lastSearchFollowers = new Ajax.Request(followersPath,
    {
        method:'get',
        parameters: {
            query: query,
            page: page,
            user_id: userSignedIn
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            var results = transport.responseJSON;
            displayFollowers(results[0], results[1], page, results[2]);
        }
    });
}

function displayFollowers(previous, next, page, users) {

    /* Show each user */
    ul_followers = $("results_followers");
    ul_followers.update("");
    users.each(function(element, index) {
        var name = element[1];
        if (name.length > 40) {
            name = name.substring(0,40) + "...";
        }
        /* Insert name */
        li = "<li id='user_"+element[0]+"' title='"+element[1]+"' >";
        li += "<a class='name' href='/play/"+element[5]+"' target='_blank'>"+name+"</a>";

        /*Insert follow/unfollow and channel link */
        if (element[2] == true) {
            action = "unfollow";
        }
        else
        {
            action = "follow";
        }

        li += "<div><a href='#' onclick='toggleFollowState("+element[0]+")'><img class='stateF' src='/images/icons/light/20/btn_"+action+".png' height='13'widht='13' alt='"+action+"' title='"+action.capitalize()+"'/></a>";

        if (element[3] == false) {
            li += "<a href='/play/"+element[5]+"' target='_blank'><img src='/images/icons/light/20/btn_tv.png' height='13' widht='13' title='Go to channel'/></a>";
        }
        if (element[6] == true) {
            li += "<a href='/snoop/"+element[5]+"'><img src='/images/icons/btn_eye.png' height='13' widht='13' title='Snoop "+ name +"'/></a>";
        }


        li+="</div></li>";


        ul_followers.insert ({
            bottom: li
        });
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

var lastSearchFollowings = null;

function searchFollowing(event,arg2) {
    var followingPath = '/users/following';
    var query = $("search_following_input").value;
    var page = arg2;
        
    if (query.length < 4 && query.length > 0) {
        return;
    }

    if (page == undefined) {
        page = 1;
    }

    if (lastSearchFollowings != null) {
        lastSearchFollowings.abort();
    }

    lastSearchFollowings = new Ajax.Request(followingPath,
    {
        method:'get',
        parameters: {
            query: query,
            page: page,
            user_id: userSignedIn
        },
        onSuccess: function(transport){
            var response = transport.responseText || "no response text";
            var results = transport.responseJSON;
            displayFollowing(results[0], results[1], page, results[2]);
        }
    });
}


function displayFollowing(previous, next, page, users) {

    /* Show each user */
    ul_following = $("results_following");
    ul_following.update("");
    users.each(function(element, index) {
        var name = element[1];
        if (name.length > 40) {
            name = name.substring(0,40) + "...";
        }
        /* Insert name */
        li = "<li id='user_"+element[0]+"' title='"+element[1]+"' >";
        li += "<a class='name' href='/play/"+element[5]+"' target='_blank'>"+name+"</a>";
        /*Insert follow/unfollow and channel link */
        if (element[2] == true) {
            action = "unfollow";
        }
        else
        {
            action = "follow";
        }

        li += "<div><a href='#' onclick='toggleFollowState("+element[0]+")'><img class='stateF' src='/images/icons/light/20/btn_cerrar.png' height='13'widht='13' alt='"+action+"' title='"+action.capitalize()+"'/></a>";

        if (element[3] == false) {
            li += "<a href='/play/"+element[5]+"' target='_blank'><img src='/images/icons/light/20/btn_tv.png' height='13' widht='13' title='Go to channel'/></a>";
        }

        if (element[6] == true) {
            li += "<a href='/snoop/"+element[5]+"'><img src='/images/icons/btn_eye.png' height='13' widht='13' title='Snoop "+ name +"'/></a>";
        }


        li+="</div></li>";


        ul_following.insert ({
            bottom: li
        });
    });
    var strPaginate = "";
    if (previous || next) {
        if (previous) {
            strPaginate += "<li><img src='/images/icons/light/20/btn_back.png' width='12' height='12'  onclick='searchFollowers(null,"+previous+")'/></li>";
        }
        //strPaginate+= page;
        if (next) {
            strPaginate += "<li><img src='/images/icons/light/20/btn_forward.png' width='12' height='12'  onclick='searchFollowers(null,"+next+")'/></li>";
        }
    }
    $$("#paginate_following ul").first().update(strPaginate);
}

function toggleBar (event) {
    var el = event.element();
    var bar = el;
    if (el.inspect().indexOf("<div") == 0) {
        bar = el.down('img');
    }
    if (el.inspect().indexOf("<span") == 0) {
        bar = el.up('div').down('img');
    }
    //console.log ("bar="+bar);

    var section = bar.id.substring(bar.id.indexOf("_")+1);
    var id_section = "wrapper_" + section;
    //$(id_section).toggle();
    Effect.toggle(id_section, 'slide',{
        duration: 0.3
    });
    if (bar.alt == "max") {
        bar.alt="min";
        bar.src="/images/icons/light/20/btn_minimize.png";
    }
    else
    {
        bar.alt="max";
        bar.src="/images/icons/light/20/btn_maximize.png";
    }

}



var FeedsController = Class.create({

    initialize: function(initTime,recursionTime) {
        this.lastEventId = null;
        this.currentPageEvent = 1;
        this.even = false;
        this.initTime = initTime;
        this.recursionTime = recursionTime;
        this._videos = new Hash;

    },

    videos: function () {
        return this._videos;
    },

    configFeeds: function() {
        feedsController.searchEvents.delay(this.initTime, 1);
        new PeriodicalExecuter(feedsController.checkNewEvents, this.recursionTime);
    },

    checkNewEvents: function() {
        console.log("checkNewEvents")
        var _this = this;
        lastEventId = this.lastEventId;
        new Ajax.Request('/events',
        {
            method:'get',
            parameters: {
                user_id: signedUserId,
                last_id: lastEventId
            },
            onSuccess:function(transport) {
                var response = transport.responseText || "no response text";
                var new_events = transport.responseJSON;
                //console.log ("lastId: " + this.lastEventId);
                //console.log ("newEvents: " + new_events);
                if (new_events.length > 0  && _this.currentPageEvent > 1) {
                    _this.searchEvents(1);
                }
                else if (new_events.length > 0)
                {
                    _this.addEvents(new_events, false);
                }
                else {

            }

            }
        });
    },

    searchEvents: function(page) {
        console.log("searchEvents for page:" + page);
        var _this = this;

        new Ajax.Request('/events',
        {
            method:'get',
            parameters: {
                user_id: signedUserId,
                page: page
            },
            onSuccess:function(transport) {
                var response = transport.responseText || "no response text";
                var results = transport.responseJSON;
                //console.log ("searchEvents: " + results);
                _this.displayEvents(results[0], results[1], results[2], page);
            }
        });

    },

    displayEvents: function(previous, events, next, page) {

        this.currentPageEvent = page;
        this.addEvents(events, true);

        var strPaginate = "";

        if (previous || next) {
            if (previous) {
                strPaginate += "<li><img src='/images/icons/light/20/btn_back.png' width='12' height='12'  onclick='feedsController.searchEvents("+previous+")'/></li>";
            }

            if (next) {
                strPaginate += "<li><img src='/images/icons/light/20/btn_forward.png' width='12' height='12'  onclick='feedsController.searchEvents("+next+")'/></li>";
            }
        }
        $$("#paginate_events ul").first().update(strPaginate);



    },

    addEvents: function(events, clear) {
        ul_events = $("results_events");

        if (clear == true) {
            ul_events.update("");
            this._videos = new Hash;

        }
        //onclick='Mynewtv.cueExternal(\"ev_#{id}\")'
        events.each (function (event) {
            var css_class = this.even ? "even" : "";
            this.even = !this.even;
            //console.log ("id: " +  event.id);
            var li = "<li id=ev_" + event.id + " class='item-event' > " + event.message + " </li>";
            if (clear == true) {
                ul_events.insert ({
                    bottom: li
                });
            }
            else
            {
                ul_events.insert ({
                    top: li
                });
            }
            var cueExternal = $("ev_"+event.id).down("a.cueExternal");
            if (cueExternal) {
                cueExternal.writeAttribute("onclick", "playlistController.cueExternal('ev_"+event.id+"')" );
            }

            if (this.currentPageEvent == 1 && !clear) {
                //console.log ("is a new event? " + event.id > this.lastEventId);
                if (event.id > this.lastEventId) {
                    Effect.Pulsate("ev_" + event.id , {
                        pulses: 2,
                        duration: 1.5
                    });
                }
            }

            if (ul_events.childElements().length > 5) {
                var last = ul_events.childElements().last();
                if (this.currentPageEvent == 1  && !clear) {
                    Effect.DropOut(last.id);
                    if (last) {
                        last.remove();
                    }
                }
                else
                {
                    if (last) {
                        last.remove();
                    }
                }
            }
            this.lastEventId = this.lastEventId < event.id ? event.id : this.lastEventId;
            this.videos().set("ev_"+event.id, event.video);

            this.updateLinksToVideos();

        }, this );
    },

    updateLinksToVideos: function() {

        $$(".pop_up_video").each(function(el) {
            el.remove()
        });

        $$("#results_events li a[video=true]").each(function(el) {
            var preview = new Control.Window(el,{
                className: 'pop_up_video',
                position: 'mouse',
                hover: true,
                offsetLeft: 30,
                iframe: false

            });
            var event_id = el.up("li").id;//.substring(3);
            var videoAsJson = feedsController.videos().get(event_id);
            preview.container.insert("<div><div class='float left'><img src='"+videoAsJson.thumb_url+"' width='106' heigh='89'> </div><div class='float middle'><p class='title'> "+videoAsJson.title+"</p><p class='author'>By: "+videoAsJson.author+"</p></div></div>");

        });
    }

});
  

 function shareOnFacebook(video)   {
        FB.ui(
        {
            method: 'feed',
            display: 'popup',
            name: player.currentVideo.title,
            link: player.currentVideo.mynewtvUrl(),
            picture: player.currentVideo.thumb_url,
            caption: 'http://MyNew.TV',
            description: player.currentVideo.description,
            message: 'Check this out!'
        },
        function(response) {
            console.log("post to fb: "+ response.post_id);
          }
        );
}


function publishAllLikedOnFacebook (event) {
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
    }

function publishAllLikedOnTwitter (event) {
        new Ajax.Request('/user/publish_tw',
        {
            method:'post' ,
            onSuccess: function (transport) {
                refreshPublishTw();
            }
        });
    }


function refreshPublishTw () {
    new Ajax.Request('/user/publishing_to_tw',
    {
        method:'get',
        onSuccess:function(transport) {
            var response = transport.responseText;
            if (response == "true") {
                $("publish_tw").src="/images/icons/btn_twitter_color.png";
                $("publish_tw").writeAttribute("publish", "true");
            }
            else
            {
                $("publish_tw").src="/images/icons/light/btn_twitter.png";
                $("publish_tw").writeAttribute("publish", "false");
            }
        }
    });

}




