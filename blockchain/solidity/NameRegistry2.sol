pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Ownable.sol";

contract NameRegistry is SafeMath, Ownable {
    
    uint256 price = 0.01 ether;
    
    uint256 available = 1000 ether;
    
    mapping (address => uint256) registrants;
    
    mapping (address => address) sales;
    
    function() public payable {
    
        uint256 rest = safeSub(available, msg.value);
    
        require(rest  >= 0 || registrants[msg.sender] > 0);
        
        if (rest >= 0) {
            
            available = rest;
        }
        
        registrants[msg.sender] = safeAdd(registrants[msg.sender], msg.value);
    }
    
    function assignSales(address _sales) public {
        sales[msg.sender] = _sales;  
    }

    mapping (bytes32 => address) public registry;
    mapping (bytes32 => address) registryOwners;
    
    
    function transferName(bytes32 _name, address _to) public {
        
        require(registryOwners[_name] == msg.sender);
        
        registryOwners[_name] = _to;
    }
    
    function changeAddress(bytes32 _name, address _to) public {
    
        require(registryOwners[_name] == msg.sender);
        
        registry[_name] = _to;
    }
    
    
    function registerName(
        address _registrant,
        bytes32 _name,
        address _address
    ) public {

        require(sales[_registrant] == msg.sender);
        
        require(registry[_name] == 0x0);
        
        require(registrants[_registrant] >= price);
        
        registrants[_registrant] = safeSub(registrants[_registrant], price);
        
        registry[_name] = _address;
        
        registryOwners[_name] = _address;
        
    }
}