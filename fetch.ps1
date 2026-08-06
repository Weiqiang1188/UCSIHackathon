$result = Invoke-WebRequest -Uri "http://verbal-sleep.picoctf.net:55826/" -TimeoutSec 15 -UseBasicParsing
$result.Content
