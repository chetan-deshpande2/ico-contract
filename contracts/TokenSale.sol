 //SPDX-License-Identifier: UNLICENSED

        pragma solidity ^0.8.0;

        import "@openzeppelin/contracts/access/Ownable.sol";
        import "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
        import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

        contract TokenSale is Ownable {
            using SafeERC20 for IERC20;

            bool public paused;

            address public admin;
        
            uint256 public price =  1500000;
            uint256 public totalTokenSold;
            uint256  private totalTokens = 30000000 ether;
            uint256 initialSaleQty = 30000000 ether  ;
            uint256 seedSaleQty = 50000000 ether ;
            uint256 RemaingSaleQty = 20000000 ether ;

            uint256 public initialSalePrice = 1500000;
            uint256 public seedSalePrice = 5400000;
            uint256 public finalSalePrince = 5650000;


            enum Stages {
                initialSale,
                seedSale,
                RemaingSale
            }

            Stages public stage = Stages.initialSale;
                
            AggregatorInterface public pricefeedETH =
                AggregatorInterface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
                
                
        

            IERC20 public token;

            mapping(address=>uint256) public usersId;
            mapping(uint256=>address) public usersAddresses;

            event TokenPurchasedEvent(
                address _purchasingAccount,
                uint256 indexed _tokensPurchase,
                uint256 indexed _amountPaid,
                uint256 indexed _currPrice
            );

            modifier isNotPaused() {
                require(paused == false, 'contract is paused');
                _;
            }

            constructor(address _admin , address _token)  {
                admin = _admin;
                token  = IERC20(_token);
            }

            /* GETTERS */

            // to get current token price in usd
            function getCurrentPriceInUSD()
                public
                view
                returns (uint256 _price)
            {
            
                    uint256 res = uint256(pricefeedETH.latestAnswer());
                    return res;
                
            }

            // get amount to be paid to buy _amount tokens 
            function amountNeedsToBePaid(uint256 _amount)
                public
                view
                returns (uint256)
            {
                uint256 res = getCurrentPriceInUSD();
                uint256 amount = (_amount * price / res);
                return amount;
            }
            
            function getCorrespondingTokens(uint256 _amount) public view returns(uint256){
                uint256 currPrice = getCurrentPriceInUSD() ;
                uint256 recievingTokens = (_amount * (currPrice / price));
                return recievingTokens;
            }

            /* SETTERS */

            // this will buy tokens equal to amount entered 
            function buyTokens(
                uint256 _amount
            ) public payable isNotPaused {
                uint256 recievingAmount;
                uint256 amountToPay;
            
                    amountToPay = amountNeedsToBePaid(_amount);
                    require(amountToPay<=msg.value,"insufficient amount");
                    if(msg.value>amountToPay){
                        payable(msg.sender).transfer(msg.value - amountToPay);
                    }
                        if (totalTokens == 0) {
                    setTokenStage();
                }
                
                    payable(admin).transfer(amountToPay);
            
                
                recievingAmount =_amount;
                totalTokenSold = totalTokenSold + recievingAmount;


                token.safeTransfer(
                    msg.sender,
                    recievingAmount
                );

            }

        function setTokenStage() internal {
                
                if (stage == Stages.initialSale && totalTokens == 0) {
                    stage = Stages.seedSale;
                    price=seedSalePrice;
                    totalTokens = seedSaleQty;
                } else if (stage == Stages.seedSale && totalTokens == 0) {
                    stage = Stages.RemaingSale;
                    price = finalSalePrince;
                    totalTokens = RemaingSaleQty;
                }
            }

            // sets new price for token in usd, _newPrice will be with 8 decimals
            function updatePrice(uint256 _newPrice) public onlyOwner isNotPaused {
                price = _newPrice;
            }

            // pause the contract if _pause 
            function setPaused(bool _pause) public onlyOwner {
                paused = _pause;
            }

        }