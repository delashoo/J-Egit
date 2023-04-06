//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9; //compiler version


contract VCS {
  struct Commit {
    bytes32 contentHash;
    uint256 timestamp;
    address author;
    bytes32[] parentHashes;
  }

  struct Branch {
    bytes32 headHash;
    mapping(bytes32 => Commit) commits;
  }

  mapping(bytes32 => Branch) public branches;

  function createBranch(bytes32 branchName) public {
    branches[branchName] = Branch(bytes32(0), new mapping(bytes32 => Commit));
  }

  function commit(bytes32 branchName, bytes32 contentHash, bytes32[] parentHashes) public {
    Branch storage branch = branches[branchName];
    bytes32 commitHash = sha256(abi.encode(contentHash, block.timestamp, msg.sender, parentHashes));
    branch.commits[commitHash] = Commit(contentHash, block.timestamp, msg.sender, parentHashes);
    branch.headHash = commitHash;
  }

  function getCommit(bytes32 branchName, bytes32 commitHash) public view returns (bytes32, uint256, address, bytes32[] memory) {
    return (
      branches[branchName].commits[commitHash].contentHash,
      branches[branchName].commits[commitHash].timestamp,
      branches[branchName].commits[commitHash].author,
      branches[branchName].commits[commitHash].parentHashes
    );
  }

  function getHead(bytes32 branchName) public view returns (bytes32) {
    return branches[branchName].headHash;
  }
}

//SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.0;

struct Version {
  string ipfsHash;
  uint256 timestamp;
  string message;
}

struct Commit {
  Version[] versions;
  uint256 timestamp;
  string message;
}

struct Branch {
  Commit[] commits;
  string name;
}

contract VCS {
  mapping(string => Branch) branches;

  function createBranch(string memory name) public {
    branches[name] = Branch(new Commit[](0), name);
  }

  function commit(string memory branchName, string memory message, string memory ipfsHash) public {
    Version[] memory versions = new Version[](1);
    versions[0] = Version(ipfsHash, block.timestamp, message);
    Commit memory commit = Commit(versions, block.timestamp, message);
    Branch storage branch = branches[branchName];
    branch.commits.push(commit);
  }

  function getBranchCommits(string memory branchName) public view returns (Commit[] memory) {
    return branches[branchName].commits;
  }
}

/*
This code defines a Version struct, which contains an IPFS hash, timestamp,
 and commit message. The Commit struct contains an array of versions, a timestamp, 
 and a commit message. The Branch struct contains an array of commits and a branch name. 
 The VCS contract defines three functions: createBranch, commit, and getBranchCommits. 
 The createBranch function creates a new branch, the commit function creates a new commit on 
 a branch, and the getBranchCommits function returns all the commits on a branch.
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract commit {
    function commitWithFile(bytes32 branchName, bytes memory fileContent) public {
    bytes32 contentHash = storeFile(fileContent);
    bytes32[] memory parentHashes = new bytes32[](1);
    parentHashes[0] = branches[branchName].headHash;
    commit(branchName, contentHash, parentHashes);
    }

    function getFile(bytes32 contentHash) public view returns (bytes memory

} 