// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AITU_SE2331 is ERC20, Ownable {
    struct AIModel {
        string name;
        string description;
        uint256 price;
        address seller;
        string accessLink;
        bool isSold;
    }

    AIModel[] public aiModels;
    mapping(uint256 => address) public modelToBuyer;

    event ModelListed(
        uint256 indexed modelId,
        string name,
        uint256 price,
        address seller
    );

    event ModelPurchased(
        uint256 indexed modelId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );

    event TransactionDetails(
        address indexed sender,
        address indexed receiver,
        uint256 amount,
        uint256 blockTimestamp
    );

    constructor(address initialOwner) ERC20("AITU_SE2331", "UGT") Ownable(initialOwner) {
        _mint(initialOwner, 2000 * 10 ** decimals());
    }

    function listAIModel(
        string memory name,
        string memory description,
        uint256 price,
        string memory accessLink
    ) external returns (uint256) {
        AIModel memory newModel = AIModel({
            name: name,
            description: description,
            price: price,
            seller: msg.sender,
            accessLink: accessLink,
            isSold: false
        });
        
        aiModels.push(newModel);
        uint256 modelId = aiModels.length - 1;
        emit ModelListed(modelId, name, price, msg.sender);
        return modelId;
    }

    function getAIModel(uint256 modelId) external view returns (
        string memory name,
        string memory description,
        uint256 price,
        address seller,
        bool isSold
    ) {
        require(modelId < aiModels.length, "Model does not exist");
        AIModel storage model = aiModels[modelId];
        return (
            model.name,
            model.description,
            model.price,
            model.seller,
            model.isSold
        );
    }

    function purchaseAIModel(uint256 modelId) external {
        require(modelId < aiModels.length, "Model does not exist");
        AIModel storage model = aiModels[modelId];
        require(!model.isSold, "Model already sold");
        require(msg.sender != model.seller, "Cannot buy your own model");
        require(balanceOf(msg.sender) >= model.price, "Insufficient balance");

        _transfer(msg.sender, model.seller, model.price);
        model.isSold = true;
        modelToBuyer[modelId] = msg.sender;

        emit ModelPurchased(modelId, msg.sender, model.seller, model.price);
    }

    function getModelAccessLink(uint256 modelId) external view returns (string memory) {
        require(modelId < aiModels.length, "Model does not exist");
        require(
            msg.sender == aiModels[modelId].seller || 
            msg.sender == modelToBuyer[modelId],
            "Not authorized"
        );
        return aiModels[modelId].accessLink;
    }

    function getAllModels() external view returns (
        uint256[] memory ids,
        string[] memory names,
        uint256[] memory prices,
        bool[] memory soldStatus
    ) {
        uint256 length = aiModels.length;
        ids = new uint256[](length);
        names = new string[](length);
        prices = new uint256[](length);
        soldStatus = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ids[i] = i;
            names[i] = aiModels[i].name;
            prices[i] = aiModels[i].price;
            soldStatus[i] = aiModels[i].isSold;
        }
        return (ids, names, prices, soldStatus);
    }

    // Existing functions...
    function getTransactionDetails(
        address sender,
        address receiver,
        uint256 amount
    ) external {
        uint256 blockTimestamp = block.timestamp;
        emit TransactionDetails(sender, receiver, amount, blockTimestamp);
    }

    function getLatestTransactionTimestamp() external view returns (string memory) {
        uint256 timestamp = block.timestamp;
        return _timestampToString(timestamp);
    }

    function getTransactionSender() external view returns (address) {
        return msg.sender;
    }

    function getTransactionReceiver(address receiver) external pure returns (address) {
        return receiver;
    }

    function _timestampToString(uint256 timestamp) internal pure returns (string memory) {
        return string(abi.encodePacked("Timestamp: ", uint2str(timestamp)));
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = uint8(48 + (_i % 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}