# kyc.mo

v0.1.0

### Purpose

This library provides an interface for calling icrc_17 KYC service providers.  It abstracts away the inner workings of KYC and lets Dapp developers focus on the results of the call.

### Usage

Installing

mops add kyc

Running KYC

```
let call_with_callback = kyc.run_kyc({
    counterparty = #ICRC1{
        owner = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        subaccount = null;
      };
      token = null;
      amount = null;
      extensible = null; 
      canister = Principal.fromActor(service_actor)}, ?callback);
```

Notifying KYC provider of transaction

```
let a_notification = {
      counterparty = #ICRC1{
        owner = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        subaccount = null;
      };
      token = ?#IC({
        canister = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        id = null;
        symbol = "OGY";
        decimals = 8;
        standard = #ICRC1;
        fee = ?200000
      });
      amount = ?500000000;
      metadata = ?#Nat(64);
    };
    
let a_request = {
      counterparty = #ICRC1{
        owner = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        subaccount = null;
      };
      token = ?#IC({
        canister = Principal.fromText("rkp4c-7iaaa-aaaaa-aaaca-cai");
        id = null;
        symbol = "OGY";
        decimals = 8;
        standard = #ICRC1;
        fee = ?200000
      });
      amount = ?2500000000;
      extensible = null;
    };


    

    let kyc = KYC.kyc({timeout = null; time = ?get_current_time; cache=null});

    
    let a_request_full : KYCTypes.KYCRequest = {a_request with canister = Principal.fromActor(service_actor)};

    let result = await* kyc.notify(a_request_full, a_notification);

```


