//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployBallot} from "../../script/DeployVoting.s.sol";
import {Script} from "forge-std/Script.sol";
import {Test, console} from "forge-std/Test.sol";
import {Ballot} from "../../src/Voting.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract BallotTest is Test {
    Ballot ballot;
    HelperConfig helperConfig;

    address proposalName1;
    address proposalName2;
    address proposalName3;

    address public PLAYER = makeAddr("Player");
    address public DELEGATE = makeAddr("delegate");

    function setUp() external {
        DeployBallot deployer = new DeployBallot();
        (ballot, helperConfig) = deployer.run();
        (proposalName1, proposalName2, proposalName3) = helperConfig
            .ActiveNetworkConfig();
    }

    // test raffle states starts as open
    function testRafflestateinititalizesOPEN() public view {
        assert(ballot.getRaffleState() == Ballot.VotingState.OPEN);
    }

    // test chairperson
    function testChairPersonisMsgsender() public view {
        assert(msg.sender == ballot.getChairPerson());
    }

    // test proposals entered into the voting
    function testProposalsEntered() public view {
        assert(
            ballot.getproposalsIndex(0) ==
                0x0000000000000000000000000000000000000001
        );
    }

    // test giving right to players
    function testonlyChairPersonGives() public {
        vm.prank(msg.sender);
        ballot.giveRightToVote(PLAYER);
        (uint256 weight, , , ) = ballot.voters(PLAYER);
        console.log(weight);
        assert(weight == 1);
    }

    // testonlychairpersoncan give right to vote

    function testOnlyChairPersonGivesRight() public {
        vm.prank(PLAYER);
        vm.expectRevert(Ballot.Ballot__NotChairPerson.selector);
        ballot.giveRightToVote(PLAYER);
    }

    //////////////
    ///voting ////
    //////////////

    modifier givenpermission() {
        vm.prank(msg.sender);
        ballot.giveRightToVote(PLAYER);
        vm.prank(msg.sender);
        ballot.giveRightToVote(DELEGATE);
        _;
    }

    // Testing function
    function testVotingFunction() public givenpermission {
        vm.prank(PLAYER);
        ballot.vote(0);
        (, uint256 count) = ballot.proposals(0);
        assert(count == 1);
        assert(ballot.getTotalVotes() == 1);
    }

    // testing you cannot vote twice
    function testBoolChangesFtoT() public givenpermission {
        vm.prank(PLAYER);
        ballot.vote(0);
        vm.expectRevert(Ballot.Ballot__Alreadyvoted.selector);
        vm.prank(PLAYER);
        ballot.vote(1);
    }

    // testing Fails if you dont have permission to vote
    function testNorighttovote() public {
        vm.prank(PLAYER);
        vm.expectRevert(Ballot.Ballot__NoRightToVote.selector);
        ballot.vote(0);
    }

    function testweightincrease() public givenpermission {
        (uint256 weight, , , ) = ballot.voters(PLAYER);
        assert(weight == 1);
    }

    /////////////
    //delegates//
    /////////////
    // testing delegation works
    function testDelegationWorks() public givenpermission {
        vm.prank(PLAYER);
        ballot.delegatevotes(DELEGATE);
        (uint256 weight, , , ) = ballot.voters(DELEGATE);
        (, , address delegate, ) = ballot.voters(PLAYER);
        assert(weight == 2);
        assert(delegate == DELEGATE);
    }

    // testing already voted

    function testAlreadyVotedRevert() public givenpermission {
        vm.prank(PLAYER);
        ballot.vote(0);
        vm.prank(PLAYER);
        vm.expectRevert(Ballot.Ballot__Alreadyvoted.selector);
        ballot.delegatevotes(DELEGATE);
    }

    // testing while loop inifinity error
    function testavoidinfinityError() public givenpermission {
        vm.prank(PLAYER);
        ballot.delegatevotes(DELEGATE);
        vm.prank(DELEGATE);
        vm.expectRevert(Ballot.Ballot__NotApplicable.selector);
        ballot.delegatevotes(PLAYER);
    }

    // Once choosen a delegate they have already voted
    function testbooleanwhenChooseDelegate() public givenpermission {
        vm.prank(PLAYER);
        ballot.delegatevotes(DELEGATE);
        (, bool voted, , ) = ballot.voters(PLAYER);
        assert(voted == true);
        assert(ballot.getTotalVotes() == 1);
    }

    ////////////////////
    ///picking winner///
    ////////////////////

    // winner functions returning answer correctly
    modifier give10permissions() {
        uint256 starting = 1;
        uint256 entrance = 9;
        for (uint256 i = starting; i < starting + entrance; i++) {
            address player = address(uint160(i));
            vm.prank(msg.sender);
            ballot.giveRightToVote(player);
            vm.prank(player);
            ballot.vote(0);
        }
        _;
    }

    function testPickwinner() public give10permissions {
        assert(ballot.PickWinner() == 0);
    }

    // testing state is open after pickwinner has finishing executing

    function testinvalidnumberofVoters() public givenpermission {
        vm.prank(PLAYER);
        vm.expectRevert(Ballot.Ballot__NotEnoughPeople.selector);
        ballot.PickWinner();
    }

    // testing that proposals count is zero after picking winner
}
