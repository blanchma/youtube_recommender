var User = Class.create({

    initialize: function(userName, userId, userSlug, owner) {
        this.name = userName;
        this.id = userId;
        this.slug = userSlug;
        this.owner=false;
        this.synchronize();
    },
  
    synchronize: function () {
        _this = this;
        new Ajax.Request('/users/' + this.id + '/info',
        {
            method:'get',
            onSuccess: function(transport){
                var response = transport.responseJSON || "no response text";
                   
                _this.channel_id = response.id;
                $("count_likes").update( response.likes );
                _this.likes = response.likes;
                $("count_hates").update( response.hates );
                _this.hates = response.hates;
                $("count_followers").update( response.count_followers );
                _this.followers = count_followers;
                if (userSignedIn) {
                    if (response.is_follower == true) {
                        $("follow_current").src="/images/icons/channel/follow.png";
                        $("follow_current").title="Click to stop following this user";
                        $("follow_current").observe("click", _this.unfollow.bindAsEventListener(_this));
                    }
                    else
                    {
                        $("follow_current").src="/images/icons/channel/unfollow.png";
                        $("follow_current").title="Click to start following this user";
                        $("follow_current").observe("click", _this.follow.bindAsEventListener(_this) );
                    }
                    _this.following = response.following;
                }
                $("channel_info").show();
                 
            }
        });
    },

    unfollow: function (event) {
        _this = this;
        console.log ("unfollow current user");
        new Ajax.Request("/users/" + _this.id + "/unfollow",
        {
            method: 'post',
            onSuccess: function (transport){
                var response = transport.responseJSON;
                if (response == true) {
                    $("follow_current").src="/images/icons/channel/unfollow.png";
                    $("follow_current").title="Click to start following this user";
                    $("follow_current").stopObserving("click", _this.unfollow );
                    $("follow_current").observe("click", _this.follow.bindAsEventListener(_this));
                    _this.following = false;
                }
            }
        });
    },

    follow: function (event) {
        _this = this;
        console.log ("follow current user");
        new Ajax.Request("/users/" + _this.id + "/follow",
        {
            method: 'post',
            onSuccess: function (transport){
                var response = transport.responseJSON;
                if (response == true) {
                    $("follow_current").src="/images/icons/channel/follow.png";
                    $("follow_current").title="Click to stop following this user";
                    $("follow_current").stopObserving("click", _this.follow );
                    $("follow_current").observe("click", _this.unfollow.bindAsEventListener(_this));
                    _this.following = true;
                }
            }
        });
    }
   
});


var Channel = Class.create({
    initialize: function(channelName, channelId, channelSlug, owner) {
        this.name = channelName;
        this.id = channelId;
        this.slug = channelSlug;
        this.likes = 0;
        this.hates = 0;
        this.owner = owner;
        this.followers = 0;
        this.following = false;
        this.synchronize();

    },
  
    synchronize: function () {
        _this = this;
        new Ajax.Request('/channels/' + this.id + '/info',
        {
            method:'get',
            onSuccess: function(transport){
                var response = transport.responseJSON || "no response text";
                   
                _this.channel_id = response.id;
                $("count_likes").update( response.likes );
                _this.likes = response.likes;
                $("count_hates").update( response.hates );
                _this.hates = response.hates;
                $("count_followers").update( response.count_followers );
                _this.followers = count_followers;
                if (userSignedIn) {
                    if (response.is_follower == true) {
                        $("follow_current").src="/images/icons/channel/follow.png";
                        $("follow_current").title="Click to stop following this channel";
                        $("follow_current").observe("click", _this.unfollow.bindAsEventListener(_this));
                    }
                    else
                    {
                        $("follow_current").src="/images/icons/channel/unfollow.png";
                        $("follow_current").title="Click to start following this channel";
                        $("follow_current").observe("click", _this.follow.bindAsEventListener(_this) ) ;
                    }
                    _this.following = response.following;
                }
                $("channel_info").show();
                 
            }
        });
     
    },


    unfollow: function (event) {
        _this = this;
        console.log ("unfollow current channel");
        new Ajax.Request("/channels/" + _this.id + "/unfollow",
        {
            method: 'post',
            onSuccess: function (transport){
                var response = transport.responseJSON;
                if (response == true) {
                    $("follow_current").src="/images/icons/channel/unfollow.png";
                    $("follow_current").title="Click to start following this channel";
                    $("follow_current").stopObserving("click", _this.unfollow );
                    $("follow_current").observe("click", _this.follow.bindAsEventListener(_this));
                    _this.following = false;
                }
            }
        });
    },

    follow: function (event) {
        _this = this;
        console.log ("follow current channel");
        new Ajax.Request("/channels/" + _this.id + "/follow",
        {
            method: 'post',
            onSuccess: function (transport){
                var response = transport.responseJSON;
                if (response == true) {
                    $("follow_current").src="/images/icons/channel/follow.png";
                    $("follow_current").title="Click to stop following this channel";
                    $("follow_current").stopObserving("click", _this.follow );
                    $("follow_current").observe("click", _this.unfollow.bindAsEventListener(_this));
                    _this.following = true;
                }
            }
        });
    }

});


