pragma solidity >=0.4.22 <0.7.0;


contract Certificate {

    address public owner;
    string public name;
    uint256 public date;
    bool public locked;
    
    struct Participant {
        string name;
        string org;
    }
    
    mapping(address => Participant) public participants;
    
    constructor(string memory _name, uint256 _date) public {
        owner = msg.sender;
        name = _name;
        date = _date;
        locked = false;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function addParticipant(
        string memory _name,
        string memory _org)  public onlyOwner returns( address) {
        require(locked == false, "must not locked");
        
        address uniqueId = address(bytes20(keccak256(abi.encodePacked(msg.sender,now))));
        participants[uniqueId] = Participant(_name, _org);
        return uniqueId;
    }
    
    function getParticipant(address  _id) public view returns(string memory, string memory) {
        Participant memory temp = participants[_id];
        return (temp.name, temp.org);
    }
    
    function finish()  public onlyOwner {
        locked = true;
    }
    
    
}