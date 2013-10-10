<%
''################ Flash Audio Recorder Configuration File ##########
''######################## MANDATORY FIELDS #########################
''//connectionstring:String
''//description: the rtmp connection string to the videorecorder application on your Flash Media Server server
''//values: 'rtmp://localhost/audiorecorder/_definst_', 'rtmp://myfmsserver.com/audiorecorder/_definst_', etc...
Dim connectionstring
connectionstring=""

''codec: Number
''desc: what codec to use
''values: 1 for Speex  0 for NellyMoser;	
''default: 1			
Dim codec
codec = 1

''soundRate: Number
''desc: the quality of the audio, the higer the value the better the audio quality (bot if you have a bad microphone this value won't really matter that much)
''values: 5,8,11,22 or 44 for when using the older Nelly Moser codec
''values: 0,1,2,3,4,5,6,7,8,9 or 10 for when using Speex 
Dim soundRate
soundRate = 10


''maxRecordingTime: Number
''affects: recorder
''desc: the maximum recording time in secdonds
''values: any number greater than 0;
Dim maxRecordingTime
maxRecordingTime=120

''userId: String
''affects: recorder
''desc: the id of the user logged into the website, not mandatory, this var is passed back to the save_video_to_db.php file via GET when the [SAVE] button in the recorder is pressed
''this variable can also be passed via flash vars like this: videorecorder.swf?userId=XXX, but the value in this file, if not empty, takes precedence
''values: strings
Dim userId
userId = ""

''##################### DO NOT EDIT BELOW ############################
Response.write("a=b")
Response.write("&connectionstring=")
Response.write(connectionstring)
Response.write("&soundRate=")
Response.write(soundRate)
Response.write("&codec=")
Response.write(codec)
Response.write("&maxRecordingTime=")
Response.write(maxRecordingTime)
Response.write("&userId=")
Response.write(userId)
Response.write("&incomingBuffer=") 
Response.write(incomingBuffer)
Response.write("&streamName=")
Response.write(streamName)
Response.write("&autoPlay=")
Response.write(autoPlay)
%>