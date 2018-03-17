pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Ownable.sol";

contract NameRegistry is SafeMath {
    
    uint256 price = 0.05 ether;
    
    address owner = 0x5cd014502003d0c4802519028b1d34f317afd810;
    
    function() public payable {
    
        require(msg.value >= price);
        
        registrants[msg.sender] = safeAdd(registrants[msg.sender], msg.value);
    
    }
    
    function finalize(address _to) public {

        require(msg.sender == owner); 
        
        _to.transfer(this.balance);

    }
    
    mapping (bytes32 => address) public registry;
    mapping (bytes32 => address) registryOwners;
    mapping (address => uint256) public registrants;
    
    
    function transferOwnership(bytes32 _name, address _to) public {
        
        require(registryOwners[_name] == msg.sender);
        
        registryOwners[_name] = _to;
    }
    
    function changeAddress(bytes32 _name, address _to) public {
    
        require(registryOwners[_name] == msg.sender);
        
        registry[_name] = _to;
    }
    
    
    function registerName(
        bytes32 _name,
        address _address
    ) public {
        
        require(registry[_name] == 0x0);
        
        require(registrants[msg.sender] >= price);
        
        registrants[msg.sender] = safeSub(registrants[msg.sender], price);
        
        registry[_name] = _address;
        
        registryOwners[_name] = _address;
    }
}