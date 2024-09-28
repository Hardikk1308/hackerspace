import {
    Horizon as Aurora,
    Asset,
    Keypair,
    TransactionBuilder,
    BASE_FEE,
    Operation,
    AuthClawbackEnabledFlag,
    AuthRevocableFlag,
} from "diamante-sdk-js";

const server = new Aurora.Server("https://diamtestnet.diamcircle.io");
const networkPassphrase = "Diamante Testnet 2024";

async function accountDetails(wallet) {
    try {
        console.log(wallet.publicKey(), " public key")
        console.log(wallet.secret(), " public key")

        const account = await server.loadAccount("GDQEAUHPLAWU4NVWV5NXZHN6364KKGIRE4ABRS2YSBOZ677SOYVUJDG7");


        console.log(account)//[params])


    } catch (e) {
        console.log(e);

    }
}

const wallet34 = Keypair.fromSecret("SBIQC3T236RUXZPFYY3DIOOE6DWFZEE3M2UXJHPPI6X2YEYXU2JDGSJ7");


// accountDetails(wallet34)

async function assetMinter(asset_name, distributor, recevier) {
    try {
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );

        const account = await server.loadAccount(distributor.publicKey());
        const asset = new Asset(
            asset_name,
            distributor.publicKey()
        );

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
        // .addOperation(
        //     // Operation.allowTrust({
        //     //     trustor: recevier.publicKey(),
        //     //     assetCode: asset_name,
        //     //     authorize: true, // Set to false to revoke the trustline
        //     // })
        // )
            .addOperation(
                Operation.payment({
                    destination: recevier.publicKey(),
                    asset,
                    amount: "1000000",
                }),
                
            )
            .setTimeout(100)
            .build();

        transaction.sign(distributor);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Asset ", asset.code, " distributed  to ", recevier.publicKey())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log(e);

    }
}


async function setupRecevier(recevier, distributor, asset_name) {
    try {

        console.log(asset_name)
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );
        const account = await server.loadAccount(recevier.publicKey());

        const asset = new Asset(
            asset_name,
            distributor.publicKey()
        );

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
            .addOperation(

                Operation.changeTrust({ asset:asset })
            )
            .setTimeout(100)
            .build();

        transaction.sign(recevier);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Trustline created for ", asset.code, " with issuer ", asset.getIssuer())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")
        }
    } catch (e) {
        console.log(e);

    }
}

async function changeTrustClaw(recevier, asset_name , distributor , wallet) {
    try {
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );
        const account = await server.loadAccount(wallet.publicKey());

        const asset = new Asset(
            asset_name,
            distributor.publicKey()
        );

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
            // .addOperation(

            //     Operation.changeTrust({ asset })
            // )
            .addOperation(Operation.changeTrust({
                asset: asset,
                limit: '1000', // Set the trustline limit as needed
                source: wallet.publicKey(),
                setFlags: AuthRevocableFlag
            }))
            .setTimeout(100)
            .build();

        transaction.sign(wallet);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Trustline created for ", asset.code, " with issuer ", asset.getIssuer())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")
        }
    } catch (e) {
        console.log( e.response === undefined ? e : e.response.data.extras );

    }
}

async function transfer(issuer, asset_name, distributor, recevier) {
    try {
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );

        const account = await server.loadAccount(distributor.publicKey());
        const asset = new Asset(
            asset_name,
            issuer.publicKey()
        );

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
            .addOperation(
                Operation.payment({
                    destination: recevier.publicKey(),
                    asset,
                    amount: "500",
                })
            )
            .setTimeout(100)
            .build();

        transaction.sign(distributor);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Asset ", asset.code, " distributed  to ", recevier.publicKey())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log(e);

    }
}

async function clawback(issuer, asset_name, distributor, recevier) {
    try {
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );

        console.log(issuer.publicKey(), " public key ")

        const account = await server.loadAccount(issuer.publicKey());
        const asset = new Asset(
            asset_name,
            issuer.publicKey()
        );

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
            // .addOperation(
            //     Operation.payment({
            //         destination: recevier.publicKey(),
            //         asset,
            //         amount: "500",
            //     })
            // )
            .addOperation(Operation.clawback({
                from: recevier.publicKey(),
                asset: asset,
                amount: "10000"
            }))
            .setTimeout(100)
            .build();

        transaction.sign(issuer);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Asset ", asset.code, " distributed  to ", recevier.publicKey())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log( e.response.data.extras);
        // error.response.data.extras

    }
}


async function createAccount(_account, creator) {
    try {
        const account = await server.loadAccount(creator.publicKey());
        
        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
            .addOperation(
                Operation.createAccount({
                    destination: _account.publicKey(),
                    startingBalance: "25", //base reserve 1 DIAM

                })
            )
            .setTimeout(100)
            .build();

        transaction.sign(creator);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("created account", _account.publicKey(), " with balance 2")
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log(e.response.data.extras);

    }
}



