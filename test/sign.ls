require! {
    \../verify-address.ls
}

err, signature <- verify-address \microsoft.com , \0xad69f2ffd7d7b3e82605f5fe80acc9152929f283  
console.log err, signature


signature = signature.substr(2); #remove 0x
r = '0x' + signature.slice(0, 64)
s = '0x' + signature.slice(64, 128)
v = '0x' + signature.slice(128, 130)
#v_decimal = web3.toDecimal(v)

console.log( { signature, r, s, v } )

