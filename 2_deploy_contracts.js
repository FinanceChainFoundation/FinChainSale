const MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
const FCC = artifacts.require("FCC");
const FCCContribution = artifacts.require("FCCContribution");
const FCCPlaceHolder = artifacts.require("FCCPlaceHolder");

const addressFoundationDev = "0x22350f968843e9a52a61e6fdaf78dcc1d8216229";
const addressFoundation = "0x22350f968843e9a52a61e6fdaf78dcc1d8216229";
const controlerOwner='';

var init=true;
var now=Date.parse(new Date())/1000;
console.log(now)

const dayCycle=1800
const startTime =now+2000 ;
const startTimeEarlyBird =now+20 ;
const endTime =startTime+dayCycle*2;
var fccInstance;

module.exports = function(deployer) {
    deployer.deploy(MiniMeTokenFactory).then(function(mtf){

        return deployer.deploy(FCC,MiniMeTokenFactory.address).then(function(){
            FCC.deployed().then(function(fcc) {
                return deployer.deploy(FCCContribution).then(function () {
                    FCCContribution.deployed().then(function(fccc) {
                        return deployer.deploy(FCCPlaceHolder, controlerOwner, FCC.address, FCC.address).then(function () {

                            return fcc.changeController(FCCContribution.address).then(function () {
                                if(init){
                                    console.log('"%s","%s",%s,%s,%s,%s,"%s","%s",100',
                                        FCC.address, FCCPlaceHolder.address, startTimeEarlyBird, startTime, endTime, dayCycle, addressFoundationDev, addressFoundation)
                                    return fccc.initialize(FCC.address, FCCPlaceHolder.address, startTimeEarlyBird, startTime, endTime, dayCycle, addressFoundationDev, addressFoundation, 100).then(function () {

                                    })
                                }
                            })

                        })
                    })
                })
            })
        })
    });
};

/*module.exports = async function(deployer, network, accounts) {


    let miniMeTokenFactoryFuture = MiniMeTokenFactory.new();

    let miniMeTokenFactory = await miniMeTokenFactoryFuture;
    console.log("MiniMeTokenFactory: " + miniMeTokenFactory.address);

    // FCC send
    let fccFuture = FCC.new(miniMeTokenFactory.address);
    // FCCContribution send

    let fccContributionFuture = FCCContribution.new();

    //FCC wait
    let fcc = await fccFuture;
    console.log("FCC: " + fcc.address);
    //FCCContribution wait
    let fccContribution = await fccContributionFuture;
    console.log("FCCContribution: " + fccContribution.address);


    // FCC changeController send
    let fccChangeControllerFuture = fcc.changeController(fccContribution.address);
    // ContributionWallet send

    // FCC changeController wait
    await fccChangeControllerFuture;
    console.log("FCC changed controller!");


    // FCCPlaceHolder send
    let fccPlaceHolderFuture = FCCPlaceHolder.new(
        controlerOwner,
        fcc.address,
        fccContribution.address);

    // FCCPlaceHolder wait
    let fccPlaceHolder = await fccPlaceHolderFuture;
    console.log("FCCPlaceHolder: " + fccPlaceHolder.address);
    console.log();

    console.log(startTimeEarlyBird,fccPlaceHolder.address,addressFoundationDev)
    // FCCContribution initialize send/wait
    await fccContribution.initialize(
        fcc.address,
        fccPlaceHolder.address,
        startTimeEarlyBird,
        startTime,
        endTime,
        dayCycle,
        addressFoundationDev,
        addressFoundation,
        1);
    console.log("FCCContribution initialized!");

};*/
//fcc:0x692a70d2e424a56d2c6c27aa97d1a86395877b3a
//fcc contribution:0xbbf289d846208c16edc8474705c748aff07732db
//placeHolder:0x0dcd2f752394c41875e259e00bb44fd505297caf