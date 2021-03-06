pragma solidity 0.4.24;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./lib/Whitelist.sol";
import "./TraceToVerifierListInterface.sol";

/**
 * @title TraceToVerifierList
 * @dev This contract is the whitelist contract for verifiers
 *      Verifier's are split into tiers from 1-3, the third tier being the most reputed
 */
contract TraceToVerifierList is Whitelist, TraceToVerifierListInterface{
    using SafeMath for uint256;
    struct meta {
        uint256 reputation;
        string urlForUploading;
        string hashForUploading;
        uint256 tier;
        uint256 idx;
    }

    mapping(address => meta) pendingMetaInfo;
    mapping(address => meta) metaInfo;

    uint256 verifierT1Count = 0;
    uint256 verifierT2Count = 0;
    uint256 verifierT3Count = 0;

    address[] verifierT1List;
    address[] verifierT2List;
    address[] verifierT3List;

    event NewPendingVerifier(address verifier);
    event UrlUpdated(address verifier, string url);

    /**
      * @dev At least T1 verifier.
      */
    modifier onlyVerifier {
        require(isVerifier(msg.sender, 1));
        _;
    }

    /** 
      * @dev constructor of this contract, it will use the constructor of whiltelist contract
      * @param owner Owner of this contract
      */
    constructor( address owner ) Whitelist(owner) public {}

    /**  
      * @dev add the current wallet as a pending verifier
      * @param _urlForUploading the url for end user to upload their profiles
      * @param _hashForUploading the hash for the url
      */
    function addPendingVerifier(string _urlForUploading, string _hashForUploading)
    public {
        pendingMetaInfo[msg.sender] = meta(100, _urlForUploading, _hashForUploading, 0, 0);

        emit NewPendingVerifier(msg.sender);
    }

    /**
      * @dev Approve a pending verifier, only can be called by the owner
      * @param _verifier the address of this verifier
      * @param _tier the tier for this verifier
      */
    function approveVerifier(address _verifier, uint256 _tier)
    public
    onlyOwner {
        metaInfo[_verifier] = pendingMetaInfo[_verifier];
        if(_tier >= 3){
            metaInfo[_verifier].tier = 3;
            verifierT3Count = verifierT3Count.add(1);
            metaInfo[_verifier].idx = verifierT3Count.sub(1);
            verifierT3List.push(_verifier);
        }
        else if(_tier <= 1){
            metaInfo[_verifier].tier = 1;
            verifierT1Count = verifierT1Count.add(1);
            metaInfo[_verifier].idx = verifierT1Count.sub(1);
            verifierT1List.push(_verifier);
        }
        else{
            metaInfo[_verifier].tier = _tier;
            verifierT2Count = verifierT2Count.add(1);
            metaInfo[_verifier].idx = verifierT2Count.sub(1);
            verifierT2List.push(_verifier);
        }

        delete pendingMetaInfo[_verifier];
        addAddressToWhitelist(_verifier);
    }

    /**
      * @dev Remove a verifier, only can be called by the owner
      * @param _verifier the address of this verifier
      */
    function removeVerifier(address _verifier)
    public
    onlyOwner  {
        uint256 _tier = metaInfo[_verifier].tier;
        if(_tier >= 3){
            verifierT3Count = verifierT3Count.sub(1);
            if(metaInfo[_verifier].idx < verifierT3List.length){
                for (uint256 i = metaInfo[_verifier].idx; i<verifierT3List.length-1; i = i.add(1)){
                    verifierT3List[i] = verifierT3List[i+1];
                }
                delete verifierT3List[verifierT3List.length-1];
                verifierT3List.length = verifierT3Count;
            }
        }
        else if(_tier <= 1){
            verifierT1Count = verifierT1Count.sub(1);
            if(metaInfo[_verifier].idx < verifierT1List.length){
                for (uint256 j = metaInfo[_verifier].idx; j<verifierT1List.length-1; j = j.add(1)){
                    verifierT1List[j] = verifierT1List[j+1];
                }
                delete verifierT1List[verifierT1List.length-1];
                verifierT1List.length = verifierT1Count;
            }
        }
        else{
            verifierT2Count = verifierT2Count.sub(1);
            if(metaInfo[_verifier].idx < verifierT2List.length){
                for (uint256 k = metaInfo[_verifier].idx; k<verifierT2List.length-1; k = k.add(1)){
                    verifierT2List[k] = verifierT2List[k+1];
                }
                delete verifierT2List[verifierT2List.length-1];
                verifierT2List.length = verifierT2Count;
            }
        }

        delete metaInfo[_verifier];
        removeAddressFromWhitelist(_verifier);
    }


    /**
      * @dev Update tier for a verifier , only can be called by the owner
      * @param _verifier the address of this verifier
      * @param _tier the updated tier
      */
    function updateVerifierTier(address _verifier, uint256 _tier)
    public
    onlyOwner {
        uint256 _prev_tier = metaInfo[_verifier].tier;
        if(_prev_tier >= 3){
            verifierT3Count = verifierT3Count.sub(1);
            if(metaInfo[_verifier].idx < verifierT3List.length){
                for (uint256 i = metaInfo[_verifier].idx; i<verifierT3List.length-1; i = i.add(1)){
                    verifierT3List[i] = verifierT3List[i+1];
                }
                delete verifierT3List[verifierT3List.length-1];
                verifierT3List.length = verifierT3Count;
            }
        }
        else if(_prev_tier <= 1){
            verifierT1Count = verifierT1Count.sub(1);
            if(metaInfo[_verifier].idx < verifierT1List.length){
                for (uint256 j = metaInfo[_verifier].idx; j<verifierT1List.length-1; j = j.add(1)){
                    verifierT1List[j] = verifierT1List[j+1];
                }
                delete verifierT1List[verifierT1List.length-1];
                verifierT1List.length = verifierT1Count;
            }
        }
        else{
            verifierT2Count = verifierT2Count.sub(1);
            if(metaInfo[_verifier].idx < verifierT2List.length){
                for (uint256 k = metaInfo[_verifier].idx; k<verifierT2List.length-1; k = k.add(1)){
                    verifierT2List[k] = verifierT2List[k+1];
                }
                delete verifierT2List[verifierT2List.length-1];
                verifierT2List.length = verifierT2Count;
            }
        }

        if(_tier >= 3){
            metaInfo[_verifier].tier = 3;
            verifierT3Count = verifierT3Count.add(1);
            metaInfo[_verifier].idx = verifierT3Count.sub(1);
            verifierT3List.push(_verifier);
        }
        else if(_tier <= 1){
            metaInfo[_verifier].tier = 1;
            verifierT1Count = verifierT1Count.add(1);
            metaInfo[_verifier].idx = verifierT1Count.sub(1);
            verifierT1List.push(_verifier);
        }
        else{
            metaInfo[_verifier].tier = _tier;
            verifierT2Count = verifierT2Count.add(1);
            metaInfo[_verifier].idx = verifierT2Count.sub(1);
            verifierT2List.push(_verifier);
        }
    }

    /**
      * @dev Update a verifier reputation, only can be called by the owner
      * @param _verifier the address of this verifier
      * @param _reputation the updated reputation
      */
    function setReputation(address _verifier, uint256 _reputation)
    public
    onlyOwner {
        metaInfo[_verifier].reputation = _reputation;
    }

    /**
      * @dev Update the data url for verifiers themselves, only can be called by the verifiers
      * @param _url the updated url
      * @param _hash the hash of this updated url
      */
    function setUrl(string _url, string _hash)
    public
    onlyVerifier {
        metaInfo[msg.sender].urlForUploading = _url;
        metaInfo[msg.sender].hashForUploading = _hash;
        emit UrlUpdated(msg.sender, _url);
    }

    /**
      * @dev get the full list of verifiers in the specific tier
      * @param _tier the tier of verifiers which is returning
      * @param _startIdx the start idx for retreving
      * @param _length the list length
      * @return verifiers the list of verifiers
      */
    function getVerifierList(uint256 _tier, uint256 _startIdx, uint256 _length)
    public
    view
    returns (address[] verifiers){
        verifiers = new address[](_length);
        if(_tier >= 3){
            require(_startIdx+_length <= verifierT3List.length);
            for (uint256 i = 0; i<_length; i++){
                verifiers[i] = verifierT3List[i+_startIdx];
            }
        }
        else if(_tier <= 1){
            require(_startIdx+_length <= verifierT1List.length);
            for (uint256 j = 0; j<_length; j++){
                verifiers[j] = verifierT1List[j+_startIdx];
            }
        }
        else{
            require(_startIdx+_length <= verifierT2List.length);
            for (uint256 k = 0; k<_length; k++){
                verifiers[k] = verifierT2List[k+_startIdx];
            }
        }
    }

    /**
      * @dev check whether a wallet is a verifier with tier
      * @param _verifier the wallet going to be checked
      * @param _tier the tier going to be checked
      * @return _isVerifier true if the user has the same or higher tier
      */
    function isVerifier(address _verifier, uint256 _tier)
    public
    view
    returns (bool _isVerifier){
        return isWhitelisted(_verifier) && metaInfo[_verifier].tier >= _tier;
    }

    /**
      * @dev check get details of a pending verifier
      * @param _verifier the verifier wallet
      * @return _reputation the reputation
      * @return _urlForUploading url for uploading
      * @return _hashForUploading hash for the url
      */
    function getPendingVerifierDetail(address _verifier)
    public
    view
    returns (uint256 _reputation, string _urlForUploading, string _hashForUploading) {
        return (pendingMetaInfo[_verifier].reputation, pendingMetaInfo[_verifier].urlForUploading, pendingMetaInfo[_verifier].hashForUploading);
    }

    /**
      * @dev check get details of a verifier
      * @param _verifier the verifier wallet
      * @return _reputation the reputation
      * @return _urlForUploading url for uploading
      * @return _hashForUploading hash for the url
      */
    function getVerifierDetail(address _verifier)
    public
    view
    returns (uint256 _reputation, string _urlForUploading, string _hashForUploading) {
        return (metaInfo[_verifier].reputation, metaInfo[_verifier].urlForUploading, metaInfo[_verifier].hashForUploading);
    }
}