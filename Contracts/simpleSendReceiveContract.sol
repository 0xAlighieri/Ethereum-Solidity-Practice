pragma solidity ^0.4.0;

contract owned {
    address owner;

    modifier onlyowner() {
        if (msg.sender == owner) {
            _;
        }
    }

    function owned() {
        owner = msg.sender;
    }
}

contract mortal is owned {
    function kill() {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}

contract SimpleWallet is mortal {
    
    
    mapping(address => Permission) permittedAddresses;
    
    event someoneAddedSomeoneToTheSendersList(address thePersonWhoAdded, address thePersonWhoIsAllowedNow, uint thisMuchHeCanSend);
    event someoneSentFunds(address thePersonReceiving, uint amountSentInWei);
    event someoneRemovedSomeoneFromSendersList(address thePersonRemoved);
    event anonFunctionFired();

    struct Permission {
        bool isAllowed;
        uint maxTransferAmount;
    }
    
    function addAddressToSendersList (address permitted, uint maxTransferAmount) onlyowner {
        permittedAddresses[permitted] = Permission(true, maxTransferAmount);
        someoneAddedSomeoneToTheSendersList(msg.sender, permitted, maxTransferAmount);
        
    }
    
    function sendFunds(address receiver, uint amountInWei)  {
        require(permittedAddresses[msg.sender].isAllowed && permittedAddresses[msg.sender].maxTransferAmount >= amountInWei); 
        bool isTheAmountReallySent = receiver.send(amountInWei);
        someoneSentFunds(receiver, amountInWei);

    }
    
    function removeAddressFromSendersList(address theAddress) {
        delete permittedAddresses[theAddress];
        someoneRemovedSomeoneFromSendersList(theAddress);
    }
    
    function () payable {
        anonFunctionFired();
        
    }
}
