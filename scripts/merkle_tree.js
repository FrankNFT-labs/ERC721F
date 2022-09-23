const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

let presaleWhitelistAddresses = [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
];

const leaves = presaleWhitelistAddresses.map(addr => keccak256(addr))
const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true })

const rootHash = merkleTree.getRoot().toString('hex')
console.log("WhiteList Merkle Tree\n", merkleTree.toString());
console.log("Roothash:\n", rootHash);

console.log("Proof:\n", createProof("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"));

function createProof(address) {
    const hashedAddress = keccak256(address);
    const proof = merkleTree.getHexProof(hashedAddress);
    return proof;
}
