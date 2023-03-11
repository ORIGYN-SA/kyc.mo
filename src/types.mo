import CandyTypes "mo:candy_0_2_0/types";
import Map "mo:map_7_0_0/Map";

module {

  public type KYCResult = { 
    kyc: {
      #Pass;
      #Fail;
      #NA;
    };
    aml: {
      #Pass;
      #Fail;
      #NA
    };
    token: ?TokenSpec;
    amount: ?Nat;
    message : ?Text;
};



public type KYCResultFuture = {
  result: KYCResult;
  timeout: Int;
};

  public type TokenSpec = {
    #IC: ICTokenSpec;
    #Extensible : CandyTypes.CandyShared; //#Class
  };

  public type ICTokenSpec = {
    canister: Principal;
    fee: ?Nat;
    symbol: Text;
    decimals: Nat;
    id: ?Nat; //use this if you have a multi token canister.  Convert identifiers to Nat using Candy.Conversion.valueToNat();
    standard: {
      #DIP20;
      #Ledger;
      #EXTFungible;
      #ICRC1;
      #Other : CandyTypes.CandyShared;
    };
  }; 

  public type KYCRequest = {
    canister : Principal;
    counterparty: KYCAccount;
    token: ?TokenSpec;
    amount: ?Nat;
  };

  public type KYCAccount = {
    #ICRC1: {
      owner: Principal;
      subaccount: ?[Nat8];
    };
    #Account: [Nat8];
    #Extensible: CandyTypes.CandyShared;
  };

  public type KYCNotification =  {
    counterparty: KYCAccount;
    token: ?TokenSpec;
    amount: ?Nat;
  };

  public type KYCClassInitArgs = {
    time : ?(() -> Int);
    timeout : ?Int;
    cache : ?CacheMap;
  };

  public type CacheMap = Map.Map<KYCRequest, KYCResultFuture>;

  public type KYCRequestCallBack = (KYCResult) -> ();

  public type Service = actor {
    icrc17_kyc_request : (KYCRequest) -> async KYCResult;
    icrc17_kyc_notification : (KYCNotification) -> (); //one shot
  };

}
