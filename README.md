### Ethnamed Registry DAPP

This DAPP helps register names in Ethnamed Registry

Status: Implemented MVP

[Website](http://ethnamed.io) | [Collaborate](https://ide.c9.io/askucher/registrant-dapp) | [Discuss](https://t.me/ethnamed)

#### Use API

```
npm i ethnamed
```

```Javascript

var ethnamed = require('ethnamed');

// TOP UP 0.1 ETH
//But ETH on your account

ethnamed.topup(0.1, function(err, result) {
    console.log(err, result);
});


// REGISTER NAME 
//please topup the account before because each address costs 0.05 ETH

ethnamed.registerName('nickname', '0x123...', function(err, result) {
    console.log(err, result);
});


// CHANGE ADDRESS
//Assign another address to nickname

ethnamed.changeAddress('nickname', '0x123...', function(err, result) {
    console.log(err, result);
});

// TRANSFER OWNERSHIP
//Assign another owner

ethnamed.transferOwnership('nickname', '0x123...', function(err, result) {
    console.log(err, result);
});

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