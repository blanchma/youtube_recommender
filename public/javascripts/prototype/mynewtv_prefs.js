function togglePrefs(event) {
  var element, form, method, url, params;
  
  element = event.findElement();
  form    = element.form;
  url     = form.readAttribute('action');
  method  = form.readAttribute('method') || 'post';
  params  = form.serialize(true);
  
  new Ajax.Request(url, {
    method: method,
    parameters: params,
    asynchronous: true,
    evalScripts: true,

    onLoading:     function(request) { element.fire("ajax:loading", {request: request}); },
    onLoaded:      function(request) { element.fire("ajax:loaded", {request: request}); },
    onInteractive: function(request) { element.fire("ajax:interactive", {request: request}); },
    onComplete:    function(request) { element.fire("ajax:complete", {request: request}); },
    onSuccess:     function(request) { element.fire("ajax:success", {request: request}); },
    onFailure:     function(request) { element.fire("ajax:failure", {request: request}); }
  });
}

document.observe('dom:loaded', function(){
  if ($('user_publish_likes')) {    
    $('user_publish_likes').observe('click', togglePrefs);
    $("user_publish_likes").observe("ajax:success", function(event){ 
      Mynewtv.publish_facebook = event.findElement().checked;
      $('fb_single_post').toggle();
    });
  }
});