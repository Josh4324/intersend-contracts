//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";

contract Receive is AxelarExecutable {
    IAxelarGasService immutable gasService;
    uint256 public payCounter;

    event Executed();

    struct Payment {
        uint256 amount;
        address sender;
        address receiver;
        uint256 id;
    }

    constructor(address _gateway, address _gasReceiver) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasReceiver);
    }

    mapping(uint256 => Payment) public idToPayment;

    event requestUserEvent(address user, uint256 amount, address creator, uint256 status, uint256 id);

    function sendToMany(
        string calldata destinationChain,
        string calldata destinationAddress,
        address[] calldata destinationAddresses,
        string calldata symbol,
        address sender,
        uint256 amount
    ) external payable {
        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gateway), amount);
        bytes memory payload = abi.encode(destinationAddresses, sender, amount);
        if (msg.value > 0) {
            gasService.payNativeGasForContractCallWithToken{value: msg.value}(
                address(this), destinationChain, destinationAddress, payload, symbol, amount, msg.sender
            );
        }
        gateway.callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        (address[] memory recipients, address sender, uint256 receivedAmount) =
            abi.decode(payload, (address[], address, uint256));
        address tokenAddress = gateway.tokenAddresses(tokenSymbol);

        uint256 sentAmount = amount / recipients.length;
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC20(tokenAddress).transfer(recipients[i], sentAmount);
        }

        idToPayment[payCounter] = Payment(receivedAmount, sender, recipients[0], payCounter);
        payCounter++;

        emit Executed();
    }

    function payHistory() public view returns (Payment[] memory) {
        uint256 totalItemCount = payCounter;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < payCounter; i++) {
            if (idToPayment[i].receiver == msg.sender) {
                itemCount += 1;
            }
        }

        Payment[] memory items = new Payment[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToPayment[i].receiver == msg.sender) {
                uint256 currentId = i;
                Payment storage currentItem = idToPayment[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
