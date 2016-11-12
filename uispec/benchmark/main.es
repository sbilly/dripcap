const {Session} = require('paperfilter');
const msgpack = require('msgpack-lite');

Session.create({
  namespace: '::<Ethernet>',
  dissectors: [
    {script: __dirname + '/../../packages/dissector/ethernet/lib/eth.es'}
  ]
}).then((sess) => {
  let time = null;
  let sum = 0;
  let count = 0;
  let maxSeq = 0;
  let packets = [];
  let repeat = 100;

  let start = () => {
    count++;
    maxSeq += packets.length * repeat;
    for (let i = 0; i < repeat; ++i) {
      for (let pkt of packets) {
        sess.analyze(pkt);
      }
    }
    time = process.hrtime();
  };

  sess.on('status', stat => {
    if (stat.packets > 0 && stat.packets >= maxSeq && stat.queue === 0) {
      let diff = process.hrtime(time);
      let sec = diff[0] + diff[1] / 1000000000.0;
      sum += sec;
      console.log(`#${count}: ${sec}sec`);
      if (count >= 10) {
        console.log(`mean: ${sum / count}sec ${packets.length * repeat}packets`);
        process.exit();
      } else {
        start();
      }
    }
  });

  let readStream = require('fs').createReadStream(__dirname +  '/../test/dump.msgpack');
  let decodeStream = msgpack.createDecodeStream();
  readStream.pipe(decodeStream).on("data", (data) => {
    if (data.length === 4) {
      packets.push({
        ts_sec: data[0],
        ts_nsec: data[1],
        length: data[2],
        payload: data[3]
      });
    }
  }).on('end', () => {
    start();
  });

}).catch(e => {
  console.warn(e);
});
