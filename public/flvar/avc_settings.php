<?php
################ Flash Audio Recorder Configuration File ##########
######################## MANDATORY FIELDS #########################
//connectionstring:String
//description: the rtmp connection string to the videorecorder application on your Flash Media Server server
//values: 'rtmp://localhost/audiorecorder/_definst_', 'rtmp://myfmsserver.com/audiorecorder/_definst_', etc...
$config['connectionstring']='http://localhost:1935';


//codec: Number
//desc: what codec to use
//values: 1 for Speex  0 for NellyMoser;	
//default: 1		
$config['codec']= 1;

//soundRate: Number
//desc: the quality of the audio, the higer the value the better the audio quality (bot if you have a bad microphone this value won't really matter that much)
//values: 5,8,11,22 or 44 for when using the older Nelly Moser codec
//values: 0,1,2,3,4,5,6,7,8,9 or 10 for when using Speex
//default : 10
$config['soundRate']=10;

//maxRecordingTime: Number
//affects: recorder
//desc: the maximum recording time in secdonds
//values: any number greater than 0;
$config['maxRecordingTime']=120;

//userId: String
//affects: recorder
//desc: the id of the user logged into the website, not mandatory, this var is passed back to the save_video_to_db.php file via GET when the [SAVE] button in the recorder is pressed
//this variable can also be passed via flash vars like this: videorecorder.swf?userId=XXX, but the value in this file, if not empty, takes precedence
//values: strings
$config['userId']='';

##################### DO NOT EDIT BELOW ############################
echo "donot=removethis";
foreach ($config as $key => $value){
	echo '&'.$key.'='.$value;
}
?>
