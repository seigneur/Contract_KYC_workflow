pragma solidity ^0.4.24;
import "./lib/Whitelist.sol";
import "./lib/Token.sol";

/**
 * @title TraceToSPList
 * @dev This contract is the whitelist contract for requesters.
 */
contract TraceToRequestorList is Ownable, Whitelist {
    struct meta {
        string country;
        string name;
        string email;
        string uriForMoreDetails;
        string hashForMoreDetails;
    }

    mapping(address => meta) pendingMetaInfo;
    mapping(address => meta) metaInfo;

    event NewPendingRequestor(address _requestorPR);
    event DetailUpdated(address _requestorPR, string detail);

    /**
      * @dev only requestors in the whitelist
      */
    modifier onlyRequestor(){
        require(isRequestorPR(msg.sender));
        _;
    }

    /** 
      * @dev constructor of this contract, it will use the constructor of whiltelist contract
      * @param owner Owner of this contract
      */
    constructor( address owner ) Whitelist(owner) public {}

    /**  
      * @dev add a wallet as a pending requestor (PR contract)
      * @param _requestorPR the PR contract deployed by this requestor (PR contract)
      * @param _country the country for this requestor (PR contract)
      * @param _name the name for this requestor (PR contract)
      * @param _email the email for this requestor (PR contract)
      * @param _uriForMoreDetails the IPFS link for this requestor (PR contract) to put more infomation
      * @param _hashForMoreDetails the hash of the JSON object in IPFS
      */
    function addPendingRequestorPR(address _requestorPR, string _country, string _name, string _email, string _uriForMoreDetails, string _hashForMoreDetails)
    public {
        pendingMetaInfo[_requestorPR] = meta(_country, _name, _email, _uriForMoreDetails, _hashForMoreDetails);
        emit NewPendingRequestor(_requestorPR);
    }

    /**
      * @dev Approve a pending requestor (PR contract), only can be called by the owner
      * @param _requestorPR the address of this requestor (PR contract)
      */
    function approveRequestorPR(address _requestorPR)
    public
    onlyOwner{
        metaInfo[_requestorPR] = pendingMetaInfo[_requestorPR];
        
        delete pendingMetaInfo[_requestorPR];
        addAddressToWhitelist(_requestorPR);
    }

    /**
      * @dev Remove a requestor (PR contract), only can be called by the owner
      * @param _requestorPR the address of this requestor (PR contract)
      */
    function removeRequestorPR(address _requestorPR)
    public
    onlyOwner{
        delete metaInfo[_requestorPR];

        removeAddressFromWhitelist(_requestorPR);
    }

    /**
      * @dev check whether an address is a requestor (PR contract)
      * @param _requestorPR the address going to be checked
      * @return _isRequestorPR true if the address is a requestor (PR contract)
      */
    function isRequestorPR(address _requestorPR) 
    public
    view
    returns(bool _isRequestorPR){
        return isWhitelisted(_requestorPR);
    }

    /**
      * @dev check get details of a pending requestor (PR contract)
      * @return _verifier the verifier wallet
      * @return _country the country for this requestor (PR contract)
      * @return _name the name for this requestor (PR contract)
      * @return _email the email for this requestor (PR contract)
      * @return _uriForMoreDetails the IPFS link for this requestor (PR contract) to put more infomation
      * @return _hashForMoreDetails the hash of the JSON object in IPFS
      */
    function getPendingRequestorPRMeta(address _requestorPR)
    public
    view
    returns(string _country, string _name, string _email, string _uriForMoreDetails, string _hashForMoreDetails){
        return (pendingMetaInfo[_requestorPR].country, pendingMetaInfo[_requestorPR].name, pendingMetaInfo[_requestorPR].email, pendingMetaInfo[_requestorPR].uriForMoreDetails, pendingMetaInfo[_requestorPR].hashForMoreDetails);
    }

    /**
      * @dev check get details of a requestor (PR contract)
      * @return _verifier the verifier wallet
      * @return _country the country for this requestor (PR contract)
      * @return _name the name for this requestor (PR contract)
      * @return _email the email for this requestor (PR contract)
      * @return _uriForMoreDetails the IPFS link for this requestor (PR contract) to put more infomation
      * @return _hashForMoreDetails the hash of the JSON object in IPFS
      */
    function getRequestorPRMeta(address _requestorPR)
    public
    view
    returns(string _country, string _name, string _email, string _uriForMoreDetails, string _hashForMoreDetails){
        return (metaInfo[_requestorPR].country, metaInfo[_requestorPR].name, metaInfo[_requestorPR].email, metaInfo[_requestorPR].uriForMoreDetails, metaInfo[_requestorPR].hashForMoreDetails);
    }

    /**
      * @dev transfer ERC20 token out in emergency cases, can be only called by the contract owner
      * @param _token the token contract address
      * @param amount the amount going to be transfer
      */
    function emergencyERC20Drain(Token _token, uint256 amount )
    public
    onlyOwner{
        address tracetoMultisig = 0x146f2Fba9EBa1b72d5162a56e3E5da6C0f4808Cc;
        _token.transfer( tracetoMultisig, amount );
    }
}