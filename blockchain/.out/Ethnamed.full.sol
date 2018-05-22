pragma solidity ^0.4.21;

contract Ethnamed {
    
    
    struct Name {
        string record;
        address owner;
        uint256 expires;
    }
    
    address issuer = 0xad69f2ffd7d7b3e82605f5fe80acc9152929f283;
    
    function changeIssuer(address _to) public {
        
        require(msg.sender == issuer); 
        
        issuer = _to;
        
    }
    
    function withdraw(address _to) public {

        require(msg.sender == issuer); 
        
        _to.transfer(address(this).balance);
    }
    
    mapping (string => Name) registry;
    
    function resolve(string _name) public view returns (string) {
        return registry[_name].record;
    }
    
    function version() public pure returns (string) {
        return "v0.001";
    }
    
    function transferOwnership(string _name, address _to) public {
        
        require(registry[_name].owner == msg.sender);
        
        registry[_name].owner = _to;
    }

    function removeExpiredName(string _name) public {
        
        require(registry[_name].expires < now);
        
        delete registry[_name];
    
    }
    
    function stringToUint(string s) pure internal returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    

    function setOrUpdateRecord(
        string length,
        string name,
        string record,
        string blockExpiry,
        address owner,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) public payable {
        
        require(stringToUint(blockExpiry) >= block.number);
        
        uint256 life = msg.value == 0.01  ether ?  48 weeks : 
                       msg.value == 0.008 ether ?  24 weeks :
                       msg.value == 0.006 ether ?  12 weeks :
                       msg.value == 0.002 ether ?  4  weeks :
                       0;
                       
        require(life > 0);
        
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n", length, name, "r=", record, "e=", blockExpiry), v, r, s) == issuer);
        require(registry[name].owner == msg.sender || registry[name].owner == 0x0);
        registry[name].record = record;
        registry[name].owner = owner;
        registry[name].expires = now + life;
    
    }
}