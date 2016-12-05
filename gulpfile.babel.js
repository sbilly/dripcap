import gulp from 'gulp';
import babel from 'gulp-babel';
import electron from 'gulp-atom-electron';
import symdest from 'gulp-symdest';
import replace from 'gulp-replace';
import zip from 'gulp-vinyl-zip';
import sequence from 'gulp-sequence';
import mocha from 'gulp-mocha';
import preservetime from 'gulp-preservetime';
import packager from 'electron-packager';
import fs from 'fs';
import path from 'path';
import glob from 'glob';
import rimraf from 'rimraf';
import {
  exec
} from 'child_process';
import npm from 'npm';
import pkg from './package.json';
import EventEmitter from 'events';

EventEmitter.defaultMaxListeners = 2048;

gulp.task('mocha', () => {
  gulp.src(['uispec/*.es', '**/uispec/*.es'], {
      read: false
    })
    .pipe(mocha({
      reporter: 'list',
      require: ['babel-register'],
      timeout: 30000,
      slow: 10000,
      retries: 3
    }))
    .once('error', (e) => {
      console.warn(e);
      process.exit(1);
    })
    .once('end', () => {
      process.exit();
    });
});

gulp.task('copy', () =>
  gulp.src([
    './package.json',
    './*.html',
    './packages/**/*',
    './dripcap-core/**/*',
    './paperfilter/**/*',
    '!./**/node_modules'
  ], {base: './'})
  .pipe(gulp.dest('./.build'))
  .pipe(preservetime())
);

gulp.task('npm', () => {
  let p = new Promise(res => npm.load({
    production: true,
    depth: 0
  }, res));

  p = p.then(() => {
    return new Promise(function(res) {
     npm.prefix = './.build/';
     return npm.commands.uninstall(['dripcap-core'], res);
   });
  });

  p = p.then(() => {
    return new Promise(function(res) {
      npm.prefix = './.build/';
      return npm.commands.install([], res);
    });
  });

  let dirs = [];
  glob.sync('./.build/packages/**/package.json').forEach(function(conf) {
    let cwd = path.dirname(conf);
    dirs.push(cwd);
  });

  for (let cwd of dirs) {
    p = p.then(() => {
      return new Promise(function(res) {
        npm.prefix = cwd;
        npm.commands.install([], res);
      });
    });
  }

  return p.then(() => {
    return new Promise(function(res) {
    rimraf('./.build/dripcap-core', () => {
      rimraf('./.build/paperfilter', res);
      });
    });
  });
});

gulp.task('linux', ['build'], cb =>
  gulp.src('./.build/**')
  .pipe(electron({
    version: pkg.devDependencies.electron,
    platform: 'linux',
    arch: 'x64',
    token: process.env['ELECTRON_GITHUB_TOKEN']
  }))
  .pipe(zip.dest('dripcap-linux-amd64.zip'))

);

gulp.task('debian-pkg', cb =>
  gulp.src('./debian/**', {
    base: './debian/'
  })
  .pipe(replace('{{DRIPCAP_VERSION}}', pkg.version, {
    skipBinary: true
  }))
  .pipe(gulp.dest('./.debian/'))

);

gulp.task('debian-bin', cb => {
  let options = {
    dir: __dirname + '/.out',
    version: pkg.devDependencies.electron,
    out: __dirname + '/.builtapp',
    asar: true,
    platform: 'linux'
  };
  return new Promise((res, rej) => {
    packager(options, (err, appPaths) => {
      if (err != null) {
        rej(err);
      } else {
        res(appPaths);
      }
    });
  });
});

gulp.task('debian', sequence(
  'debian-bin',
  'debian-pkg'
));

gulp.task('darwin', cb => {
  let options = {
    dir: __dirname + '/.out',
    version: pkg.devDependencies.electron,
    out: __dirname + '/.builtapp',
    platform: 'darwin',
    asar: {
      unpackDir: 'node_modules/dripcap-helper'
    },
    'osx-sign': true,
    icon: __dirname + '/images/dripcap.icns'
  };
  return new Promise((res, rej) => {
    packager(options, (err, appPaths) => {
      if (err != null) {
        rej(err);
      } else {
        res(appPaths);
      }
    });
  });
});

gulp.task('win32', cb => {
  let options = {
    dir: __dirname + '/.out',
    version: pkg.devDependencies.electron,
    out: __dirname + '/.builtapp',
    platform: 'win32',
    arch: 'x64',
    icon: __dirname + '/images/dripcap.ico',
    asar: true,
    win32metadata: {
      CompanyName: 'dripcap.org',
      FileDescription: '☕️ Caffeinated Packet Analyzer',
      ProductName: 'Dripcap'
    }
  };
  return new Promise((res, rej) => {
    packager(options, (err, appPaths) => {
      if (err != null) {
        rej(err);
      } else {
        res(appPaths);
      }
    });
  });
});

gulp.task('default', ['build'], cb => {
  let env = {
    DRIPCAP_ATTACH: '1'
  };
  exec('electron --enable-logging .build', {
    env: Object.assign(env, process.env)
  }, cb);
});

gulp.task('build', sequence(
  'copy',
  'npm'
));

gulp.task('out-pf', cb => {
  gulp.src([
    './.build/node_modules/paperfilter/*.js',
    './.build/node_modules/paperfilter/*.json',
    './.build/node_modules/paperfilter/*.es',
    './.build/node_modules/paperfilter/**/*.node'
  ], {base: '.build'})
  .pipe(gulp.dest('./.out'))
  .pipe(preservetime())
});

gulp.task('out-files', cb => {
  gulp.src([
    './.build/package.json',
    './.build/js/*',
    './.build/*.html',
    './.build/packages/**/*',
    './.build/node_modules/**/*',
    '!./.build/node_modules/paperfilter/**'
  ], {base: '.build'})
  .pipe(gulp.dest('./.out'))
  .pipe(preservetime())
});

gulp.task('out', sequence(
  ['out-files', 'out-pf']
));
