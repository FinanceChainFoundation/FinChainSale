var FCC="0x06d3c687d94a6b15076fbbaff1ca73e3a674b402"
var FCCP="0x1a41cdcb663cf672fbc6344b851736af2edbe703"
var addressFoundationDev="0x8c10273b46212b2fa87284779b6fecc787dc6938"
var addressFoundation="0x8c10273b46212b2fa87284779b6fecc787dc6938"

const dayCycle=3600*24*10


const startTimeEarlyBird =Date.parse("2017/8/22 20:00:00")/1000;

const startTime =Date.parse("2017/9/7 20:00:00")/1000;

const endTime =Date.parse("2017/9/27 20:00:00")/1000;

var d_startTimeEarlyBird=new Date(startTimeEarlyBird*1000)
var d_startTime=new Date(startTime*1000)
var d_endTime=new Date(endTime*1000)

console.log("早鸟开启时间:",d_startTimeEarlyBird.toLocaleString())
console.log("正式开启时间:",d_startTime.toLocaleString())
console.log("结束时间:",d_endTime.toLocaleString()



)

console.log('"%s","%s",%s,%s,%s,%s,"%s","%s",100',
    FCC, FCCP, startTimeEarlyBird, startTime, endTime, dayCycle, addressFoundationDev, addressFoundation)
