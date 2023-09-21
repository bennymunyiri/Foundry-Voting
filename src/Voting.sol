// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

/**
 * @title Voting contract
 * @author Benson Munyiri
 * @notice This contract is creating a voting setup
 * where there is ballot, proposals and voters
 * @dev Implements an automation protocal
 */

contract Ballot {
    // voter structure

    error Ballot__NotChairPerson();
    error Ballot__Alreadyvoted();
    error Ballot__NoRightToVote();
    error Ballot__NotenoughPeople();
    error Ballot__NotApplicable();
    error Ballot__NotEnoughPeople();

    enum VotingState {
        OPEN,
        CALCULATING
    }

    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }
    // Proposal structure
    struct Proposal {
        address name;
        uint256 count;
    }
    // mapping of an address to the voter characteristics
    mapping(address => Voter) public voters;
    // num of voters
    uint256 public total;
    address public chairperson;
    VotingState public s_votingstate;
    Proposal[] public proposals;

    // takes in an array of propasal names and push them in Proposal array
    constructor(address[3] memory propasalNames) {
        chairperson = msg.sender;

        voters[chairperson].weight = 1;

        uint length = propasalNames.length;

        for (uint i = 0; i < length; i++) {
            proposals.push(Proposal({name: propasalNames[i], count: 0}));
        }
    }

    function giveRightToVote(address myright) public {
        total = getTotalVotes();
        if (s_votingstate != VotingState.OPEN) {
            revert Ballot__NotApplicable();
        }
        // require only chairperson calls this function
        if (msg.sender != chairperson) {
            revert Ballot__NotChairPerson();
        }
        // checks if already voted the address asking for voting rights
        if (voters[myright].voted) {
            revert Ballot__Alreadyvoted();
        }
        // chairperson gives right the to vote
        require(voters[myright].weight == 0);
        voters[myright].weight = 1;
    }

    // vote function using voting index

    function vote(uint256 proposalIndex) public {
        if (s_votingstate != VotingState.OPEN) {
            revert Ballot__NotApplicable();
        }
        Voter storage voter = voters[msg.sender];

        // checking if already voted
        if (voter.voted) {
            revert Ballot__Alreadyvoted();
        }
        // checking the right to vote
        if (voter.weight == 0) {
            revert Ballot__NoRightToVote();
        }

        // voting now
        voter.voted = true;
        voter.vote = proposalIndex;
        // adding the vote count
        proposals[proposalIndex].count += 1;
        total += 1;
    }

    function delegatevotes(address to) external {
        if (s_votingstate != VotingState.OPEN) {
            revert Ballot__NotApplicable();
        }
        Voter storage sender = voters[msg.sender];

        if (sender.voted) {
            revert Ballot__Alreadyvoted();
        }
        if (sender.weight == 0) {
            revert Ballot__NoRightToVote();
        }
        if (sender.delegate == msg.sender) {
            revert Ballot__NotApplicable();
        }

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            if (to == msg.sender) {
                revert Ballot__NotApplicable();
            }
        }

        Voter storage delegate_ = voters[to];
        if (delegate_.weight < 1) {
            revert Ballot__NoRightToVote();
        }
        sender.voted = true;
        sender.delegate = to;
        total += 1;
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].count += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    function PickWinner() public returns (uint256 winnerproposal_) {
        total = getTotalVotes();
        if (total < 9) {
            revert Ballot__NotEnoughPeople();
        }
        s_votingstate = VotingState.CALCULATING;
        uint256 winner = 0;
        uint256 length = proposals.length;
        for (uint256 i = 0; i < length; i++) {
            if (proposals[i].count > winner) {
                winner = proposals[i].count;
                winnerproposal_ = i;
            }
        }

        // Reset state variables for a new round of voting
        for (uint256 i = 0; i < length; i++) {
            proposals[i].count = 0;
        }

        // Reset voters' voted status and delegate to address(0)
        address[] memory voterAddresses = new address[](total);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < length; i++) {
            address voterAddress = proposals[i].name;
            Voter storage voter = voters[voterAddress];
            voter.voted = false;
            voter.delegate = address(0);
            voterAddresses[currentIndex] = voterAddress;
            currentIndex++;
        }

        // Reset total votes and change state back to OPEN
        total = 0;
        s_votingstate = VotingState.OPEN;

        return winnerproposal_;
    }

    function getProposals() public view returns (address[] memory) {
        address[] memory proposalnames = new address[](proposals.length);
        for (uint i = 0; i < proposals.length; i++) {
            proposalnames[i] = proposals[i].name;
        }
        return proposalnames;
    }

    function getproposalsIndex(uint256 index) public view returns (address) {
        return proposals[index].name;
    }

    function getRaffleState() public view returns (VotingState) {
        return s_votingstate;
    }

    function getChairPerson() public view returns (address) {
        return chairperson;
    }

    function getTotalVotes() public view returns (uint256) {
        return total;
    }
}
