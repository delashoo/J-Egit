//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "ipfs-http-client/ src/index.sol";

contract VCS {
  IPFSHTTPClient ipfs = IPFSHTTPClient("localhost", 5001);

  function commit(string memory branchName, string memory message, string memory ipfsHash) public {
    Version[] memory versions = new Version[](1);
    versions[0] = Version(ipfsHash, block.timestamp, message);
    Commit memory commit = Commit(versions, block.timestamp, message);
    Branch storage branch = branches[branchName];
    branch.commits.push(commit);

    ipfs.add(bytes(ipfsHash));
  }

  function getVersionIPFSHash(string memory branchName, uint256 commitIndex, uint256 versionIndex) public view returns (string memory) {
    return branches[branchName].commits[commitIndex].versions[versionIndex].ipfsHash;
  }
}

//his code uses the IPFSHTTPClient library to add a file to IPFS when a new commit is created. I
//t also defines a getVersionIPFSHash function, which returns the IPFS hash of a specific version.

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract StoreIpfs {
    function storeFile(bytes memory fileContent) public returns (bytes32) {
        bytes memory encoded = abi.encodePacked(fileContent);
        (bool success, bytes memory result) = ipfs.add(encoded);
        require(success, "Failed to store file on IPFS");
        return bytes32(result);
    }
}
