pragma solidity ^0.8.0;

contract DistributionCenter {
    struct Product {
        string name;
        uint price;
        uint quantity;
        string category;
    }

    struct Order {
        address customer;
        uint orderId;
        uint[] productIds;
        uint[] quantities;
        bool delivered;
    }

    mapping(uint => Product) public products;
    mapping(uint => Order) public orders;
    uint public productCount;
    uint public orderCount;

    event OrderPlaced(uint orderId, address customer);
    event ProductDelivered(uint orderId);

    function addProduct(string memory _name, uint _price, uint _quantity, string memory _category) public {
        productCount++;
        products[productCount] = Product(_name, _price, _quantity, _category);
    }

    function placeOrder(uint[] memory _productIds, uint[] memory _quantities) public {
        require(_productIds.length == _quantities.length, "Invalid order");

        orderCount++;
        orders[orderCount] = Order(msg.sender, orderCount, _productIds, _quantities, false);

        emit OrderPlaced(orderCount, msg.sender);
    }

    function deliverProduct(uint _orderId) public {
        Order storage order = orders[_orderId];
        require(order.customer == msg.sender, "Only customer can mark order as delivered");

        for (uint i = 0; i < order.productIds.length; i++) {
            Product storage product = products[order.productIds[i]];
            require(product.quantity >= order.quantities[i], "Not enough stock for delivery");
            product.quantity -= order.quantities[i];
        }

        order.delivered = true;

        emit ProductDelivered(_orderId);
    }
}
