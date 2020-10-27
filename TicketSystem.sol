pragma solidity >=0.4.22 <0.7.0;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/ERC721.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/Ownable.sol";


contract TicketSystem is ERC721,Ownable {
    
    uint64 public ticketSupply;
    uint256 public initialTicketPrice;
    
    struct Ticket  {
        uint256 price;
        bool forSale;
        bool used;
    }
    
    Ticket[] tickets;
    
    constructor(string memory _eventName, 
                string memory _eventSymbol,
                uint64 _ticketSupply,
                uint256 _initialTicketPrice)
    public ERC721(_eventName, _eventSymbol)  {
        ticketSupply = _ticketSupply;
        initialTicketPrice = _initialTicketPrice;
    }
    
    
    // mengecek apakah ticket masih ada
    modifier isAvailable() {
        require((tickets.length < ticketSupply),"no more new tickets available");
        _;
    }   

   // mengecek apakah ticket sudah di gunakan
    modifier isNotUsed(uint256 _ticketId) {
        require(tickets[_ticketId].used != true,"ticket already used");
        _;
    }

   // mengecek apakah ticket sudah di gunakan
    modifier onlyTicketOwner(uint256 _ticketId) {
        require((ownerOf(_ticketId) == msg.sender),"no permission");
        _;
    }



    function buyTicket() external isAvailable payable returns(uint256) {   
        require((msg.value >= initialTicketPrice),"not enough money");
        
        if(msg.value > initialTicketPrice)
        {
            msg.sender.transfer(msg.value.sub(initialTicketPrice));
        }
        
         Ticket memory _ticket = Ticket({
            price: initialTicketPrice,
            forSale: bool(false),
            used: bool(false)
        });
        
        tickets.push(_ticket);
        uint256 _ticketId = tickets.length - 1;
        
        _mint(msg.sender, _ticketId);
        return _ticketId;
        
    }
    
  
    function setTicketForSale(uint256 _ticketId, uint256 _price)  external  isNotUsed(_ticketId) onlyTicketOwner(_ticketId) {
        tickets[_ticketId].forSale = true;
        tickets[_ticketId].price = _price;
       
    }

    function cancelTicketSale(uint256 _ticketId) external onlyTicketOwner(_ticketId){
        tickets[_ticketId].forSale = false;
    }
    
    function buyTicketFromAttendee(uint256 _ticketId) external  payable {
        require(tickets[_ticketId].forSale = true,"ticket not for sale");
        uint256 _priceToPay = tickets[_ticketId].price;
        address payable _seller = address(uint160(ownerOf(_ticketId)));
        require((msg.value >= _priceToPay),"not enough money");

        //Return overpaid amount to sender if necessary
        if(msg.value > _priceToPay)
        {
            msg.sender.transfer(msg.value.sub(_priceToPay));
        }

        _seller.transfer(_priceToPay);
       
        safeTransferFrom(_seller, msg.sender, _ticketId);
        tickets[_ticketId].forSale = false;    
    }
    
    function isTicketOwner(uint256 _ticketId)  external view  returns (bool) {
        require((ownerOf(_ticketId) == msg.sender),"no ownership of the given ticket");
      
        return true;
    }
    
    function checkTicketOwnership(uint256 _ticketId, address user)  public view  returns (bool) {
        if (ownerOf(_ticketId) == user){
            return true;
        }
        return false;
    }
    
    
    function getTicketInfo(uint256 _id)  public view returns (
        uint256 price, 
        bool forSale,
        bool used,
        address owmer
    ){
        price = uint256(tickets[_id].price);
        forSale = bool(tickets[_id].forSale);
        used = bool(tickets[_id].used);
        owmer  = address(uint160(ownerOf(_id)));
    }
    
    function getTicketStatus(uint256 _ticketId) public view returns (bool) {
        return tickets[_ticketId].used;
    }
    
    
    function setTicketToUsed(uint256 _ticketId) public  onlyOwner {
        tickets[_ticketId].used = true;
    }
    
    
    function withdrawBalance() public onlyOwner {
        uint256 _contractBalance = uint256(address(this).balance);
        msg.sender.transfer(_contractBalance);
       
    }
    
}