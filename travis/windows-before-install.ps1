choco install jq

cp C:\MinGW\bin\mingw32-make.exe C:\MinGW\bin\make.exe
$env:Path = $env:Path + ";C:\MinGW\bin;C:/Users/appveyor/AppData/Local/Yarn/config/global/node_modules/.bin"

Copy-Item -Path ../dripcap -Destination ../dripcap2 -Recurse

$env:NO_WPCAP = "true"
npm config set loglevel error
yarn global add gulp electron babel-cli node-gyp
yarn
