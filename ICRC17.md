# ICRC-17 - Elective KYC Service Standard

## Data Details

* icrc: 17
* title: ICRC-17 Elective KYC Standard
* author: Austin Fatheree - austin dot fatheree at gmail dot com - @afat on twitter
* status: Deliberating
* category: ICRC
* requires: ICRC-16
* created: 2023-Mar-10
* updated: 2023-Mar-10

## Context

The proposed ICRC-17 Elective KYC Standard aims to establish an interface for dapps to communicate with KYC Service canisters on the Internet Computer. The standard defines two simple functions that allow dapps to request KYC checks for users and to notify the KYC Service canister when users transact a certain amount of tokens. The standard also defines a set of types that can be used to represent the necessary data for KYC checks and results.

## Assumptions
The ICRC-17 standard relies on the following assumptions:

* KYC should be elective by the stakeholders involved in a transaction, with varying levels of KYC required depending on the stakeholders involved.
* KYC is important and a practical reality for many users in certain jurisdictions, as well as for dapp providers building in those jurisdictions.
* The minimal information required for KYC should be known only to the KYC Service canister, which can handle the KYC and AML checks on behalf of the dapp.

## Goals and Objectives
The ICRC-17 Elective KYC Standard aims to achieve the following goals and objectives:

* Provide a simple and standardized interface for dapps to request KYC checks for users.
* Provide a simple and standardized interface for dapps to notify the KYC Service canister when users transact a certain amount of tokens.
* Improve interoperability between different KYC Service canisters and dapps.
* Simplify the integration of KYC checks into dapps.

Interface Details
The ICRC-17 Elective KYC Standard defines two simple functions, icrc17_kyc_request and icrc17_kyc_notification, that can be used to request KYC checks for users and to notify the KYC Service canister when users transact a certain amount of tokens. The standard also defines a set of types, including KYCCanisterRequest, KYCResult, and KYCNotification

The details of the interface are as follows:

```
service {
   icrc17_kyc_notification: (KYCNotification) -> (); //one shot - notify service of a transaction
   icrc17_kyc_request: (KYCCanisterRequest) -> (KYCResult); // request kyc - aml info
 };

type TokenSpec = 
 variant {
   Extensible: CandyShared; //for future use cases
   IC: ICTokenSpec;
 };
type KYCResult = 
 record {
   aml: variant {
          Fail;
          NA;
          Pass;
        };
   amount: opt nat;
   kyc: variant {
          Fail;
          NA;
          Pass;
        };
   message: opt text;
   token: opt TokenSpec;
   timeout: opt nat;
 };
type KYCCanisterRequest = 
 record {
   amount: opt nat;
   counterparty: KYCAccount;
   token: opt TokenSpec;
 };
type KYCNotification = 
 record {
   amount: opt nat;
   counterparty: KYCAccount;
   token: opt TokenSpec;
 };
type KYCAccount = 
 variant {
   Account: vec nat8;
   Extensible: CandyShared;
   ICRC1: record {
            owner: principal;
            subaccount: opt vec nat8;
          };
 };
type ICTokenSpec = 
 record {
   canister: principal;
   decimals: nat;
   fee: opt nat;
   id: opt nat; //used for multi-token canisters
   standard: variant {
               DIP20;
               EXTFungible;
               ICRC1;
               Ledger;
               Other: CandyShared; //for future use
             };
   symbol: text;
 };
type PropertyShared = 
 record {
   immutable: bool;
   name: text;
   value: CandyShared;
 };
type CandyShared = 
 variant {
   Array: vec CandyShared;
   Blob: blob;
   Bool: bool;
   Bytes: vec nat8;
   Class: vec PropertyShared;
   Float: float64;
   Floats: vec float64;
   Int: int;
   Int16: int16;
   Int32: int32;
   Int64: int64;
   Int8: int8;
   Map: vec record {
              CandyShared;
              CandyShared;
            };
   Nat: nat;
   Nat16: nat16;
   Nat32: nat32;
   Nat64: nat64;
   Nat8: nat8;
   Nats: vec nat;
   Option: opt CandyShared;
   Principal: principal;
   Set: vec CandyShared;
   Text: text;
 };
 ```


The icrc17_kyc_request function allows the user to submit a request for a KYC check. The request includes a principal, a token specification, and an amount that the user wants to transact. Some of these fields are optional, and it is up to the KYC Service canister to determine if enough information has been provided. The response includes whether the user passed KYC and AML checks, as well as the maximum amount of the provided token that the user is allowed to transact. The KYC Service canister may provide a timeout in its response that the dapp should honor and resubmit a request if the timeout period passes.

The icrc17_kyc_notification function is a one-shot function that a service can call to notify the KYC Service canister when a user transacts a certain number of tokens. This allows the KYC Service canister to adjust the allocations based on time periods. 

The types used in the ICRC-17 Elective KYC Standard implement the ICRC-15 CandyShared standard, allowing for future changes and extensibility.

## Use Cases

The ICRC-17 Elective KYC Standard enables three forms of elective KYC that dapps can implement according to their specific needs:

Dapp level KYC: In this scenario, any asset administered by the dapp will need to have buyers KYCed. This approach can help to ensure that all transactions conducted within the dapp are compliant with KYC regulations.  In the instance of an NFT collection, the collection owner may want to elect that transactions that involve their collection involve KYC.  Users of the system must decide if they want to engage if the collection owner elects to do this.

Transaction level KYC: Any seller of an asset can indicate that they only want to transact with KYCed users on a per-transaction basis. This approach can provide an additional layer of security for sellers and reduce the risk of fraudulent or tainted transactions.

Elective level KYC: In this scenario, a user may elect broadly that they want to only participate with KYCed users and declare a specific KYC platform to use to validate buyers. This approach can provide users with more control over their KYC data and streamline the process of conducting KYC checks across multiple dapps.  This particular service may warrant its own ICRC standard and discussions as to where this registry should reside.

Ultimately, it will be the dapp's decision and responsibility to implement these forms of elective KYC. By providing a standardized interface for KYC Service canisters, the ICRC-17 Elective KYC Standard can help to simplify the process of conducting KYC checks and support the growth of dapps on the Internet Computer.


## Conclusion

The ICRC- 17 Elective KYC Standard proposes a simple interface for dapps to communicate with KYC Service canisters on the Internet Computer. The standard is designed to make KYC elective for stakeholders involved in a transaction, while also allowing KYC to be conducted in a practical and efficient manner for users and dapp developers alike.

The standard relies on the assumption that KYC is important and a practical reality for many users in certain jurisdictions, but that it should not burden dapp developers with the complexity of conducting KYC checks. Instead, all the dapp knows is a principal, and it subscribes or relies on a KYC Service canister that returns only if the principal passes KYC and AML checks and the amount that they are allowed to transact at.





