
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract ReleaseToken {
    
    struct Token {
        string name;
        uint age;
    }

    Token[] tokens;
    mapping(string => uint) tokensId;
    mapping (uint => uint) tokensToOwner;
    mapping(uint => uint) tokensForSale;

    function createToken(string name, uint age) public accept{
        require(!tokensId.exists(name), 103);

        tokens.push(Token(name, age));
        tokensId[name] = tokens.length - 1;
        tokensToOwner[tokens.length - 1] = msg.pubkey();
    }

    function putForSale(string tokenName, uint value) public accept checkOwner(tokenName){
        uint tokenId = tokensId[tokenName];
        tokensForSale[tokenId] = value;
    }

    function getAllTokens() public view returns (Token[]){
        return tokens;
    }

    //For Test
    function changeOwner(string tokenName,uint newOwner) public accept checkOwner(tokenName){
        uint tokenId = tokensId[tokenName];
        tokensToOwner[tokenId] = newOwner;
    }

    function getAllTokensForSale() public view returns (Token[], uint[]){
        Token[] tokenArr;
        uint[] valuesArr;
        optional(uint, uint) currentOpt = tokensForSale.min();
        while (currentOpt.hasValue()){
            (uint key, uint value) = currentOpt.get();
            valuesArr.push(value);
            tokenArr.push(tokens[key]);
            currentOpt = tokensForSale.next(key);
        }
        return (tokenArr, valuesArr);
    }

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwner(string tokenName) {
        uint tokenId = tokensId[tokenName];
        require(tokensToOwner[tokenId] == msg.pubkey(), 104);
        _;
    }

    modifier accept {
		tvm.accept();
		_;
	}
}
