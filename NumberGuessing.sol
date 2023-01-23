// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

contract NumberGuessing {
    // Número gerado aleatoriamente
    uint256 secretNumber;
    // Endereço do jogador vencedor
    address payable winner;

    // Evento para indicar se o jogador acertou ou não
    event GuessResult(bool success, address player);

    constructor() {
        // Gera o número secreto aleatoriamente
        secretNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
    }

    uint256 totalPayments;

    function guess(uint256 _guess) public payable  {
        require(msg.value > 0, "Voce deve enviar ao menos 1 wei para poder palpitar.");
        totalPayments += msg.value;
        if (_guess == secretNumber) {
            winner = payable(msg.sender);
            emit GuessResult(true,winner);
            uint256 reward = totalPayments * 2;
            winner.transfer(reward);             

        } else {
            emit GuessResult(false,msg.sender);
             
        }
    }


    function getWinner() public view returns (address) {
        return winner;
    }
}