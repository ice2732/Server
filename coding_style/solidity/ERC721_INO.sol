// SPDX-License-Identifier: MIT
// Initial NFT Offering
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ERC721_INO is Pausable, AccessControl {
    ERC721 public ERC721_BOX;
    address public Operator; // 판매 박스 보관 주소

    // 구매한 지갑, token Id
    event Sale(address indexed from, uint8 indexed order, uint256 indexed tokenId);

    /////////////////////////////////////////////////////
    // box sale 일정
    struct saleOrder {
        uint256 startBoxId; // 시작 박스 인덱스
        uint256 endBoxId; // 마지막 박스 인덱스
        uint256 startTime; // 시작 시간
        uint256 endTime; // 종료 시간
        uint256 price; // 박스 가격(wei)
        uint256 limitPerUser; // 이번 회차에 유저당 구입 가능 박스 제한 수량
        bool whiteList; // 화이트 리스트 적용 여부
    }
    
    // 회차 => Box Sale 정보
    mapping(uint8 => saleOrder) public saleOrders;
    
    // 회차별 화이트리스트
    mapping(uint8 => mapping(address => bool)) public whiteLists;

    // 회차별 현재 token Id
    mapping(uint8 => uint256) public currentTokenId;
    
    // 회차-유저별 구입한 박스 수량
    mapping(uint8 => mapping(address => uint256)) public boxPerUser;

    constructor(address _ERC721_BOX, address _Operator) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        ERC721_BOX = ERC721(payable(_ERC721_BOX));
        Operator = _Operator;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // sale 회차별 설정
    function setSaleOrder(
        uint8 _order,
        uint256 _startBoxId,
        uint256 _endBoxId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price,
        uint256 _limitPerUser,
        bool _whiteList
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(0 == saleOrders[_order].startTime, "setSaleOrder: this order already set");
        require(_order > 0, "setSaleOrder: order must be greater than zero");
        require(_endTime > block.timestamp, "setSaleOrder: _endTime is under now");
        require(_endTime > _startTime, "setSaleOrder: _endTime is under _startTime");

        saleOrder storage newOrder = saleOrders[_order];
        newOrder.startBoxId = _startBoxId;
        newOrder.endBoxId = _endBoxId;
        newOrder.startTime = _startTime;
        newOrder.endTime = _endTime;
        newOrder.price = _price;
        newOrder.limitPerUser = _limitPerUser;
        newOrder.whiteList = _whiteList;

        currentTokenId[_order] = _startBoxId;
    }

    // 회차별 whitelist 추가
    function addWhiteList(uint8 _order, address[] memory _addresses) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_order > 0, "addWhiteList: order must be greater than zero");
        require(0 < _addresses.length, "addWhiteList: address must be greater than zero");

        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; i++) {
            whiteLists[_order][_addresses[i]] = true;
        }
    }

    function sale(uint8 _order) public payable whenNotPaused {
        require(_order > 0, "sale: order must be greater than zero");

        // 기간 체크
        require(saleOrders[_order].startTime <= block.timestamp, "sale: sale is not started");
        require(saleOrders[_order].endTime >= block.timestamp, "sale: sale is ended");

        // whitelist 유저인지 체크
        if(saleOrders[_order].whiteList == true) {
            require(whiteLists[_order][msg.sender] == true, "sale: not in whitelist");
        }

        // msg.value로 박스 갯수 체크
        uint256 boxAmount = msg.value / saleOrders[_order].price;
        require(boxAmount * saleOrders[_order].price == msg.value, "sale: incorrect value");
        require(0 < boxAmount, "sale: box amount must be greater than zero");
        require(20 >= boxAmount, "sale: exceeded number of boxes purchasable at one time");
        
        // 유저당 구매 갯수 제한 체크
        boxPerUser[_order][msg.sender] += boxAmount;
        require(boxPerUser[_order][msg.sender] <= saleOrders[_order].limitPerUser, "sale: exceeded number of boxes purchasable");

        // 최대 구매 박스를 초과했는지 체크
        uint256 currentNftId = currentTokenId[_order];
        currentTokenId[_order] += boxAmount;
        require(currentTokenId[_order] - 1 <= saleOrders[_order].endBoxId, "sale: Not enough boxes are left");
        
        for (uint256 i = 0; i < boxAmount; i++) {
            ERC721_BOX.safeTransferFrom(Operator, msg.sender, currentNftId + i);
            emit Sale(msg.sender, _order, currentNftId + i);
        }
    }

    // 보관 중인 판매 코인 출금
    function withdrawEth(address to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(to != address(0), "withdrawEth: transfer to the zero address");
        address payable receiver = payable(to);
        receiver.transfer(address(this).balance);
    }
}
