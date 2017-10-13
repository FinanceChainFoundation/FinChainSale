pragma solidity ^0.4.11;

import "./Owned.sol";
import "./MiniMeToken.sol";
import "./SafeMath.sol";
import "./ERC20Token.sol";

contract FCCContribution is Owned, TokenController {

    using SafeMath for uint256;
    MiniMeToken public FCC;

    uint256 public constant MIN_FUND = (0.001 ether);
    uint256 public constant CRAWDSALE_END_DAY = 2;

    uint256 public dayCycle = 10 days;
    uint256 public startTimeEarlyBird=0 ;
    uint256 public startTime=0 ;
    uint256 public endTime =0;
    uint256 public finalizedBlock=0;
    uint256 public finalizedTime=0;

    bool public isFinalize = false;
    bool public isPause = false;

    uint256 public totalContributedETH = 0;
    uint256 public totalTokenSaled=0;

    uint256 public MaxEth=5000 ether;

    uint256[] public ratio;

    address public fccController;
    address public destEthFoundationDev;
    address public destEthFoundation;
    uint256 public proportion;

    bool public paused;

    modifier initialized() {
        require(address(FCC) != 0x0);
        _;
    }

    modifier contributionOpen() {
        require(time() >= startTimeEarlyBird &&
              time() <= endTime &&
              finalizedBlock == 0 &&
              address(FCC) != 0x0);
        _;
    }

    modifier notPaused() {
        require(!paused);
        _;
    }

    function FCCContribution() {
        paused = false;
        ratio.push(19500);
        ratio.push(18500);
        ratio.push(17500);
    }


    /// @notice This method should be called by the owner before the contribution
    ///  period starts This initializes most of the parameters
    /// @param _fcc Address of the FCC token contract
    /// @param _fccController Token controller for the FCC that will be transferred after
    ///  the contribution finalizes.
    /// @param _startTime Time when the contribution period starts
    /// @param _startTimeEarlyBird Time when the contribution early bird period starts
    /// @param _endTime The time that the contribution period ends
    /// @param _destEthFoundationDev Dev destination address where the contribution ether is sent
    /// @param _destEthFoundation Destination address where the contribution ether is sent
    function initialize(
        address _fcc,
        address _fccController,
        uint256 _startTimeEarlyBird,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _dayCycle,
        address _destEthFoundationDev,
        address _destEthFoundation,
        uint256 _proportion    //30 mean 0.3
    ) public onlyOwner {
      // Initialize only once
        require(address(FCC) == 0x0);

        FCC = MiniMeToken(_fcc);
        require(FCC.totalSupply() == 0);
        require(FCC.controller() == address(this));
        require(FCC.decimals() == 18);  // Same amount of decimals as ETH

        startTime = _startTime;
        startTimeEarlyBird=_startTimeEarlyBird;
        endTime = _endTime;
        dayCycle=_dayCycle;

        assert(startTime < endTime);

        require(_fccController != 0x0);
        fccController = _fccController;

        require(_destEthFoundationDev != 0x0);
        destEthFoundationDev = _destEthFoundationDev;

        require(_destEthFoundation != 0x0);
        destEthFoundation = _destEthFoundation;

        proportion=_proportion;

    }

    function changeRatio(uint256 _day,uint256 _ratio)onlyOwner{
        ratio[_day]=_ratio;
    }

    /// @notice If anybody sends Ether directly to this contract, consider he is
    ///  getting FCCs.
    function () public payable notPaused {
        if(totalContributedETH>=MaxEth) throw;
        proxyPayment(msg.sender);
    }


    //////////
    // MiniMe Controller functions
    //////////

    /// @notice This method will generally be called by the FCC token contract to
    ///  acquire FCCs. Or directly from third parties that want to acquire FCCs in
    ///  behalf of a token holder.
    /// @param _account FCC holder where the FCCs will be minted.
    function proxyPayment(address _account) public payable initialized contributionOpen returns (bool) {
        require(_account != 0x0);
        uint256 day = today();

        require( msg.value >= MIN_FUND );

        uint256 toDev;
        if(proportion<100){
            toDev=msg.value*100/proportion;
            destEthFoundationDev.transfer(toDev);
            destEthFoundation.transfer(msg.value-toDev);
        }else
        {
            destEthFoundationDev.transfer(msg.value);
        }

        uint256 r=ratio[day];
        require(r>0);

        uint256 tokenSaling=r.mul(msg.value);
        assert(FCC.generateTokens(_account,tokenSaling));

        totalContributedETH += msg.value;
        totalTokenSaled+=tokenSaling;

        NewSale(day, msg.sender, msg.value);
    }
    function onTransfer(address, address, uint256) public returns (bool) {
        return false;
    }

    function onApprove(address, address, uint256) public returns (bool) {
        return false;
    }
    function issueTokenToAddress(address _account, uint256 _amount,uint256 _ethAmount) onlyOwner initialized {


        assert(FCC.generateTokens(_account, _amount));

        totalContributedETH +=_amount;

        NewIssue(_account, _amount, _ethAmount);

    }

    function finalize() public onlyOwner initialized {
        require(time() >= startTime);

        require(finalizedBlock == 0);

        finalizedTime = getBlockNumber();
        finalizedTime = now;

        FCC.changeController(fccController);
        Finalized();
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns (bool) {
        if (_addr == 0) return false;
        uint256 size;
        assembly {
          size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function time() constant returns (uint) {
        return block.timestamp;
    }

    //////////
    // Constant functions
    //////////

    /// @return Total tokens issued in weis.
    function tokensIssued() public constant returns (uint256) {
        return FCC.totalSupply();
    }

    //////////
    // Testing specific methods
    //////////

    /// @notice This function is overridden by the test Mocks.
    function getBlockNumber() internal constant returns (uint256) {
        return block.number;
    }

    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyOwner {
        if (FCC.controller() == address(this)) {
          FCC.claimTokens(_token);
        }
        if (_token == 0x0) {
          owner.transfer(this.balance);
          return;
        }

        ERC20Token token = ERC20Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    /// @notice Pauses the contribution if there is any issue
    function pauseContribution() onlyOwner {
        paused = true;
    }

    /// @notice Resumes the contribution
    function resumeContribution() onlyOwner {
        paused = false;
    }

    function today() constant returns (uint) {
        if(now<startTime)
            return 0;
        return now.sub( startTime) / dayCycle + 1;
    }
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event NewSale(uint256 _day ,address _account, uint256 _amount);
    event NewIssue(address indexed _th, uint256 _amount, uint256  _ethAmount);
    event Finalized();
}
