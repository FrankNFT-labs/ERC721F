const {MerkleTree} = require("merkletreejs")
const keccak256 = require("keccak256")

let presaleWhitelistAddresses = [
    "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"
];

const leaves = presaleWhitelistAddresses.map(addr => keccak256(addr))
const merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true})

const rootHash = merkleTree.getRoot().toString('hex')
console.log("WhiteList Merkle Tree\n", merkleTree.toString());
console.log("Roothash:\n", rootHash);


console.log("Proof:\n", createProof("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"));

function createProof(address) {
    const hashedAddress = keccak256(address);
    const proof = merkleTree.getHexProof(hashedAddress);
    return proof;
}