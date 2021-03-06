
var hashtrack = {
    'frequency': 100,
    'last_hash': window.location.hash,
    'onhashchange_callbacks': [],
    'onhashvarchange_callbacks': {},
    'first_call': [],
    'interval': null,

    'check_hash': function() {
        if (window.location.hash != hashtrack.last_hash)
        {
            hashtrack.last_hash = location.hash;
            hashtrack.update();
            hashtrack.call_onhashchange_callbacks();
        }
    },
    'init': function() {
        if (hashtrack.interval === null) {
            hashtrack.interval = setInterval(hashtrack.check_hash,
                             hashtrack.frequency);
        }
        if (typeof hashtrack.vars === 'undefined') {
            hashtrack.vars = {};
        }
        hashtrack.update();
        // Act on the hash as if it changed when the page loads, if its
        // "important"
        if (window.location.hash) {
            hashtrack.call_onhashchange_callbacks();
        }
    },
    'setFrequency': function (freq) {
        if (hashtrack.frequency != freq) {
            hashtrack.frequency = freq;
            if (hashtrack.interval) {
                clearInterval(hashtrack.interval);
                hashtrack.interval = setInterval(
                        hashtrack.check_hash, hashtrack.frequency);
            }
        }
    },
    'stop': function() {
        clearInterval(hashtrack.interval);
        hashtrack.interval = null;
    },
    'onhashchange': function(func, first_call) {
        hashtrack.onhashchange_callbacks.push(func);
        if (first_call) {
            func(location.hash.slice(1));
        }
    },
    'onhashvarchange': function(varname, func, first_call) {
        if (!(varname in hashtrack.onhashvarchange_callbacks)) {
            hashtrack.onhashvarchange_callbacks[varname] = [];
        }
        hashtrack.onhashvarchange_callbacks[varname].push(func);
        if (first_call) {
            func(hashtrack.get(varname));
        }
    },
    'call_onhashchange_callbacks': function() {
        var hash = window.location.hash.slice(1);
        for (var i = 0; i < hashtrack.onhashchange_callbacks.length; i++) {
            var f = hashtrack.onhashchange_callbacks[i];
            if (typeof f === 'function') {
                f(hash);
            }
        }
    },
    'call_onhashvarchange_callbacks': function(name, value) {
        if (name in hashtrack.onhashvarchange_callbacks) {
            for (var f in hashtrack.onhashvarchange_callbacks[name]) {
                if (typeof f === 'function') {
                    f(value);
                }
            }
        }
    },
    'update': function () {
        var vars = hashtrack.all();
        for (var k in vars) {
            if (hashtrack.vars[k] != vars[k]) {
                hashtrack.call_onhashvarchange_callbacks(k, vars[k]);
            }
        }
        hashtrack.vars = vars;
    },
    'all': function () {
        var hash = window.location.hash.slice(1, window.location.hash.length),
            vars = hash.split("&"),
            result_vars = {};
        for (var i = 0; i < vars.length; i++) {
            var pair = vars[i].split("=");
            result_vars[pair[0]] = pair[1];
        }
        return result_vars;
    },
    'get': function (key) {
        return hashtrack.vars[key];
    },

    'set': function (variable, value) {
        var hash = window.location.hash.slice(1, window.location.hash.length);
        
        var new_hash;
        if (hash.indexOf(variable + '=') == -1) {
            new_hash = hash + '&' + variable + '=' + value;
        } else {
            new_hash = hash.replace(variable + '=' + hashtrack.get(variable), variable + '=' + value);
        }
        window.location.hash = new_hash;
        hashtrack.vars[variable] = value;
    },

    'getPath': function () {
        return hashtrack.parseHash(location.hash).path;
    },

    'setPath': function (new_path) {
        pq = hashtrack.parseHash(location);
        if (pq.path == new_path) {
            return;
        } else {
            if (location.hash[1] == "/") {
            if (pq.qs.length > 0) {
                // #/foo/bar/?baz=10
                
            } else {
                // #/foo/bar
            }
            } else {
            // #?baz=foo
            }
        }
    },

    parseHash: function (string) {
        path__qs = _path_qs(string);
        return {'path': path__qs[0], 'qs': path__qs[1]}
    }
};

function _path_qs (string) {
    var path__qs = string.split("?");
    if (path__qs.length == 1) {
	if (string[0] == "/") {
	    return [path__qs, ""];
	} else {
	    return ["", path__qs];
	}
    } else {
	return [path__qs[0], path__qs[1]];
    }
}

function _path (string) {
    return _path_qs(string)[0];
}

function _qs (string) {
    return _path_qs(string)[1];
}

function addHashQuery(a) {
    var href = $(a).attr('href');
    var new_vars = hashtrack.all(_qs(href));
    $.each(new_vars, function (name, value) {
	    hashtrack.set(name, value);
	});
    return false;
}

if (typeof route != "undefined") {
    hashtrack.path = function (match, func) {
	route(match).bind(function(){
		path_and_qs = routes.args.path.split('?');
		qs = path_and_qs[1];
		path = [];
		$.each(path_and_qs[0].split('/'), function(){ if (this.length > 0) { path.push(this); } });
		func(path);
	    });
    };
}

