<?php
//this file is executed on the web server when the [SAVE] button is pressed in the audio recorder
//4 variables are passed to this file via POST:
//streamName: the file name of the new audio recording on the media server including the .flv extension
//streamDuration: duration of the recorded audio file in seconds but accurate to the millisecond (like this: 4.322)
//userId: the userId sent via flash vars or avc_settings.php
//recorderId: the recorderId sent via flash vars, to be used when there are many recorders on the same web page

$streamName=$_POST["streamName"];
$streamDuration=$_POST["streamDuration"];
$userId= $_POST["userId"];
$recorderId= $_POST["recorderId"];

echo "success";
?>