const account1 = Keypair.fromSecret("SAE3AHGV3HPH3FERHFKMNZ4RRJATQWPRAL6F2VWDZA2K6JK66HCAVPPF"); //copy keypair private generated, which will has to be acitvated

const account2 = Keypair.fromSecret("SBNJSKLXLX3YJLVBGG5EOGIAN3VOW7YP5S75RQ65OFG2HD6XI2RISN4W"); //copy keypair private generated, which will has to be acitvated

const creator = Keypair.fromSecret("SCJD5AOKWFLGII2G6TJK5LOC6DIW6QL75G4YO42AW3K5CVG2OSHWLTDW");
/**
 * operations to to activate a account from a source
 */
// createAccount(account2, creator)


async function transferWithMemo(issuer, asset_name, distributor, recevier) {
    try {
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );

        const account = await server.loadAccount(distributor.publicKey());
        const asset = new Asset(
            asset_name,
            issuer.publicKey()
        );

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024 ",
        })
            .addOperation(
                Operation.payment({
                    destination: recevier.publicKey(),
                    asset,
                    amount: "1",
                })
            )
            .addMemo(Memo.text("sampleMemo"))
            .setTimeout(100)
            .build();

        transaction.sign(distributor);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Asset ", asset.code, " distributed  to ", recevier.publicKey(), "With mome sampleMemo")
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log(e);

    }
}


async function storeData(wallet, key, data) {
    try {
        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );

        const account = await server.loadAccount(wallet.publicKey());

        console.log()
        console.log("wallet: ", wallet.publicKey())

        console.log()

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024 ",
        })
            .addOperation(
                Operation.manageData({
                    name: key,
                    value: data
                })
            )
            .setTimeout(100)
            .build();

        transaction.sign(wallet);
        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Stored data ", key, " in wallet ", wallet.publicKey())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log(e);

    }
}

// storeData(account2, "car","etios")
//                           w2           w3
async function setMultiSign(userKeypair, signer) {
    try {
        const account = await server.loadAccount(userKeypair.publicKey());


        const setoptionsOperation = Operation.setOptions({
            medThreshold: 2,
            signer: {
                ed25519PublicKey: signer.publicKey(),
                weight: 1
            }
        });




        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        }).addOperation(

            setoptionsOperation
        )
            .setTimeout(100)
            .build();

        // const transaction = new StellarSdk.TransactionBuilder(account, txOptions)
        //     .addOperation(swapOperation)
        //     .setTimeout(30)
        //     .build();

        transaction.sign(userKeypair);

        const transactionResult = await server.submitTransaction(transaction);
        console.log('Transaction successfully:', transactionResult.hash);
    } catch (error) {
        console.error('Error executing swap:', error);
    }
}

async function clawbackEnabled(userKeypair) {
    try {
        const account = await server.loadAccount(userKeypair.publicKey());


        const setoptionsOperation = Operation.setOptions({
            setFlags: AuthClawbackEnabledFlag
            // medThreshold: 2,
            // signer: {
            //     ed25519PublicKey: signer.publicKey(),
            //     weight: 1
            // }
        });




        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        }).addOperation(

            setoptionsOperation
        )
            .setTimeout(100)
            .build();

        // const transaction = new StellarSdk.TransactionBuilder(account, txOptions)
        //     .addOperation(swapOperation)
        //     .setTimeout(30)
        //     .build();

        transaction.sign(userKeypair);

        const transactionResult = await server.submitTransaction(transaction);
        console.log('Transaction successfully:', transactionResult.hash);
    } catch (error) {
        // console.error('Error executing swap:', error);
        console.log( error.response.data.extras);

    }
}

async function _transfer(w1, w2, amt) {
    try {
        const wallet3 = Keypair.fromSecret("SAM3C36J7CO6EBNBHMDCHYTN6IWUZX627J35VFOM462EMMNE4HIV7GA6");


        const server = new Aurora.Server(
            "https://diamtestnet.diamcircle.io"
        );

        const account = await server.loadAccount(w1.publicKey());

        const transaction = new TransactionBuilder(account, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024",
        })
            .addOperation(
                Operation.payment({
                    destination: w2.publicKey(),
                    asset: Asset.native(),
                    amount: amt.toString(),
                })
            )
            .setTimeout(100)
            .build();

        //med 2
        //w1 = 1
        //wallet3 = 1
        // 1+1 =2
        transaction.sign(w1);
        transaction.sign(wallet3);

        const result = await server.submitTransaction(transaction);
        if (result.successful === true) {
            console.log("###################################")

            console.log()
            console.log("Asset distributed  to ", recevier.publicKey())
            console.log("Transaction hash: ", result.hash)

            console.log()

            console.log("###################################")

        }
    } catch (e) {
        console.log(e);

    }
}


