pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Ownable.sol";

contract NameRegistry is SafeMath, Ownable {
    
    uint256 price = 0.01 ether;
    
    mapping (address => uint256) registrants;
    
    function() public payable {
        registrants[msg.sender] = safeAdd(registrants[msg.sender], msg.value);
    }

    mapping (bytes32 => address) public registry;
    mapping (bytes32 => address) registryOwners;
    
    function transferName(bytes32 _name, address _to) public {
        
        require(registryOwners[_name] == msg.sender);
        registryOwners[_name] = _to;
    }
    
    function registerName(
        bytes32 _name,
        address _address
    ) public {
        
        require(registry[_name] == 0x0);
        require(registrants[msg.sender] >= price);
        registrants[msg.sender] = safeSub(registrants[msg.sender], price);
        registry[_name] = _address;
        registryOwners[_name] = msg.sender;
        
    }
}