var PlaylistModel = Class.create({
    initialize: function() {
        this.className = 'PlaylistModel';
        this._videos = new Hash;
        this._playlistIds = [];
        this._searchlistIds = [];   

        this.config = false;
        this.initialPath = null;
        this.nextPath = '/next_video/';
        this.previousPath = '/prev_video/';
        
        this.requestingId = [];
        this.requestNextCounter = 0;
        this.requestPrevCounter = 0;
        this.lastIdRequestNext = null;
        this.lastIdRequestPrev = null;    
        this.requestingTimeouts = new Hash;
        this.synchronize();           
    },

    synchronize: function() {
        /* To stop double configuration bug in Firefox/Ubuntu */
        if (this.config == true) {
            return;
        }
        var _this = this;
        vid = hashtrack.get("vid");        
        
        if (channelSlug == "public") {
            this.initialPath = '/public';
            this.previousPath = '/public/prev/';
            this.nextPath = '/public/next/';
            setInfoMessage("You are watching MyNew.Tv channel. Please, Sign In to get your own personalized channel.");
        }
        else if (channelId) {
            this.initialPath = '/channels/'+currentChannel.id;
            this.previousPath = '/channels/'+currentChannel.id+'/prev/';
            this.nextPath = '/channels/'+currentChannel.id+'/next/';            
            setTimeout("setInfoMessage('You are watching ' + currentChannel.name + ' channel.')",4000);
        }
        else if (owner == true) {
            this.initialPath = '/user_playlist/';
            this.previousPath = '/prev_video/';
            this.nextPath = '/next_video/';
        }
        else if (userId) {
            this.initialPath = '/user_channels/'+userId;
            this.previousPath = '/user_channels/' + userId + '/prev/';
            this.nextPath = '/user_channels/' + userId + '/next/';
        }       
        else 
        {
            console.log("Disoriented");                 
        }
        
        new Ajax.Request(this.initialPath,
        {
            method:'get',
            parameters: {
                vid: vid
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";
                var array = transport.responseJSON;
                _this.append(array,true);
                

                //fireEvent
                Event.fire(document, "playlist:initial").delay(4);
            },
            onFailure: function(){ 
                console.log("failInitial: " + this.initialPath);
            }
        });
        
      
        /* To stop double configuration bug in Firefox/Ubuntu */
        this.config = true;
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
        else
        {
            if (!this.requestPreviousVideo(videoId) )  {
                Event.fire(document, "playlist:previous:loading", 
                {
                    id: this.previousRequestPath()
                });
            }
        }
    },

    next: function (videoId) {
        var nextIndex = this._playlistIds.indexOf(videoId) + 1;
        var nextVideoId = this._playlistIds[nextIndex];
        if (nextVideoId == undefined) {
            if (!this.requestNextVideo(videoId) ) {
                Event.fire(document, "playlist:next:loading", 
                {
                    id: this.nextRequestPath()
                });
            }
        }        
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
                if (!this._playlistIds.include(v.id)) {                   
                    this._videos.set(v.id, v);
                    this._playlistIds.push(v.id);
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
            if (!this._playlistIds.include(v.id)) {
                this._videos.set(v.id, v);
                this._playlistIds.push(v.id);
                result.push(v);
            }
            else {
                result.push(this.get(v.id) ) ;
            }
        }

        if (result.length > 0 && notifyView == true ) {
            Event.fire(document, "playlist:append", {
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
                if (!this._playlistIds.include(v.id)) {                   
                    this._videos.set(v.id, v);
                    this._playlistIds.unshift(v.id);
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
            if (!this._playlistIds.include(v.id)) {
                this._videos.set(v.id, v);
                this._playlistIds.unshift(v.id);
                result.push(v);
            }
            else {
                result.push(this.get(v.id) ) ;
            }
        }

        if (result.length > 0 && notifyView == true ) {
            Event.fire(document, "playlist:prepend", {
                videos : result
            });
        }

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
    },

    isRequestingPrevious: function () {
        return this.requestPrevCounter > 0;
    },

    requestPreviousVideo: function (id) {
        var _this = this;
        
        if (id == undefined) {
            var id = this.first().id;
        }
        var path = this.previousPath + id;
     

        if ( this.lastIdRequestPrev == id) {
            return false;
        }

        var arrayIds = this.ids().toArray();
        var _ids = arrayIds.inspect();     

        var lastRequest = new Ajax.Request(path,
        {
            method:'get',
            parameters: {
                ids : _ids
            },
            onLoading: function () {
                Event.fire(document, "playlist:previous:loading", {
                    id : path
                });
                _this.requestPrevCounter++;
            },
            onSuccess: function(transport){
                var response = transport.responseText || "no response text";

                if (response != "false") {                                   
                    var video_json = transport.responseJSON;
                    result = _this.prepend(video_json, false);
                    Event.fire(document, "playlist:previous:success", {
                        id : result[0].id,
                        path :path
                    });
                } 
                else
                {
                    Event.fire(document, "playlist:previous:false", {
                        id : path
                    });
                }
            },
            onFailure: function(response){
                Event.fire(document, "playlist:previous:fail", {
                    id : path
                });
            },
            onComplete: function(response){
                _this.requestPrevCounter--;
                _this.removeRequest(lastRequest.url);
                _this.lastIdRequestPrev = null;
              
            }
        });
        this.lastIdRequestPrev = id;
        lastIndexRequest = this.addRequest (lastRequest);
        return true;
    },

    isRequestingNext: function () {
        return this.requestNextCounter > 0;
    },

    requestNextVideo: function (id) {
        var _this = this;
        
        if (id == undefined) {
            var id = this.last().id;
            if (id == undefined) {
                return;
            }
        }
        var path = this.nextPath + id;

        if ( this.lastIdRequestNext == id) {
            return false;
        }

        var arrayIds = this.ids().toArray();
        var _ids = arrayIds.inspect();


        var lastRequest = new Ajax.Request(path,
        {
            method:'get',
            parameters: {
                ids : _ids
            },
            onLoading: function () {
                Event.fire(document, "playlist:next:loading", {
                    id : path
                })
                _this.requestNextCounter++;
            },
            onSuccess: function(transport){

                var response = transport.responseText || "no response text";                
                
                if (response != "false") {
                    var video_json = transport.responseJSON;
                    result = _this.append(video_json,false);
                    Event.fire(document, "playlist:next:success", {
                        id : result[0].id,
                        path :path
                    });
                } 
                else 
                {
                    Event.fire(document, "playlist:next:false", {
                        id : path
                    });
                }
            },           
            onFailure: function(response){
                console.log("fail requestNextVideo");
                Event.fire(document, "playlist:next:fail", {
                    id : path
                });
            },
            onComplete: function(response){
                _this.requestNextCounter--;
                _this.removeRequest(lastRequest.url);             
                _this.lastIdRequestNext = null;
            }
        });
        this.lastIdRequestNext = id;
        lastIndexRequest = this.addRequest (lastRequest);
        return true;
    },
    
    abortRequest: function (url) {
        console.log("abortRequest: " +  url);
        var request = this.getRequest(url);
        if (request) {
            request.abort();
            this.removeRequest(request);
        }
              
        request.options.onFailure();
        request.options.onComplete();
    },

    addRequest: function (lastRequest) {
        this.requestingId = this.requestingId.concat([lastRequest]);
        var timeoutId = setTimeout("playlistModel.abortRequest('"+lastRequest.url+"')", 35000);
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
        url = url.substring(0, url.indexOf("?")); 
        return this.requestingId.detect(function (element) {
            if (element.url.substring(0, element.url.indexOf("?")) == url) {
                return element;
            }
            else
            {
                return null;
            }
        });
    },

    getPath: function (id) {
            
        var path = this.requestingId.detect(function (element) {
            if (element.url.substring(0, element.url.indexOf("?")).indexOf(id) > 0 ) {
                return true;
            }
            else
            {
                return null;
            }
        });
        return path.url.substring(0, path.url.indexOf("?"));
    },
    
    existRequest: function (request) {
        return this.requestingId.any(function (element) {
            if (element.url.substring(0, element.url.indexOf("?")).indexOf(request.url) > -1) {
                return true;
            }
            else
            {
                return false;
            }
        });
    },

    nextRequestPath: function () {
        return this.getPath(this.lastIdRequestNext);
    
    },
    previousRequestPath: function () {
        return this.getPath(this.lastIdRequestPrev);
    }
    


});
Object.extend(PlaylistModel.prototype, Enumerable);


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
        return '#<Video:{id:'+this.id+', title: '+this.title+'}>';
    }
});


