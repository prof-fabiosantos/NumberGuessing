//Autor: Prof. Fabio Santos (fssilva@uea.edu.br)
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

//importação da classe Ownable da biblioteca openzeppelin.
import "@openzeppelin/contracts/access/Ownable.sol";

//Estendendo a Ownable permite adicionar o modificador onlyOwner às nossas funções para que apenas o proprietário do contrato
//possa executá-las
contract TimeLockFunctions is Ownable {

  //O enum nos permite acessar a função de time-locked de forma mais legível
   enum Functions { ADI, SUB, MUL, DIV }   

   //_TIMELOCK constante define o quanto queremos que nossas funções esperem até que possam ser executadas
   uint256 private constant _TIMELOCK = 0 days;

   //um mapeamento de time-locked que nos ajuda a ver qual função está atualmente desbloqueada
   mapping(Functions => uint256) public timelock;

   //modificador que verifica se uma função está desbloqueada 
   //Verificando se o atual horário é maior do que quando ativamos o desbloqueio
   modifier notLocked(Functions _fn) {
     require(timelock[_fn] != 0 && timelock[_fn] <= block.timestamp, "Funcao esta bloqueada(time-locked)");
     _;
   }
  
  //função de desbloqueio que nos permite chamar nossas funções após a quantidade de dias definido na constante _TIMELOCK 
  function unlockFunction(Functions _fn) public onlyOwner {
    timelock[_fn] = block.timestamp + _TIMELOCK;
  }
  
  //função de bloqueio caso queiramos cancelar o tempo
  function lockFunction(Functions _fn) public onlyOwner {
    timelock[_fn] = 0;
  }
  
  //Finalmente, verificamos se as funções estão desbloqueadas e as bloqueamos de volta depois de usá-las

  function adicao(uint a, uint b) view public onlyOwner notLocked(Functions.ADI) returns (uint) {
      return a + b;          
  }
    
  function subtracao(uint a, uint b) view public  onlyOwner notLocked(Functions.SUB) returns (uint) {
      return a - b;       
  }
    
  function multiplicacao(uint a, uint b) view public  onlyOwner notLocked(Functions.MUL) returns (uint){
      return a * b;           
  }

  function divisao(uint a, uint b) view public  onlyOwner notLocked(Functions.DIV) returns (uint) {
      
      uint result;

      if (b != 0){
          result = a / b;
      }
      
      return result;           
  }

}