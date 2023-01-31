//SPDX-License-Identifier: MIT

 

/**

* Forza ICO - Laravel CMS | Crypto ERC-20 Pre-Sale CMS (Crypto Fundraising)

 * This script was made by ZiLab Technologies

* If you need any help or custom development feel free to contact us

*

 * Website: www.zilab.co

* Telegram: @zilab_technologies

*/


pragma solidity 0.8.0;

 
//Cria a interface do padrão de token ERC-20
//Essa interface define as principais funções do token baseado no padrão ERC-20
interface IERC20 {

  //obter saldo
  function balanceOf(address who) external view returns (uint256);
  //realizar transferência de uma determinada quantidade de tokens para uma conta de destinto (address é o endereço a conta)
  function transfer(address to, uint256 value) external returns (bool);
  //conceder permissão para uma conta realizar uma transação  
  function allowance(address owner, address spender) external view returns (uint256);
  //realizar transferência de uma determinada quantidade de tokens de uma conta de origem (from) para uma conta de destinto (to)
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  //aprova que uma determinada conta negocie uma determinada quantidade de token  
  function approve(address spender, uint256 value) external returns (bool);

}
 
//Contrato que fornece suporte para o proprietário de um determinado contrato
//Por meio desse contrato é possível usar funções para saber quem é o propritário de um determinado contrato
//Alterar o proprietário de um determinado contrato
//Criar um modificador de acesso para que somente o proprietário do contrato possa executar uma determinada função
contract Ownable {

  //váriavel estado privada que armazena o endereço da conta do proprietário do contrato
  //Normalmente o proprietário é a pessoa que faz a implantação (deploy) do contrado em uma rede descentraliza,
  //Por exemplo, Binance Smart Chain  
  address private owner; 
  //Declaração de um evento, que vai ser emitido quando a função transferOwnership for executada
  event NewOwner(address oldOwner, address newOwner); 

  //Método construtor do contrato. Ele armazena o endereço da conta de uma pessoa na variável owner (proprietário do contrato)
  constructor() {
    owner = msg.sender;
  }
  //Criar um modificador de acesso para que somente o proprietário do contrato possa executar uma determinada função
  modifier onlyOwner() {
    require(isOwner(), "Ownable: caller is not the owner");
    _;
  }
  //Retorna o endereço do proprietário do contrato
  function contractOwner() external view returns (address) {
    return owner;
  }

  //Verifica se é o proprietário que executa uma determinada função
  function isOwner() public view returns (bool) {
    return msg.sender == owner;
  }

  //Transfere ou altera o proprietário do contrato
  function transferOwnership(address _newOwner) external onlyOwner {

    require(_newOwner != address(0), 'Ownable: address is not valid');
    owner = _newOwner;

    emit NewOwner(msg.sender, _newOwner);

  }

}
 
//Contrato que fornece suporte para pausar operações de um contrato
//E somnente pode ser usado pelo proprietário do contrato
//Possui funções que permitem pausar, tirar de pause, verificar se está pausado um contrato
contract Pausable is Ownable {

  //Variável privada que armazena o estado da conta de um usuário, se o valor da variável for true (significa que está pausado)
  bool private _paused;

  //Eventos que são emitidos quando determinadas funções pause() e unpause() são executadas
  event Paused(address account);
  event Unpaused(address account);

  //Modificadores de acesso
  modifier whenNotPaused() {
    require(!_paused, "Pausable: not paused");
    _;

  }
 
  modifier whenPaused() {
    require(_paused, "Pausable: paused");
    _;

  }
  //Retorna o valor da vaviável _paused, ou seja se um contrato está pausado
  function paused() external view returns (bool) {
    return _paused;
  }

  //Pausa um determinado contrato, somente o proprietário do contrato pode chamar essa funçao e usa modicação de
  //acesso whenNotPaused para restrigir que a função só pode pausar um contrato se ele não estiver pausado
  function pause() external onlyOwner whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);

  }
 //Tira da pausa um determinado contrato, somente o proprietário do contrato pode chamar essa funçao e usa modicação de
  //acesso whenPaused para restrigir que a função só pode pausar um contrato se ele estiver pausado
  function unpause() external onlyOwner whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }

}

