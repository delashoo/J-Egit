//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "ipfs-http-client/ src/index.sol";

contract VCS {
  IPFSHTTPClient ipfs = IPFSHTTPClient("localhost", 5001); //IPFSHTTPClient library, used to add file to IPFS when commit is created

  function commit(string memory branchName, string memory message, string memory ipfsHash) public {
    Version[] memory versions = new Version[](1);
    versions[0] = Version(ipfsHash, block.timestamp, message);
    Commit memory commit = Commit(versions, block.timestamp, message);
    Branch storage branch = branches[branchName];
    branch.commits.push(commit);

    ipfs.add(bytes(ipfsHash));
  }

  function getVersionIPFSHash(string memory branchName, uint256 commitIndex, uint256 versionIndex) public view returns (string memory) {
    return branches[branchName].commits[commitIndex].versions[versionIndex].ipfsHash; //returns IPFS hash of the specific version
  }
}

//his code uses the IPFSHTTPClient library to add a file to IPFS when a new commit is created. I
