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
    /**
    The code provided looks fairly efficient, but there are a few small changes that could improve its readability and maintainability:

Use events to log repository, branch, and commit creations instead of relying solely on the function return values.
Use bytes instead of bytes32 for message, name, and description variables to allow for longer input values.
Use string instead of bytes32[] for parentHashes to make it easier to handle multiple parent commits.
     */
}

/***
initialize(): This function is often used to set up the initial state of the contract. It may assign values to state variables or perform other necessary setup operations. This function is usually called only once, when the contract is first deployed.

commit(): This function is likely used to record changes to the contract's state. It may take arguments to specify the details of the change, such as the amount of ether being transferred or the new value of a state variable. The function may also perform checks to ensure that the change is valid before committing it to the contract's state.

revert(): This function may be used to undo changes to the contract's state. It is usually called when an error or exception occurs during contract execution. The function may return any ether that was transferred during the failed transaction and restore the contract's state to its previous state.

getRevision(): This function may be used to retrieve information about a specific revision or version of the contract's code or state. It may take an argument to specify the revision number or other details, and it may return information such as the author of the revision, the date it was made, or the changes that were made.

merge(): This function may be used to combine two or more different revisions or branches of the contract's code or state. It may take arguments to specify the revisions or branches to be merged and may perform checks to ensure that the merge is valid. The function may also resolve conflicts that arise when two revisions or branches have made conflicting changes to the same code or state.
 */

 /***
 The last 5 functions of this VCS Solidity code are:

commit: This function allows a repository owner to make a new commit to a branch. 
It takes the repository name, branch name, commit hash, commit message, and an array of parent hashes as inputs. 
It first checks if the caller is the owner of the repository and if the branch exists. T
Then it checks if all the parent commits exist by iterating through the parent hashes array and checking if each commit exists. 
If all parent commits exist, a new commit is created by storing the commit hash, message, parent hashes, author address, and timestamp in the commits mapping. 
The latest commit of the branch is updated to the new commit hash, and the commit is marked as existing in the branch.

getLatestCommit: This function returns the hash of the latest commit in a branch. 
It takes the repository name and branch name as inputs and first checks if the branch exists. 
if the branch exists, it returns the latest commit hash stored in the latestCommit field of the Branch struct.

getCommit: This function returns the information of a commit. 
it takes the repository name, branch name, and commit hash as inputs and first checks if the commit exists in the specified branch. 
If the commit exists, it returns the hash, message, parent hashes, author address, and timestamp stored in the Commit struct.

getBranches: This function returns the list of all branches in a repository. 
It takes the repository name as an input and returns the array of branch names stored in the branches field of the Repository struct.

getBranchLatestCommit: This function returns the hash of the latest commit in a branch. 
It takes the repository name and variable number of branch names as inputs and first checks if each branch exists in the specified repository. If all branches exist, it returns an array of the latest commit hashes for each branch in the same order as the input branch names.
  */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "ipfs://QmX9y6xgQQhjN42HdGWpKyEZ4wZ4nRdA4YMBKjzvVG9WnS/contracts/IPFS.sol";

contract VCS is IPFS {

    event RepositoryCreated(bytes32 name, bytes description, address owner);
    event BranchCreated(bytes32 repositoryName, bytes32 branchName);
    event CommitCreated(bytes32 repositoryName, bytes32 branchName, bytes32 hash, bytes message, bytes32[] parentHashes, address author, uint256 timestamp);

    struct Repository {
        bytes32 name;
        bytes description;
        address owner;
        bytes32[] branches;
        mapping(bytes32 => bool) branchExists;
    }

    struct Branch {
        bytes32 name;
        bytes32 latestCommit;
        mapping(bytes32 => bool) commitExists;
    }

    struct Commit {
        bytes32 hash;
        bytes message;
        bytes[] parentHashes;
        address author;
        uint256 timestamp;
    }

    mapping(bytes32 => Repository) private repositories;
    mapping(bytes32 => mapping(bytes32 => Branch)) private branches;
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => Commit))) private commits;

    function createRepository(bytes32 name, bytes memory description) public {
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

        emit RepositoryCreated(name, description, msg.sender);
    }

    function createBranch(bytes32 repositoryName, bytes32 branchName) public {
        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can create a branch");
        require(!repositories[repositoryName].branchExists[branchName], "Branch already exists");

        repositories[repositoryName].branches.push(branchName);
        branches[repositoryName][branchName] = Branch({
            name: branchName,
            latestCommit: bytes32(0)
        });

        repositories[repositoryName].branchExists[branchName] = true;

        emit BranchCreated(repositoryName, branchName);
    }

    function commit(bytes32 repositoryName, bytes32 branchName, bytes32 hash, bytes memory message, bytes[] memory parentHashes) public {
        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can commit");
        require(repositories[repositoryName].branchExists[branchName], "Branch does not exist");

        for (uint i = 0; i < parentHashes.length; i++) {
            require(commits[repositoryName][branchName][parentHashes[i]].hash != bytes32(0), "Parent commit does not exist");
        }

        commits[repositoryName][branchName][hash] = Commit({
           
        timestamp: block.timestamp,
        message: message,
        parentHashes: parentHashes,
        hash: hash,
        committer: msg.sender
        });

        emit CommitEvent(repositoryName, branchName, hash, message, parentHashes, msg.sender);
    }

    // Function to get the commit details
    function getCommit(bytes32 repositoryName, bytes32 branchName, bytes32 hash) public view returns (uint256, bytes memory, bytes[] memory, address) {
        Commit storage commit = commits[repositoryName][branchName][hash];
        require(commit.hash != bytes32(0), "Commit does not exist");
        return (commit.timestamp, commit.message, commit.parentHashes, commit.committer);
    }

    // Function to create a branch
    function createBranch(bytes32 repositoryName, bytes32 branchName) public {
        require(repositories[repositoryName].owner == msg.sender, "Only repository owner can create branch");
        require(!repositories[repositoryName].branchExists[branchName], "Branch already exists");

        repositories[repositoryName].branchExists[branchName] = true;

        emit CreateBranchEvent(repositoryName, branchName, msg.sender);
    }
}