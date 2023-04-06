// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "ipfs://QmX9y6xgQQhjN42HdGWpKyEZ4wZ4nRdA4YMBKjzvVG9WnS/contracts/IPFS.sol";

contract VCS is IPFS {

    //contract describes 3 structs
    //Repository: includes the name of the repository, description, owner's address, an array of branches, and a mapping to check if a branch exists.
    struct Repository {
        bytes32 name;
        bytes32 description;
        address owner;
        bytes32[] branches;
        mapping(bytes32 => bool) branchExists;
    }

    //Branch: It includes the name of the branch, the hash of the latest commit, and a mapping to check if a commit exists.
    struct Branch {
        bytes32 name;
        bytes32 latestCommit;
        mapping(bytes32 => bool) commitExists;
    }

    //Commit: It includes the hash of the commit, the commit message, an array of parent hashes, the author's address, and the timestamp.
    struct Commit {
        bytes32 hash;
        bytes32 message;
        bytes32[] parentHashes;
        address author;
        uint256 timestamp;
    }

    //The contract defines three mappings:
    
    mapping(bytes32 => Repository) private repositories;     //repositories: It maps the name of a repository to its information.
    mapping(bytes32 => mapping(bytes32 => Branch)) private branches; // branches: It maps the name of a repository to its branches and each branch name to its information.
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => Commit))) private commits; //Commit: It includes the hash of the commit, the commit message, an array of parent hashes, the author's address, and the timestamp.


    //createRepository: It takes the name and description of the repository as inputs and creates a new repository. 
    //It checks if the repository already exists by verifying if the "master" branch exists, and if not, it creates a new "master" branch and adds it to the repository's branches.
    function createRepository(bytes32 name, bytes32 description) public {
        require(!repositories[name].branchExists["master"], "Repository already exists");

        repositories[name] = Repository({
            name: name,
            description: description,
            owner: msg.sender,
            branches: new bytes32[](1)
        });

        branches[name]["master"] = Branch({
            name: "master",
            latestCommit: bytes32(0)
        });

        repositories[name].branchExists["master"] = true;
    }

    //createBranch: It takes the name of the repository and the name of the new branch as inputs and creates a new branch. 
    //It checks if the branch already exists, and if not, it adds the new branch to the repository's branches.
    function createBranch(bytes32 repositoryName, bytes32 branchName) public {
        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can create a branch");
        require(!repositories[repositoryName].branchExists[branchName], "Branch already exists");

        repositories[repositoryName].branches.push(branchName);
        branches[repositoryName][branchName] = Branch({
            name: branchName,
            latestCommit: bytes32(0)
        });

        repositories[repositoryName].branchExists[branchName] = true;
    }

    function commit(bytes32 repositoryName, bytes32 branchName, bytes32 hash, bytes32 message, bytes32[] memory parentHashes) public {
        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can commit");
        require(repositories[repositoryName].branchExists[branchName], "Branch does not exist");

        // Check if all parent commits exist
        for (uint i = 0; i < parentHashes.length; i++) {
            require(commits[repositoryName][branchName][parentHashes[i]].hash != bytes32(0), "Parent commit does not exist");
        }

        // Create the commit
        commits[repositoryName][branchName][hash] = Commit({
            hash: hash,
            message: message,
            parentHashes: parentHashes,
            author: msg.sender,
            timestamp: block.timestamp
        });

        // Update the latest commit in the branch
        branches[repositoryName][branchName].latestCommit = hash;

        // Mark commit as existing in branch
        branches[repositoryName][branchName].commitExists[hash] = true;
    }

    function getLatestCommit(bytes32 repositoryName, bytes32 branchName) public view returns (bytes32) {
        require(repositories[repositoryName].branchExists[branchName], "Branch does not exist");

        return branches[repositoryName][branchName].latestCommit;
    }

    function getCommit(bytes32 repositoryName, bytes32 branchName, bytes32 commitHash) public view returns (bytes32 hash, bytes32 message, bytes32[] memory parentHashes, address author, uint256 timestamp) {
        require(branches[repositoryName][branchName].commitExists[commitHash], "Commit does not exist");

        Commit memory commit = commits[repositoryName][branchName][commitHash];
        return (commit.hash, commit.message, commit.parentHashes, commit.author, commit.timestamp);
    }

    function getBranches(bytes32 repositoryName) public view returns (bytes32[] memory) {
        return repositories[repositoryName].branches;
    }

    function getBranchLatestCommit(bytes32 repositoryName, bytes32 branchName) public view returns (bytes32) {
        require(repositories[repositoryName].branchExists[branchName], "Branch does not exist");

        return branches[repositoryName][branchName].latestCommit;
    }

    function getRepository(bytes32 repositoryName) public view returns (bytes32 name, bytes32 description, address owner) {
        require(repositories[repositoryName].owner != address(0), "Repository does not exist");

        Repository memory repository = repositories[repositoryName];
        return (repository.name, repository.description, repository.owner);
    }
}