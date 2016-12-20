choco install jq

cp C:\MinGW\bin\mingw32-make.exe C:\MinGW\bin\make.exe
$env:Path = $env:Path + ";C:\MinGW\bin;C:/Users/appveyor/AppData/Local/Yarn/config/global/node_modules/.bin"

Copy-Item -Path ../dripcap -Destination ../dripcap2 -Recurse

$env:NO_WPCAP = "true"
npm config set loglevel error
yarn global add gulp electron babel-cli node-gyp

$dir = $pwd
cd "C:\Program Files\nodejs"
rm babel-doctor.cmd
rm babel-external-helpers.cmd
rm babel-node.cmd
rm babel.cmd
rm electron.cmd
rm gulp.cmd
rm node-gyp.cmd

Rename-Item babel-doctor.cmd.cmd babel-doctor.cmd
Rename-Item babel-external-helpers.cmd.cmd babel-external-helpers.cmd
Rename-Item babel-node.cmd.cmd babel-node.cmd
Rename-Item babel.cmd.cmd babel.cmd
Rename-Item electron.cmd.cmd electron.cmd
Rename-Item gulp.cmd.cmd gulp.cmd
Rename-Item node-gyp.cmd.cmd node-gyp.cmd

cd $dir

yarn