var PlaylistController = Class.create({

    initialize: function(view, model) {
        this.playlistModel = model;
        this.playlistView = view;
        this.currentVideo = null;
     

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
        this.startPlayingThread = null;
     
        
        this.config = false;

        this.bindingEvents();

        
        this.autoFill= new PeriodicalExecuter(this.fillPlaylist.bindAsEventListener(this), 10 );

    },
      

    bindingEvents: function (){

        $("next_video").observe("click", this.cueNextVideo.bindAsEventListener(this) );
        $("previous_video").observe("click", this.cuePreviousVideo.bindAsEventListener(this) );
        $("next_playlist").observe("click", this.nextPlaylist.bindAsEventListener(this) );
        $("previous_playlist").observe("click", this.previousPlaylist.bindAsEventListener(this) );
        if (userSignedIn) {
            $("like_current").observe("click", this.likeCurrentVideo.bindAsEventListener(this) );
            $("hate_current").observe("click", this.hateCurrentVideo.bindAsEventListener(this) );
            shortcut.add("Up", this.likeCurrentVideo.bindAsEventListener(this)   );
            shortcut.add("Down", this.hateCurrentVideo.bindAsEventListener(this)  );
        }
        Event.observe(document, "playlist:initial", this.startPlaying.bindAsEventListener(this));    
        Event.observe(document, "player:ready", this.startPlaying.bindAsEventListener(this));
        Event.observe(document, "player:recover", this.continuePlaying.bindAsEventListener(this));

        Event.observe(document, "player:complete", this.cueNextVideo.bindAsEventListener(this));
        Event.observe(document, "player:error", this.saveError.bindAsEventListener(this));
        Event.observe(document, "video:remove", this.removeFromChannel.bindAsEventListener(this));                
        Event.observe(document, "update:video:rating",this.changeVideoRating.bindAsEventListener(this)  );
        Event.observe(document, "playlist:next:false", this.requestFalse.bindAsEventListener(this));

        shortcut.add("Right", this.cueNextVideo.bindAsEventListener(this)   );
        shortcut.add("Left",  this.cuePreviousVideo.bindAsEventListener(this) );

        Event.observe(document, "change:rating", this.changeRating.bindAsEventListener(this));        
        this.startPlayingThread = new PeriodicalExecuter(this.startPlaying.bindAsEventListener(this), 2 );

    },

    fillPlaylist: function (event) {
        //console.log("fill Playlist");
        if (this.playlistView.size() < this.playlistView.maxSize && this.playlistModel.size() > 0 ) {
            if (this.playlistModel.requestingId.length == 0) {
                this.playlistModel.requestNextVideo();
            }
        }
      
    },

    startPlaying: function (event) {
        console.log("start playing");
        if (this.playlistModel.ids().length > 0 && player.ready && this.currentVideo == null) {
            this.cueVideo(this.playlistModel.first() );      
            if (this.startPlayingThread) {
                this.startPlayingThread.stop();
            }
            if (this.playlistModel.ids().length < 3) {
                this.fillPlaylist();
            }
        }
        else
        {
            if (player.getState() == "PLAYING" && this.startPlayingThread.timer) {
                this.startPlayingThread.stop();
            }
          
        }
    },

    requestFalse: function (event) {

        this.autoFill.stop();
    },

    saveError: function (event) {
        this.removeFromDatabase(this.currentVideo.id, true);
        this.cueNextVideo();  
    },

    continuePlaying: function (event) {
        this.cueVideo(this.currentVideo);
    },

    previousPlaylist: function (event) {
        var firstVisibleId = this.playlistView.firstVideoId();           
        var sizeVisible = this.playlistView.size();
        var prev = this.playlistModel.previous(firstVisibleId);

        if (prev != undefined) {
            this.playlistView.prependVideo(prev);
        }
    },
    nextPlaylist:function(event) {    
        var lastVisibleId = this.playlistView.lastVideoId();   
       
        var sizeVisible = this.playlistView.size();
        var next = this.playlistModel.next(lastVisibleId);

        if (next != undefined) {
            this.playlistView.appendVideo(next);
        }
    },  
    cuePreviousVideo: function (event) {
        var currentVideoId = this.currentVideo.id;
        var prev = this.playlistModel.previous(currentVideoId);
        if (prev != undefined) {
            this.cueVideo(prev);
            this.previousPlaylist();
        }
        
    },
    cueNextVideo: function (event) {
        var currentVideoId = this.currentVideo.id;
        var next = this.playlistModel.next(currentVideoId);
        if (next != undefined) {
            console.log ("next: " + next.id);
            this.cueVideo(next);
            this.nextPlaylist();
        }
    },

    changeVideoRating: function (event) {
        var video_id = event.memo.id;
        var action = event.memo.action;
        //var video = this.playlistModel.get(video_id);

        if (action == "hated" && channelId && owner == true) {
            this.playlistView.removeVideo(video_id, true);
            this.playlistModel.unset(video_id);
        }
    
    },

    cueAlternateVideoId: function(videoId) {
        //this.skipCurrentVideoWithoutCueNext();
        var video = this.playlistModel.get(videoId);
        this.cueVideo(video, false);
    //hideAudioRecorder();
    //if the video is an item of the playlist
    //if (!video.from == "search") {
    //  this.requestNextVideo();
    //}
    },

    cueExternal: function (id) {
        var videoAsJson = feedsController.videos().get(id);

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
            var video =  new Video(videoAsJson);
            this.cueVideo(video, false);
            
        //hideAudioRecorder();
        }
       
    },

    enqueueExternal: function (id) {
        var videoAsJson = feedsController.playlist().get(id);
        if(this.currentVideo.id != videoAsJson.id) {
            var results = this.playlistModel.append(videoAsJson);
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
        player.load(video);
       
        this.setVisualChanges(video);
        hashtrack.set("vid",video.id);

        this.currentVideo.setPageFields();
        //this.addVideoThumbs();
        replaceDataForTwitterButton(this.currentVideo.title, this.currentVideo.mynewtvUrl() );
        //retrieveAudioComments(video.id, userId);
        if (this.currentVideo.id == this.playlistModel.last().id ) {
            this.playlistModel.requestNextVideo();
        }
    },
    
    setVisualChanges: function (video) {
         this.currentVideo.setPageFields();
        Event.fire(document, "update:pointer", {
            id: video.id
        });

        if (userSignedIn) {
            $("current_rating_loading").setStyle({
                visibility : 'hidden'
            });

         
            if (video.rating == "liked") {      
                $("like_current").src="/images/player/btn_smile_on.png";
                $("hate_current").src="/images/player/btn_angry_light.png";
            }
            else if (video.rating == "hated") {
                $("like_current").src="/images/player/btn_smile_light.png";
                $("hate_current").src="/images/player/btn_angry_on.png";

            }
            else
            {
                $("like_current").src="/images/player/btn_smile_light.png";
                $("hate_current").src="/images/player/btn_angry_light.png";
            }

        }
        //console.log ("CueVideo from "+ this.currentVideo.from);

        if (this.currentVideo.from == 'facebook' && userSignedIn) {
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


    removeFromDatabase: function (video_id) {
        new Ajax.Request('/videos/' + this.video_id,
        {
            method:'delete'
        });

        this.playlistModel.unset(this.video_id);
        this.playlistView.removeVideo(video_id, false);

    },

    removeFromChannel: function (event) {
        var video_id = event.memo.id;

        new Ajax.Request('/channels/' + channelId + '/unset/'+video_id,
        {
            method:'post'
        });

        this.playlistModel.unset(this.video_id);
        this.playlistView.removeVideo(video_id, true);
    },

    

    /* Unused */
    requestPostVideo: function(videoId) {
        var path = '/watch/'+videoId;
        new Ajax.Request(path,
        {
            method: 'get',
            onSuccess: function(transport) {
                var array = transport.responseJSON;
                if (!array) {
                    // having weirdness w/ json response sometimes.
                    array = transport.responseText.evalJSON();
                }
                controller.playlist = new PlaylistModel(array);
                controller.cueNextVideo();
            },
            onFailure: function() {}
        });


    },

    querySearchVideos: function(query) {
        if (this.playlist != null) {
            this.playlistModel.clearSearchList();
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
                        visibility : 'hidden'
                    });
                    $('btn_search').removeClassName('searching');

                    throw $break;
                }
                else
                {

                    var array = transport.responseJSON;
                    controller.playlist.addToSearchlist(array);
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
                            visibility : 'hidden'
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
        controller.playlist = new PlaylistModel(array);
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

    likeCurrentVideo: function(event) {  
        if (this.currentVideo.rating == "liked") {
            this.destroyRate("liked", this.currentVideo);
            this.currentVideo.rating = null;
        }
        if (this.currentVideo.rating != "liked") {
            this.sendRate("liked", this.currentVideo);
            if (this.publish_facebook || this.publish_twitter) {
                setInfoMessage("You liked it! We'll publish it!");
            } else {
                setInfoMessage('You liked it!');
            }
            if (this.currentVideo.from == "facebook") {
                likePost();
                showFbLikeTab();
            }

        }
        
    },

    hateCurrentVideo: function(event) {

        if (this.currentVideo.rating == "hated") {
            this.destroyRate("hated", this.currentVideo);
            this.currentVideo.rating = null;
        }
        if (this.currentVideo.rating != "hated") {
            this.sendRate("hated", this.currentVideo);
            setInfoMessage("OK, no good...Here's another video!");
            this.cueNextVideo();
        }
    },    

    changeRating: function(event) {
        console.log("change:rating ");
        var button = event.element();//.up("div");

        if ( button.id.indexOf("rates") >= 0) {
            console.log("miss the icon");
            return;
        }
        var wrapper = button.up("div");
        var video_id = wrapper.id.substring (wrapper.id.indexOf("_") + 1, wrapper.id.length  );
        console.log("video_id = " + video_id);
        var video = this.playlistModel.get(video_id);
  
        if (video) {
            var currentState = video.rating;
            var newState = button.alt;
            console.log("currentState: " + currentState + ", newState: " + newState);

            //Hate!
            if (currentState == "hated" && newState == "hated") {
                playlistController.destroyRate("hated", video);            
            }
        
            //Unhate!
            if (currentState != "hated"  && newState == "hated") {
                playlistController.sendRate("hated", video);           
            }
        
            //Unlike it!
            if (currentState == "liked" && newState == "liked") {
                playlistController.destroyRate("liked", video);           
            }
        
            //Like it!
            if (currentState != "liked" && newState == "liked") {
                playlistController.sendRate("liked", video);            
            }
        
        
        }

    },

    

    sendRate: function (action, video) {
        var _this = this;
        var path = '/ratings/';
        var params = "rating[action]="+action +
        "&rating[video_id]="+ video.id +
        "&rating[video_score]="+ video.score +
        "&rating[source]="+ video.from;
        if (channelId) {
            params+="&rating[channel_id]="+channelId;
        }
        if (userId) {
            params+="&rating[user_channel_id]="+userId;       
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
                if (_this.currentVideo.id == video.id) {
                    $("current_rating_loading").setStyle({
                        visibility: 'visible'
                    });
                }
        
            },
            onSuccess: function(transport) {
                var response = transport.responseJSON || "no response text";
                video.rating = response.action;
                console.log("send response:" + response.action);
                Event.fire(document, "update:video:rating", {
                    id: video.id,
                    action: response.action
                });
                if (_this.currentVideo.id == video.id) {
                    Event.fire(document, "current:rating:change", {
                        action: response.action
                    });
                }
                return true;
            },
            onComplete: function() {
                $("rate_loader_"+video.id).hide();
                if (_this.currentVideo.id == video.id) {
                    $("current_rating_loading").setStyle({
                        visibility : 'hidden'
                    });
                }
            }
        } );
    },
    
    destroyRate: function(action, video) {
        var _this = this;
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
                if (_this.currentVideo.id == video.id) {
                    $("current_rating_loading").setStyle({
                        visibility: 'visible'
                    });
                }
            },
            onSuccess: function(transport) {
                var response = transport.responseJSON || "no response text";
                console.log("send response:" + response);
                if(response == true) {
                    Event.fire(document, "update:video:rating", {
                        id: video.id,
                        action: false
                    });
                }
                if (_this.currentVideo.id == video.id) {
                    Event.fire(document, "current:rating:change", {
                        action: response.action
                    });
                }
                

                return true;
            },
            onComplete: function() {
                $("rate_loader_"+video.id).hide();
                if (_this.currentVideo.id == video.id) {
                    $("current_rating_loading").setStyle({
                        visibility: 'hidden'
                    });
                }
            }
        } );        
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



