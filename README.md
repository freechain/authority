### Ethnamed Registry DAPP

This DAPP helps register names in Ethnamed Registry

Status: Implemented MVP

[Website](http://ethnamed.io) | [Collaborate](https://ide.c9.io/askucher/registrant-dapp) | [Discuss](https://t.me/ethnamed)

#### Use API

```
npm i ethnamed
```

```Javascript

//API is UNDER CONSTRUCTION

var web3 = require('web3'); // or window.web3 (connected to metamask)

var ethnamed = require('ethnamed')(web3);

var showResult = function(err, result) {
    console.log(err, result);
}

// TOP UP 0.1 ETH
//Put ETH on your account

ethnamed.topup(0.1, showResult);


// REGISTER NAME 
//please topup the account before because each address costs 0.05 ETH

ethnamed.registerName('nickname', '0x123...', showResult);


// CHANGE ADDRESS
//Assign another address to nickname

ethnamed.changeAddress('nickname', '0x123...', showResult);


// TRANSFER OWNERSHIP
//Assign another owner

ethnamed.transferOwnership('nickname', '0x123...', showResult);

```


#### Start DAPP Server

![Demo](http://res.cloudinary.com/nixar-work/image/upload/v1521280043/Screen_Shot_2018-03-17_at_11.46.42.png)


Install
```
npm run install
npm run compile
```

Start the Ganache blockchain
```
npm run blockchain
```

Deploy contracts 
```
npm run deploy
```

Start the DAPP
```
npm run start
```



-----------------

ethnamed.io