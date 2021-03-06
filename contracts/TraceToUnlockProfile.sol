pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./lib/Withdrawable.sol";

import "./TraceToMetaInfoInterface.sol";
import "./TraceToRequestorListInterface.sol";
import "./TraceToVerifierListInterface.sol";

import "./TraceToUnlockProfileInterface.sol";

/**
 * @title TraceToUnlockProfile
 * @dev This contract is for requestor to request the key for profiles.
 */
contract TraceToUnlockProfile is Withdrawable, TraceToUnlockProfileInterface{
    using SafeMath for uint256;
    struct ProfileKey {
        string[] keyPieces;
        uint256 keyCount;
        mapping(bytes32 => bool) keyPieceExists;
        bool isInit;
    }

    struct RequestedProfile {
        mapping(uint256 => ProfileKey) RequestedProfiles;
        mapping(uint256 => string) reasons;
    }

    mapping(address => RequestedProfile) requests;

    uint256 minCount = 10;

    TraceToMetaInfoInterface public tracetoMetaInfo;
    TraceToVerifierListInterface public tracetoVerifierList;

    event ProfileRequested(uint256 profile, string reason, address requestor);
    event KeyShared(uint256 profile, address requestor);

    /**
      * @dev Only the requestor in the requestor list contract.
      */
    modifier onlyRequestor {
        require(TraceToRequestorListInterface(tracetoMetaInfo.getRequestorWL()).isRequestorPR(msg.sender));
        _;
    }

    modifier onlyVerifier {
        require(TraceToVerifierListInterface(tracetoMetaInfo.getVerifierWL()).isVerifier(msg.sender, 1));
        _;
    }

    /** 
      * @dev constructor of this contract, it will transfer ownership and use the requestor list and verifier list set in meta info contract 
      * @param owner Owner of this contract
      * @param _metaInfo meta info contract address
      */
    constructor(address owner, address _metaInfo)
    public {
        transferOwnership(owner);

        tracetoMetaInfo = TraceToMetaInfoInterface(_metaInfo);
    }

    /**  
      * @dev request to unlock a new profile
      * @param _profileHash the profile id 
      * @param _reason the reason for unlocking this profile
      */
    function requestProfileKey(uint256 _profileHash, string _reason)
    public
    onlyRequestor{
        assert(!requests[msg.sender].RequestedProfiles[_profileHash].isInit);

        requests[msg.sender].RequestedProfiles[_profileHash].isInit = true;
        requests[msg.sender].reasons[_profileHash] = _reason;

        emit ProfileRequested(_profileHash, _reason, msg.sender);
    }

    /**  
      * @dev share the encrypted key piece of one profile to one requestor, can be called by verifier only
      * @param _profileHash the profile id 
      * @param _keyPiece the encrypted key piece, the duplicate one will be rejected
      * @param _requestor the requestor who will get this piece
      */
    function setKey(uint256 _profileHash, string _keyPiece, address _requestor)
    public
    onlyVerifier{
        assert(!requests[_requestor].RequestedProfiles[_profileHash].keyPieceExists[keccak256(bytes(_keyPiece))]);
        requests[_requestor].RequestedProfiles[_profileHash].keyPieces.push(_keyPiece);
        requests[_requestor].RequestedProfiles[_profileHash].keyCount = requests[_requestor].RequestedProfiles[_profileHash].keyCount.add(1);
        requests[_requestor].RequestedProfiles[_profileHash].keyPieceExists[keccak256(bytes(_keyPiece))] = true;

        if(requests[_requestor].RequestedProfiles[_profileHash].keyCount >= minCount)
            emit KeyShared(_profileHash, _requestor);
    }

    /**  
      * @dev get the reason for one request
      * @param _profileHash the profile id 
      * @param _requestor the requestor who requested this profile
      */
    function getReason(uint256 _profileHash, address _requestor)
    public
    view
    returns (string reason){
        return requests[_requestor].reasons[_profileHash];
    }

    /**  
      * @dev once the key is shared, requestor can retrieve the key via this function
      * @param _profileHash the profile id 
      * @param _idx the idx of the key piece, will remove if solidity allow string[] returns later
      * @return keyPieces the requested key piece
      */
    function getKey(uint256 _profileHash, uint256 _idx)
    public
    onlyRequestor
    view
    returns (string _keyPieces){
        assert(requests[msg.sender].RequestedProfiles[_profileHash].isInit
            && requests[msg.sender].RequestedProfiles[_profileHash].keyCount >= minCount 
            && _idx >= 0 
            && _idx < minCount);

        return requests[msg.sender].RequestedProfiles[_profileHash].keyPieces[_idx];
    }
}
