// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract AICoin {
    // Nome e símbolo da moeda
    string public constant name = "AI Coin";
    string public constant symbol = "AI";

    // Total supply
    uint256 public totalSupply = 1_000_000 * 10**18;

    // Balanços de cada conta
    mapping (address => uint256) public balances;

    // Preço da moeda em wei por unidade
    uint256 public constant price = 1_000_000_000_000_000_000;

    // Tempo de início e fim da ICO
    uint256 public startTime;
    uint256 public endTime;

    // Evento para rastrear transferências
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Construtor para definir o período da ICO
    constructor(uint256 _startTime, uint256 _endTime) {
        startTime = _startTime;
        endTime = _endTime;
    }

    // Função para comprar moedas durante a ICO
    function buy() public payable {
        require(msg.value >= price, "O valor minimo para a compra eh de 1 AI");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "A ICO ainda nao comecou ou ja terminou");
        uint256 amount = msg.value / price;
        balances[msg.sender] += amount;
        totalSupply -= amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // Função para transferir moedas de uma conta para outra
    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "Saldo insuficiente");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
    }

    // Função para consultar o saldo de uma conta
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}
