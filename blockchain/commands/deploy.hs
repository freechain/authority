resolve ./solidity/Ethnamed.sol -> ./.out/Ethnamed.full.sol
compile ./.out/Ethnamed.full.sol -> Ethnamed
deploy Ethnamed
export addresses ./.out/addresses.json