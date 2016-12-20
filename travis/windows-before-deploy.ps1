if($env:APPVEYOR_REPO_TAG_NAME -ne $null){
  cd ../dripcap2
  $env:NO_WPCAP = ""
  yarn
  gulp build
  gulp out
  gulp win32
  mv .builtapp\Dripcap-win32-x64 .builtapp\Dripcap
  Compress-Archive -Path .builtapp\Dripcap -DestinationPath ..\dripcap\dripcap-windows-amd64.zip
}
