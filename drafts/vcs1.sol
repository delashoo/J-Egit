// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9; //Compiler version 0.8.9 and above but not including 0.9.0 & beyond.

import "ipfs://QmX9y6xgQQhjN42HdGWpKyEZ4wZ4nRdA4YMBKjzvVG9WnS/contracts/IPFS.sol";

contract Egit is IPFS {

    event RepositoryCreated(bytes32 name, bytes description, address owner);
    event BranchCreated(bytes32 repositoryName, bytes32 branchName);
    event CommitCreated(bytes32 repositoryName, bytes32 branchName, bytes32 hash, bytes message, bytes32[] parentHashes, address author, uint256 timestamp);


        /**
            Contract describes 3 structs;
            1. Repository, includes; repo name, repo description, owner's address, a dynamic array of branches && mapping to check if branch already exist in the repo.
            2. Branch, includes; name of branch, hash of latest commit made in the branch && mapping to check existence of a commit.
            3. Commit, includes; hash of the commit, commit msg, array of parenthashes, author's address && timestamp of commit
         */
    struct Repository {
        bytes name;
        bytes description;
        address owner;
        bytes32[] branches;
        mapping(bytes32 => bool) branchExists;
    }

    struct Branch {
        bytes name;
        bytes32 latestCommit;
        mapping(bytes32 => bool) commitExists;
    }

    struct Commit {
        bytes32 hash;
        bytes message;
        string parentHashes;
        address author;
        uint256 timestamp;
    }

        /*
            The contract defines three mappings;
            1. A mapping of bytes32 [repo_name] to the struct Repository, to map repo name to its infomation.
            2. A mapping of bytes32 [repo_name] to another mapping of bytes32 [branch_name] to the Branch struct. Maps repo to its branches && each branch mapped to its info[branch struct]
            3. A mapping of bytes32 [branch_name] to another mapping of bytes32 [commit_hash] to the Commit struct. Maps each branch to its commit && each commit to its info[commit struct]

        */
    mapping(bytes32 => Repository) private repositories; 
    mapping(bytes32 => mapping(bytes32 => Branch)) private branches; 
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => Commit))) private commits; 


        /**
                Function createRepository
            1. takes two inputs; name of repo && description
            2. Checks if repo exists by verifying non-existence of master branch from 2nd mapping
            3. Repo declaration; name, description && owner's address(msg.sender) && branch array initialized
            4. Master branch declaration; name & latest commit update
            5. Setting creation of master branch to true, used to check for existence of repo[step 2]
            6. Emit an event.
         */

    function createRepository(bytes name, bytes description) public {

        require(!repositories[name].branchExists["master"], "Repository already exists"); 

        repositories[name] = Repository({
            name: name,
            description: description,
            owner: msg.sender,
            branches: new bytes[] (1)
        });

        branches[name]["master"] = Branch({
            name: "master",
            latestCommit: bytes32(0)
        });

        repositories[name].branchExists["master"] = true; 

        emit RepositoryCreated(name, description, msg.sender);
    }

        /**
                function createBranch
            1. Takes in two arguments; Repo_Name && Branch_Name
            2. Checks if creator is owner of the repo
            3. Checks if Branch_Name exists in the Repo
            4. Branch declaration; name && latest commit
            5. Push newly created branch to Repo's array of branches
            6. Set boolean value for if branch is created to true
            7. Emit event

         */
    function createBranch(bytes32 repositoryName, bytes32 branchName) public {
        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can create a branch"); 
        require(!repositories[repositoryName].branchExists[branchName], "Branch already exists");

        branches[repositoryName][branchName] = Branch({
            name: branchName,
            latestCommit: bytes32(0)
        });
        repositories[repositoryName].branches.push(branchName); 
        
        repositories[repositoryName].branchExists[branchName] = true; 

        emit BranchCreated(repositoryName, branchName);

    }

        /**
                function Commit
            1. Takes in 5 arguments; Repo_Name, Branch_Name, Commit_hash, commit_msg && parentHashes
            2. Verifies msg.sender to be owner of the repo &
            3. CHecks if Branch_Name exists in repo struct
            4. Confirms if parent commits exist by iterating thro' parent hashes >> Verifies commit hash is not in parents hashes
            5. Commit declaration; hash, commit_msg, parenthashes, msg.sender address && timestamp of the commit
            6. Update the latestcommit in the Branch struct by passing the commit_hash
            7. Mark commit as existing in branch
            8. Emit commit event.
         */
    function Commit(bytes32 repositoryName, bytes32 branchName, bytes32 hash, bytes32 message, string parentHashes) public {

        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can commit");
        require(repositories[repositoryName].branchExists[branchName], "Branch does not exist");

        for (uint i = 0; i < parentHashes.length; i++) {
            require(commits[repositoryName][branchName][parentHashes[i]].hash != bytes32(0), "Parent commit does not exist");
        }

        commits[repositoryName][branchName][hash] = Commit({
            hash: hash,
            message: message,
            parentHashes: parentHashes,
            author: msg.sender,
            timestamp: block.timestamp
        });

        branches[repositoryName][branchName].latestCommit = hash;

        branches[repositoryName][branchName].commitExists[hash] = true;

        emit CommitEvent(repositoryName, branchName, hash, message, parentHashes, msg.sender);
    }

        /**
                function getLatestCommit
            1. Takes the repository name and branch name as inputs >> checks if branch exist
            2. If the branch exists, it returns the latest commit hash stored in the latestCommit field of the Branch struct.
         */
    function getLatestCommit(bytes32 repositoryName, bytes32 branchName) public view returns (bytes32) {
        
        require(repositories[repositoryName].branchExists[branchName], "Branch does not exist");
        return branches[repositoryName][branchName].latestCommit;
    }

        /* 
                function getCommit
            1. Takes 3 arguments; repo_Name, Branch_Name & commit_Hash to give info on the commit.
            2. Checks if commit exists in the specifiead branch
            3. If true, returns from the commit struct, all info of the specific commit.
        */
    function getCommit(bytes32 repositoryName, bytes32 branchName, bytes32 commitHash) public view returns (bytes32 hash, bytes32 message, bytes32[] memory parentHashes, address author, uint256 timestamp) {

        require(branches[repositoryName][branchName].commitExists[commitHash], "Commit does not exist");

        Commit memory commit = commits[repositoryName][branchName][commitHash];
        return (commit.hash, commit.message, commit.parentHashes, commit.author, commit.timestamp);
    }

        /**
                function getBranches
            1. This function returns the list of all branches in a repository. 
            2. It takes the repository name as an input and returns the array of branch names stored in the branches field of the Repository struct.
        */
    function getBranches(bytes32 repositoryName) public view returns (bytes32[] memory) {
        
        return repositories[repositoryName].branches;
    }

        /** 
                function getBranchLatestCommit
            1. This function returns the hash of the latest commit in a branch. 
            2. takes the repository name and variable number of branch names as inputs 
            3. checks if each branch exists in the specified repository. 
            4. If all branches exist, it returns an array of the latest commit hashes for each branch in the same order as the input branch names. 
        */
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