//Contrato que Implementa a interface do padrão de token ERC-20
//Esse contrato implementa as funções de um token baseado no padrão ERC-20 
//Esse contrato também usa  os contrato Ownable e Pausable
contract RocketCMS is IERC20, Ownable, Pausable {

  //Declaração de variáveis de estado
  //Essas variáveis vão armazenar o nome, simbolo, número de casas decimais e o total supply de tokens cunhados (mint)
  string public name;
  string public symbol;
  uint8  public decimals;
  uint256 public totalSupply; //Guarda a quantidade de tokens existentes

  //Declaração de mapping usado para armazenar os saldos de tokens de determinadas contas de usuários 
  mapping (address => uint256) internal _balances;
  //Declaração de mapping para armazenar os endereços das contas que receberam a permissão um usuário para realizar transações com seus tokens
  mapping (address => mapping (address => uint256)) internal _allowed;

  //Declaração de eventos que serão emitidos quando as funções do contrato forem chamadas
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  //Método construtor do contrato. Esse método é chamado automaticamente quando feito o deploy, ou seja a implantação
  //Do contrato em alguma rede descentralizada, por exemplo, a Binance Smart Chain
  //Por meio desse método construtor será possível durante o deploy especificar os seguintes dados referentes ao token
  //Nome do token, Simbolo do token, número de casas decimais, o número de total supply, ou seja o número de tokens disponiveis para negócio  
  constructor (string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply ) {

    symbol = _symbol;
    name = _name;
    decimals = _decimals;
    totalSupply = _totalSupply;
    _balances[msg.sender] = _totalSupply;

  }

  //Função que realizar transferência de uma determinada quantidade de tokens para uma 
  //conta de destinto (_to, address é o endereço a conta de destino)
  //Move tokens da conta do chamador da função para a conta de destinto
  //Essa função só será executada se o contrato não estiver pausado 
  //Retorna um valor booleano que indica se a operação foi bem-sucedida.
  function transfer(address _to, uint256 _value) external override whenNotPaused returns (bool) {

    require(_to != address(0), 'ERC20: to address is not valid');
    require(_value <= _balances[msg.sender], 'ERC20: insufficient balance');

     _balances[msg.sender] = _balances[msg.sender] - _value;
    _balances[_to] = _balances[_to] + _value;

    emit Transfer(msg.sender, _to, _value); 
    
    return true;

  }

  //Função usada para obter saldo de token da conta de um determinado usuário
  //Retorna a quantidade de tokens de propriedade de um determinado usuário
  function balanceOf(address _owner) external override view returns (uint256 balance) {
    return _balances[_owner];
  }
  //Função que permite aprovar que uma determinada conta possa negociar (gastar) uma determinada quantidade de token 
  //Define uma quantidade de tokens permitada para gastar pelo chamador da função.
  //Essa função só será executada se o contrato não estiver pausado 
  //Retorna um valor booleano que indica se a operação foi bem-sucedida.  
  function approve(address _spender, uint256 _value) external override whenNotPaused returns (bool) {

    _allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);
    return true;

  }
 
  //Função que realizar transferência de uma determinada quantidade de tokens de uma conta de origem (from, , address é o endereço a conta de origem) para uma 
  //conta de destinto (_to, address é o endereço a conta de destino)
  //Essa função só será executada se o contrato não estiver pausado 
  //Retorna um valor booleano que indica se a operação foi bem-sucedida.

  function transferFrom(address _from, address _to, uint256 _value) external override whenNotPaused returns (bool) {

    require(_from != address(0), 'ERC20: from address is not valid');
    require(_to != address(0), 'ERC20: to address is not valid');
    require(_value <= _balances[_from], 'ERC20: insufficient balance');
    require(_value <= _allowed[_from][msg.sender], 'ERC20: transfer from value not allowed'); 

    _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _value;
    _balances[_from] = _balances[_from] - _value;
    _balances[_to] = _balances[_to] + _value; 

    emit Transfer(_from, _to, _value);
    return true;

  }
   //Função usada para conceder permissão para uma determinada conta realizar transações com os tokens de um usuário
   //Essa função recebe endereço da conta do proprietário (address _owner) dos tokens e o endereço da conta do usuário (address _spender)
   //que vai receber a permissição usar os tokens
   //Retorna o número restante de tokens que serão permitido gastar em nome do proprietário dos tokens
   //Essa função só será executada se o contrato não estiver pausado  
   function allowance(address _owner, address _spender) external override view whenNotPaused returns (uint256) {

    return _allowed[_owner][_spender];

  }

  //Função usada para aumentar a quantidade de tokens que uma determinada conta tem a permissão para realizar transações com os tokens de um usuário
  //Atomicamente aumenta a quantidade de tokens concedida ao gastador pelo chamador.
  //Essa função recebe endereço da conta que recebeu a permissão (address _spender) e quantidade de tokens (uint256 _addedValue)
  //Essa função só será executada se o contrato não estiver pausado   
  function increaseApproval(address _spender, uint256 _addedValue) external whenNotPaused returns (bool) {

    _allowed[msg.sender][_spender] = _allowed[msg.sender][_spender] + _addedValue; 

    emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

    return true;

  }

  //Função usada para reduzir a quantidade de tokens que uma determinada conta tem a permissão para realizar transações com os tokens de um usuário
  //Atomicamente diminui a permissão concedida pelo chamador
  //Essa função recebe endereço da conta que recebeu a permissão (address _spender) e quantidade de tokens (uint256 _addedValue)
  //Essa função só será executada se o contrato não estiver pausado  
  function decreaseApproval(address _spender, uint256 _subtractedValue) external whenNotPaused returns (bool) {

    uint256 oldValue = _allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {
      _allowed[msg.sender][_spender] = 0;
    } else {
      _allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }

    emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]); 

    return true;

  }

  //Função usada para cunhar, ou seja, executar a operação de mint de tokens.
  //Essa função recebe como argumentos de entrada o endereço da conta do usuário (address _to) que será o proprietário
  //dos tokens cunhados e a quantidade de tokens (uint256 _amount) que serão cunhados
  //Essa função só será executada se o contrato não estiver pausado e somente pode ser chamada pelo proprietário do
  //Contrato 
  function mintTo(address _to, uint256 _amount) external whenNotPaused onlyOwner returns (bool) {

    require(_to != address(0), 'ERC20: to address is not valid'); 

    _balances[_to] = _balances[_to] + _amount;
    totalSupply = totalSupply + _amount; 

    emit Transfer(address(0), _to, _amount);

    return true;
  }

  //Função usada para queimar uma determinada de tokens que foram cunhados.
  //Destrói tokens reduzindo o oferta total (Total Supply)
  //Essa função recebe como argumento a quantidade de tokens (uint256 _amount) que serão queimados
  //Essa função só será executada se o contrato não estiver pausado 

  function burn(uint256 _amount) external whenNotPaused returns (bool) {

    require(_balances[msg.sender] >= _amount, 'ERC20: insufficient balance'); 

    _balances[msg.sender] = _balances[msg.sender] - _amount;
    totalSupply = totalSupply - _amount;

    emit Transfer(msg.sender, address(0), _amount); 

    return true;

  }

  //Função é uma outra versão da função anterior usada para queimar uma determinada de tokens que foram cunhados.
  //Destroi uma quantidade (uint256 _amount) de tokens de uma conta (address _from) do usuário chamador da função
  //Essa função recebe como argumentos o endereço da conta de um usurário a quantidade de tokens (uint256 _amount) que serão queimados
  //Essa função só será executada se o contrato não estiver pausado 

  function burnFrom(address _from, uint256 _amount) external whenNotPaused returns (bool) {

    require(_from != address(0), 'ERC20: from address is not valid');
    require(_balances[_from] >= _amount, 'ERC20: insufficient balance');
    require(_amount <= _allowed[_from][msg.sender], 'ERC20: burn from value not allowed');

 
    _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _amount;
    _balances[_from] = _balances[_from] - _amount;
    totalSupply = totalSupply - _amount;

    emit Transfer(_from, address(0), _amount);

    return true;

  }
}
 