const distributor = Keypair.fromSecret("SCJ4JJMDG2QBXOEMF7QWCDDHZGSYCZX7CT5HRK5STNBEWBQHQ3UZICXZ")//"SADOF6LZVIDCWX4CKFLBR5QMZRRZ3UTG2FUDBRQ53MRCO666OG3VPUBH")//"SC2HI4XH5IORVY6B3MHRSRVXEFHXQAEOZZ7ATDWGKAZPACSNU3U36XES");
const recevier = Keypair.fromSecret("SCABL5AJQSRMDYNDADJGBULZBE6GZEYUDMECFUXTLOR4I2WMDTB5PKEJ")//"SD5Q35U6AO6XTFRJZFSAYVDURMADTARJY4ARAA327YXFR72M4MALN2NF")//"SC4ISJDRNUTYDFKFUOKINM2LLWW6SMH2B4GLQCGVX63K6ZY3MCO4VYNZ");


const wallet1 = Keypair.fromSecret('SBJYJJBW7MZJJOZM6NAQERY6DSPLRY6FX2PAYR5ZYLRUXWZXSCJAEOOA');
// const wallet2 = Keypair.fromSecret("SCS5VSUUYLI4XXU26OYVM5UC2I2SA3PRBJW52AY5JZH765P4ATBOLW77");
// const wallet3 = Keypair.fromSecret("SAM3C36J7CO6EBNBHMDCHYTN6IWUZX627J35VFOM462EMMNE4HIV7GA6");
// const wallet4 = Keypair.fromSecret("SAFQVZ37VEYKQUBMFOB226I7RT7TQ5GYWGPYHWDTSI6JMLBSD2FREDZ5");


console.log("===================================")
console.log()
console.log("distributor :", distributor.publicKey()) //asset issuer
console.log()
console.log("Holder :", recevier.publicKey())
// console.log()
console.log("wallet 1:", wallet1.publicKey())
// console.log()
// console.log("wallet 2:", wallet2.publicKey())
// console.log()
// console.log("wallet 3:", wallet3.publicKey())
// console.log()
// console.log("wallet 4:", wallet4.publicKey())
console.log()
console.log("===================================")

var asset = "hackspace"


/**
 * setupRecevier, where recevier will create a trusline for asset which will minted by distributor
 * once trustline is created, asset can be minted from distributor to recevier
 * incase of NFT, the amount in payment should be mentioned 0.0000001 and in metadata the metadata is updated
 */
//             minter    recevier    asset
// setupRecevier(recevier, distributor, asset).then(function () {
    // assetMinter(asset, distributor, recevier)
// })
// 

//cusotm
// setupRecevier(wallet1, distributor, "CAT24").then(function () {
//     assetMinter("CAT24", distributor, wallet1)
// })

//balances
//data
//subentry_count
//thresholds
//offers
const wallet5 = Keypair.fromSecret("SBWTXJ6WIK63QPEJWJSY5F4PGZWCQQN55ZC6GMYNHUHY22LM4N2AZLQH");

/**
 * to fetch account details, balances, to check subentries, offers made by this account
 */
// accountDetails(wallet5, "balances")

/**
 * setupRecevier, where wallet1 will create a trusline for asset issued by distributor
 * once trustline is created, asset can be transfered from distributor to wallet1
 */
//  setupRecevier(wallet1, distributor, asset)
//  setupRecevier(recevier, distributor, "CAT24")

// changeTrustClaw(recevier, asset, distributor, wallet1)
transfer(distributor, asset, recevier, wallet1)
// clawback(distributor, asset, recevier, wallet1)
// clawbackEnabled(wallet1)
// transferWithMemo(distributor, asset, recevier, wallet4) //Transaction hash:  6c07c304243955c19bf49dd7d54b3dfcbd9230286a35582e06d830bc4fb8cd94


/**
 * trasnaction which demosntrated storing a key value pair in an accounts data field
 * this can used when issuing RWA or NFT assets, where in issuer wallet which will mint the asset to holder, to add metadata to it data filed with asset name as key and makes another trasnaction making it weight(issuer account) 0, does making the data field immutable
 */
// storeData(distributor, "bridgerGoa", "bridge") //Transaction hash:  f25e841a0b8e69523d8b7bf9ff52159b451ffd59f8d5f1bf7959cb0d14b63b40


/**
 * to set signers values, 
 * example, payment operation falls under medium threshold, to transfer any assets held in a account payment opration is used
 * if we set medium threshold lets 4
 * and we add two other wallet, example w1 and w2, with weight of w1 as 1 and weight of w2 as 2, 
 * now when ever this accounts makes a transaction, this accounts weight 1 and when w1 and w2 signs it becomes 1 + 1 + 2 which equal to 4, so now payment transaction would succeed
 * if accounts own masterweight is set to 0, then it will be become a lock account, which means that account cant do any trasanciton with its private key
 */
