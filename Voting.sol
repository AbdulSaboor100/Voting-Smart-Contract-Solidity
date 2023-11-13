// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

contract Voting {
    struct ballotStructure {
        uint256 id;
        string name;
    }

    address payable owner;
    uint256[] private idList;
    uint256 public ballotsCount;
    bool public isVotingStartedStatus;
    mapping(address => uint256) private voters;
    mapping(address => bool) private voted;
    mapping(uint256 => ballotStructure) public ballots;
    mapping(uint256 => uint256) public votes;

    constructor() {
        owner = payable(msg.sender);
    }

    function register(uint256 _id) external isVotingStarted onlyVoter {
        string memory numberString = Strings.toString(_id);
        uint256 length = bytes(numberString).length;

        require(length == 13, "Id number is invalid");
        require(voters[msg.sender] == uint256(0), "You can register only once");
        for (uint256 i = 0; i < idList.length; i++) {
            require(idList[i] != _id, "Voter already exits");
        }
        voters[msg.sender] = _id;
        idList.push(_id);
    }

    function setVotingStartedStatus() external onlyOwner {
        isVotingStartedStatus = true;
    }

    function createBallot(string memory _name) external onlyOwner {
        for (uint256 i = 0; i < ballotsCount; i++) {
            require(
                keccak256(abi.encodePacked(ballots[i + 1].name)) !=
                    keccak256(abi.encodePacked(_name)),
                "Looks like this ballot is already created"
            );
        }

        ballotsCount++;
        ballotStructure memory _ballot;
        _ballot = ballotStructure(ballotsCount, _name);
        ballots[ballotsCount] = _ballot;
    }

    function getBallots() external view returns (ballotStructure[] memory) {
        ballotStructure[] memory _allBallots = new ballotStructure[](
            ballotsCount
        );
        for (uint256 i = 0; i < ballotsCount; i++) {
            string memory _name = ballots[i + 1].name;
            uint256 _id = ballots[i + 1].id;
            ballotStructure memory _ballot = ballotStructure(_id, _name);
            _allBallots[i] = _ballot;
        }
        return _allBallots;
    }

    function castVote(uint256 _ballotId)
        external
        onlyVoter
        isVotingStarted
        isThisVoter
    {
        require(
            !voted[msg.sender],
            "Can't vote because voter has already voted"
        );
        require(
            ballots[_ballotId].id != uint256(0),
            "No ballot found to this ballot id"
        );
        votes[_ballotId] += 1;
        voted[msg.sender] = true;
    }

    modifier isVotingStarted() {
        require(isVotingStartedStatus, "Voting is not started yet");
        _;
    }

    modifier isThisVoter() {
        require(voters[msg.sender] != uint256(0), "Voter not registered");
        _;
    }

    modifier onlyVoter() {
        require(owner != msg.sender, "Owner can't call this function");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can call this function");
        _;
    }

    receive() external payable {
        revert();
    }
}