var PlaylistView = Class.create({
    initialize: function(model) {
        this.className = 'PlaylistView';        
        this.playlistModel = model;
        this.maxSize = 6;


        this.previousLoading = false;
        this.nextLoading = false;

        this.bindingEvents();

    },

    
    bindingEvents: function () {
        Event.observe(document, "playlist:previous:loading", this.requestPreviousLoading.bindAsEventListener(this) );
        Event.observe(document, "playlist:previous:fail", this.requestPreviousFail.bindAsEventListener(this));
        Event.observe(document, "playlist:previous:false", this.requestFalse.bindAsEventListener(this) );
        Event.observe(document, "playlist:previous:success", this.requestPreviousSuccess.bindAsEventListener(this) );

        Event.observe(document, "playlist:next:loading", this.requestNextLoading.bindAsEventListener(this));
        Event.observe(document, "playlist:next:fail", this.requestNextFail.bindAsEventListener(this));
        Event.observe(document, "playlist:next:false", this.requestFalse.bindAsEventListener(this));
        Event.observe(document, "playlist:next:success",this.requestNextSuccess.bindAsEventListener(this)  );
        Event.observe(document, "update:video:rating",this.updateVisualRating.bindAsEventListener(this)  );
        Event.observe(document, "current:rating:change",this.updateCurrentRating.bindAsEventListener(this)  );
        Event.observe(document, "update:pointer",this.updateCurrentPointer.bindAsEventListener(this)  );

        Event.observe(document, "playlist:initial", this.showPlaylist.bindAsEventListener(this));    
        //Event.observe(document, "playlist:append", this.appendVideo.bindAsEventListener(this)  );
        //Event.observe(document, "playlist:append", this.prependVideo.bindAsEventListener(this)  );
        Event.observe(document, "view:resize", this.resize.bindAsEventListener(this));

    },

    showPlaylist: function (event) {
        $("video_list").update("");

        var addVideoThumbs = this.addVideoThumbs.bind(this);
        this.playlistModel.each (function(video) {
            addVideoThumbs(video);
        });

    },

    appendVideo: function (video) {
          
        if (this.size() < this.maxSize) {
            this.addVideoThumbs( video, null, 'bottom' );
        }
        else
        {
            var first = this.first();
            var addVideoThumbs = this.addVideoThumbs.bind(this);
            new Effect.Move(first, {
                x: -400,
                y: 0,
                mode: 'relative',
                transition: Effect.Transitions.linear,
                afterFinish: function () {
                   addVideoThumbs( video, null, 'bottom' );
                    if (first) {
                        first.remove();
                    }
                   
                }
            });
        }

    },

    prependVideo: function(video) {
            

        if (this.size() < this.maxSize) {
            this.addVideoThumbs( video, null, 'top' );
        }
        else
        {
            var last = this.last();
            var addVideoThumbs = this.addVideoThumbs.bind(this);
            new Effect.Move(last, {
                x: 400,
                y: 0,
                mode: 'relative',
                transition: Effect.Transitions.linear,
                afterFinish: function () {
                 addVideoThumbs( video, null, 'top' );
                    if (last) {
                        last.remove();
                    }
                   
                }
            });
        }
    },
  
    removeVideo: function (video_id, effect) {
        var thumb = $(""+video_id);
        if (thumb) {
            if (effect == true) {
                thumb.puff();
            }
            else
            {            
                thumb.remove();
            } 
            this.updateCurrentPointer();
        }
    },

    requestPreviousLoading: function (event) {
        var request_id = event.memo.id;
        if ( $(request_id) ) {
            return;
        }

        this.prevPlaylistOff("Searching for previous video...");
        if (this.size() < this.maxSize) {
            this.addVideoLoading('top', request_id );
        }
        else
        {
            var last = this.last();
            var addVideoLoading = this.addVideoLoading.bind(this);
            new Effect.Move(last, {
                x: 400,
                y: 0,
                mode: 'relative',
                transition: Effect.Transitions.linear,
                afterFinish: function () {
                    if (playlistModel.isRequestingPrevious() ) {
                        addVideoLoading('top', request_id );
                    }
                    if (last) {
                        last.remove();
                    }
                   
                }
            });
        }

    },

    requestNextLoading: function (event) {
        var request_id = event.memo.id;

        if ( $(request_id) ) {
            return;
        }

        this.nextPlaylistOff("Searching for next video...");
       

        if (this.size() < this.maxSize) {
            this.addVideoLoading('bottom', request_id );
        }
        else
        {
            var first = this.first();
            var addVideoLoading = this.addVideoLoading.bind(this);
            new Effect.Move(first, {
                x: -400,
                y: 0,
                mode: 'relative',
                transition: Effect.Transitions.linear,
                afterFinish: function () {
                    if (playlistModel.isRequestingNext() ) {
                        addVideoLoading('bottom', request_id );
                    }
                    if (first) {
                        first.remove();
                    }
                    
                }
            });
        }
        
          
    },
    requestPreviousFail: function (event) {
        var loadingElement = $(event.memo.id);
        if (loadingElement) {
            loadingElement.remove();
            this.updateCurrentPointer();
        }
        this.prevPlaylistOn();    
    },

    requestNextFail: function (event) {
        var loadingElement = $(event.memo.id);
        if (loadingElement) {
            loadingElement.remove();
            this.updateCurrentPointer();
        }
        this.nextPlaylistOn();    
    },

    requestFalse: function (event) {
        var loadingElement = $(event.memo.id);
        if (loadingElement) {
            loadingElement.remove();     
            this.updateCurrentPointer();       
        }
        setErrorMessage("No more videos");

    },

    requestPreviousSuccess: function (event) {
        var video_id = event.memo.id;
        var path = event.memo.path;
        var element = $(path);
        if (element) {
            this.addVideoThumbs(this.playlistModel.get(video_id), element, 'bottom' );
        }
        this.prevPlaylistOn("");
    },
   
    requestNextSuccess: function (event) {
        var video_id = event.memo.id;
        var path = event.memo.path;
        var element = $(path);

        if (element) {
            this.addVideoThumbs(this.playlistModel.get(video_id), element, 'top' );
        }
        this.nextPlaylistOn("");
    
    },


    addVideoLoading: function (_position, url) {
        var playlist = $('video_list');

        var li = new Element('li', {
            'id': url
        }).update("<div class='container'><img src='/images/icons/ajax-loader_111.gif' class='video_loader' /></div>");
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
        this.updateCurrentPointer();
        return li;
    },

    addVideoThumbs: function(video, _li, _position) {
        var _this = this;
        var sizeVisible = $$("#video_list li").size();
                
        var playlist = $('video_list');
        var img    = video.thumbnailImg();
        var titleP  = video.titleP();
        //var author = video.authorP();
        var content = "<div class='container'><div class='item_video'><div class='head'>"+titleP + "</div><div class='middle'><div class='thumb'>"+img+"<img onclick='"+video.linkToPlay()+"'  class='play_button'  src='/images/player/play_white.png'></div></div></div><div class='footer'>";
        if (userSignedIn) {
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
            if (channelId && owner == true) {
                content+="<img alt='del' height='20' src='/images/icons/trash_light.png' title='Remove from channel' width='20' id='remove_"+video.id+"'>";
            }
            content+="<img src='/images/icons/ajax-loader_111.gif' height='16' width='16' class='rating-loader' id='rate_loader_"+video.id+"' style='display: none'/></div>";
        }
        content+="</div></div>";
        
        if (_li == undefined ) {
            _li = new Element('li');
          
            var li = _li.update(content);     
        
        
            if (_position == "top") {
        
                if (sizeVisible < this.maxSize) {
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
                if (sizeVisible < this.maxSize) {
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

        li.addClassName("video_thumb video_draggable");
        li.writeAttribute("id", video.id);
        li.observe("mouseover",showPlayButton );
        li.observe("mouseout", hidePlayButton );  
        if (userSignedIn) {
            $("rates_"+video.id).observe("click", function(event) {
                event.element().fire("change:rating");
            } );
            if (owner == true) {
                setDraggableVideo(li.id);
                if (channelId) {
                    $("remove_"+video.id).observe("click", function(event) {
                        $("remove_"+video.id).fire("video:remove", {
                            id : video.id
                        }) ;
                    });
                }
            }
        }
        this.updateCurrentPointer();
    },

    updateCurrentPointer: function(event) {
        //console.log("updating arrow position");
        if (playlistController.currentVideo) {
            var id = playlistController.currentVideo.id;
            if ( $(""+id) ) {
                var left = $(""+id).getLayout().get("left");
                new Effect.Move('arrow_current_video', {
                    x: left + 60,
                    y: 0,
                    mode: 'absolute'
                });
            }
        }
    },
   
    resize: function () {
        //RESIZE UI
        //this.adjustRatingActionsButtons();
        this.adjustPlaylist();
        this.adjustHeader();
        this.visiblizeUI();
        

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
        $("playlist").show();
        if ( $("channel_list") ) {
            $("channel_list").show();
        }
    },

    firstVideoId: function () {
        var prev =  $$("#video_list li[id].video_thumb").first();
        return parseInt(prev.id);
    },

    first: function () {
        return $$("#video_list li[id]").first();
    
    },
    lastVideoId: function () {
        var last =  $$("#video_list li[id].video_thumb").last();
        return parseInt(last.id);
    },

    last: function () {
        return $$("#video_list li[id]").last();
    },

    size: function () {
        return  $$("#video_list li").size();
  
    },

    nextPlaylistOn: function (msg) {
        // $("next_playlist").observe("click", nextPlaylist);
        $("next_playlist").removeClassName("grey");
        if (msg != undefined && msg != "") {
            setInfoMessage(msg);
        }
    },

    nextPlaylistOff: function (msg) {
        //$("next_playlist").stopObserving("click");
        $("next_playlist").addClassName("grey");        
        if (msg != undefined && msg != "") {
            setInfoMessage(msg);
        }
    },


    prevPlaylistOn: function (msg) {
        // $("previous_playlist").observe("click", prevPlaylist);
        $("previous_playlist").removeClassName("grey");
        if (msg != undefined && msg != "") {
            setInfoMessage(msg);
        }
    },
      
    prevPlaylistOff: function (msg) {
        // $("previous_playlist").stopObserving("click");
        $("previous_playlist").addClassName("grey");
        if (msg != undefined && msg != "") {
            setInfoMessage(msg);
        }
    },

    updateCurrentRating: function(event) {
        var action = event.memo.action;
        if (action == "liked") {
            $("like_current").src="/images/player/btn_smile_on.png";
            $("hate_current").src="/images/player/btn_angry_light.png";
        }
        else if (action == "hated") {
            $("like_current").src="/images/player/btn_smile_light.png";
            $("hate_current").src="/images/player/btn_angry_on.png";

        }
        else
        {
            $("like_current").src="/images/player/btn_smile_light.png";
            $("hate_current").src="/images/player/btn_angry_light.png";
        }
    },

    updateVisualRating: function(event) {
        var video_id = event.memo.id;
        var video = this.playlistModel.get(video_id);
        var action = event.memo.action;

        var liked_img = $("rates_" + video_id).down("img[alt=liked]");
        var hated_img = $("rates_" + video_id).down("img[alt=hated]");
      
        if (action == "liked") {
            liked_img.src = liked_img.src.replace("_off","_on");
            liked_img.writeAttribute("state","on");
            hated_img.src = hated_img.src.replace("_on","_off");
            hated_img.writeAttribute("state", "off");
        }
        else if (action == "hated") {
            liked_img.src = liked_img.src.replace("_on","_off");
            liked_img.writeAttribute("state","off");
            hated_img.src = hated_img.src.replace("_off","_on");
            hated_img.writeAttribute("state","on");
          
        }
        else {
            liked_img.src = liked_img.src.replace("_on","_off");
            liked_img.writeAttribute("state","off");
            hated_img.src = hated_img.src.replace("_on","_off");
            hated_img.writeAttribute("state","off");
        }

       
    }

});


var FlaresController = Class.create({
    initialize: function() {
        this.flareThread = null;
        this.visibility = Boolean (Cookie.get("visibility") );        
        
        if (this.visibility == true) {
            this.startFlaring.delay(3);
        }
        $("visibility_select").value=this.visibility;
        $("visibility_select").observe("change", this.visibilityChange.bindAsEventListener(this) );
     
    },

    startFlaring: function() {
        console.log("start flaring");        
        this.flareThread = new PeriodicalExecuter (flaresController.updateSharing, 30);
    },

    stopFlaring: function() {
        console.log("stop flaring");
        if (this.flareThread) {
            this.flareThread.stop();
        }
    },

    visibilityChange: function (event) {
      this.visibility = Boolean(event.target.value);
        if (this.visibility == true) {
            this.startFlaring();

        }
        else
        {
            this.stopFlaring();
        }
        
        Cookie.set("visibility",   this.visibility );
    },

    updateSharing: function() {
        console.log("updating flare");
        if (  playlistController.currentVideo ) {
            new Ajax.Request("/snoops/"+signedUserId+"/flare",
            {
                method:'post',
                parameters: {
                    position : player.getPosition(),
                    video_id : playlistController.currentVideo.id
                }
            });
        }
    }
});