// setMultiSign(wallet2, wallet3) //Transaction successfully: 40dcde937c138fbeea2d9161bf191f44df674b49ccbf0cb5d181849fd79ff6ec

// _transfer(wallet2, wallet4, 1)


async function setupAssetsAndLiquidity() {
    try {
        asset = new Asset(asset, distributor.publicKey());
        // Load accounts
        const distributorAccount = await server.loadAccount(
            recevier.publicKey()
        );

        const transaction = new TransactionBuilder(distributorAccount, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024 2024",
        })
            .addOperation(
                Operation.manageSellOffer({
                    selling: asset,//What you're selling.
                    buying: Asset.native(),//What you're buying. //custom abc
                    amount: "200", //The total amount you're selling. If 0, deletes the offer.
                    price: "1", //Price of 1 unit of selling in terms of buying.
                    // offerId: "475" // to update a existing offer
                })
            )
            .setTimeout(30)
            .build();

        transaction.sign(recevier);
        await server.submitTransaction(transaction);

        console.log(
            "Assets created, trustlines set, and liquidity added successfully."
        );
    } catch (error) {
        console.error("Error setting up assets and liquidity:", error);
    }
}

async function buy() {

    asset = new Asset(asset, distributor.publicKey());

    try {
        // Load accounts
        const distributorAccount = await server.loadAccount(
            wallet1.publicKey()
        );

        const transaction3 = new TransactionBuilder(distributorAccount, {
            fee: BASE_FEE,
            networkPassphrase,
        })

            .addOperation(
                Operation.manageBuyOffer({
                    selling: Asset.native(),//What you're selling.
                    buying: asset,//What you're buying.
                    buyAmount: "5", //The total amount you're buying. If 0, deletes the offer.
                    // amount: "2000",
                    price: "2", //Price of 1 unit of buying in terms of selling.
                    // offerId: "475"


                })
            )
            .setTimeout(30)
            .build();

        transaction3.sign(wallet1);
        await server.submitTransaction(transaction3);

        console.log(
            "Assets traded"
        );
    } catch (error) {
        console.error("Error setting up assets and liquidity:", error);
    }
}

/**
 * operations to sell assets for other assets, defined the overall quantity to be sold and what would be price of each
 */
// setupAssetsAndLiquidity()
async function setupAssetsAndLiquiditycat() {
    try {
        asset = new Asset("CAT24", distributor.publicKey());
        // Load accounts
        const distributorAccount = await server.loadAccount(
            wallet1.publicKey()
        );

        const transaction = new TransactionBuilder(distributorAccount, {
            fee: BASE_FEE,
            networkPassphrase: "Diamante Testnet 2024 2024",
        })
            .addOperation(
                Operation.manageSellOffer({
                    selling: asset,//What you're selling.
                    buying: new Asset("testOffer2", distributor.publicKey()),//Asset.native(),//What you're buying. //custom abc
                    amount: "200", //The total amount you're selling. If 0, deletes the offer.
                    price: "1", //Price of 1 unit of selling in terms of buying.
                    // offerId: "475" // to update a existing offer
                })
            )
            .setTimeout(30)
            .build();

        transaction.sign(wallet1);
        await server.submitTransaction(transaction);

        console.log(
            "Assets created, trustlines set, and liquidity added successfully."
        );
    } catch (error) {
        console.error("Error setting up assets and liquidity:", error);
    }
}

// setupAssetsAndLiquiditycat()

/**
 * operations to buy assets with other assets, defining the price with from above trasnaction (setupAssetsAndLiquidity)
 */
// buy()


async function buyCAT() {

    asset = new Asset("testOffer2", distributor.publicKey());

    try {
        // Load accounts
        const distributorAccount = await server.loadAccount(
            recevier.publicKey()
        );

        const transaction3 = new TransactionBuilder(distributorAccount, {
            fee: BASE_FEE,
            networkPassphrase,
        })

            .addOperation(
                Operation.manageBuyOffer({
                    selling: asset,//What you're selling.
                    buying: new Asset("CAT24", distributor.publicKey()),//What you're buying.
                    buyAmount: "5", //The total amount you're buying. If 0, deletes the offer.
                    // amount: "2000",
                    price: "1", //Price of 1 unit of buying in terms of selling.
                    // offerId: "475"


                })
            )
            .setTimeout(30)
            .build();

        transaction3.sign(recevier);
        await server.submitTransaction(transaction3);

        console.log(
            "Assets traded"
        );
    } catch (error) {
        console.error("Error setting up assets and liquidity:", error);
    }
}


// buyCAT()