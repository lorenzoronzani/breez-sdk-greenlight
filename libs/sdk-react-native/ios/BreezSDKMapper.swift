import Foundation
import BreezSDK

class BreezSDKMapper {
    static func arrayOf(fiatCurrencies: [FiatCurrency]) -> [Any] {
        return fiatCurrencies.map { (fiatCurrency) -> [String: Any] in return dictionaryOf(fiatCurrency: fiatCurrency) }
    }
    
    static func arrayOf(localizedNames: [LocalizedName]?) -> [Any]? {
        if localizedNames != nil {
            return localizedNames?.map { (localizedName) -> [String: Any] in return dictionaryOf(localizedName: localizedName) }
        }
        
        return nil
    }
    
    static func arrayOf(localeOverrides: [LocaleOverrides]?) -> [Any]? {
        if localeOverrides != nil {
            return localeOverrides?.map { (localeOverride) -> [String: Any?] in return dictionaryOf(localeOverride: localeOverride) }
        }
        
        return nil
    }
    
    static func arrayOf(lsps: [LspInformation]) -> [Any] {
        return lsps.map { (lspInformation) -> [String: Any?] in return dictionaryOf(lspInformation: lspInformation) }
    }
    
    static func arrayOf(openingFeeParamsValues: [OpeningFeeParams]) -> [Any] {
        return openingFeeParamsValues.map { (openingFeeParams) -> [String: Any]? in return dictionaryOf(openingFeeParams: openingFeeParams) }
    }
    
    static func arrayOf(payments: [Payment]) -> [Any] {
        return payments.map { (payment) -> [String: Any?] in return dictionaryOf(payment: payment) }
    }
    
    static func arrayOf(rates: [Rate]) -> [Any] {
        return rates.map { (rate) -> [String: Any] in return dictionaryOf(rate: rate) }
    }

    static func arrayOf(routeHints: [RouteHint]) -> [Any] {
        return routeHints.map { (routeHint) -> [String: Any] in return dictionaryOf(routeHint: routeHint) }
    }
    
    static func arrayOf(routeHintHops: [RouteHintHop]) -> [Any] {
        return routeHintHops.map { (routeHintHop) -> [String: Any?] in return dictionaryOf(routeHintHop: routeHintHop) }
    }
    
    static func arrayOf(swapInfos: [SwapInfo]) -> [Any] {
        return swapInfos.map { (swapInfo) -> [String: Any?] in return dictionaryOf(swapInfo: swapInfo) }
    }

    static func arrayOf(reverseSwapInfos: [ReverseSwapInfo]) -> [Any] {
        return reverseSwapInfos.map { (swapInfo) -> [String: Any?] in return dictionaryOf(reverseSwapInfo: swapInfo) }
    }
    
    static func arrayOf(unspentTransactionOutputs: [UnspentTransactionOutput]) -> [Any] {
        return unspentTransactionOutputs.map { (unspentTransactionOutput) -> [String: Any] in return dictionaryOf(unspentTransactionOutput: unspentTransactionOutput) }
    }
    
    static func asEnvironmentType(envType: String) throws -> EnvironmentType {
        switch(envType) {
        case "production": return EnvironmentType.production
        case "staging": return EnvironmentType.staging
        default: throw SdkError.Generic(message: "Invalid environment type")
        }
    }

    static func asBitcoinProvider(provider: String) throws -> BuyBitcoinProvider {
        switch(provider) {
        case "moonpay": return BuyBitcoinProvider.moonpay
        default: throw SdkError.Generic(message: "Invalid Bitcoin provider")
        }
    }
    
    static func asGreenlightNodeConfig(config: [String: Any?]) -> NodeConfig? {
        let inviteCode = config["inviteCode"] as? String
        let credentialsMap = config["partnerCredentials"] as? [String: Any]
        let partnerCredentials = (credentialsMap == nil ? nil : asGreenlightCredentials(reqData: credentialsMap!))
        return NodeConfig.greenlight(config: GreenlightNodeConfig(partnerCredentials: partnerCredentials, inviteCode: inviteCode))
    }
    
    static func asNodeConfig(nodeConfig: [String: Any?]) -> NodeConfig? {
        if let innerConfig = nodeConfig["config"] as?  [String: Any],
           let configType = nodeConfig["type"] as? String {
            switch (configType) {
            case "greenlight": return asGreenlightNodeConfig(config: innerConfig)
            default: return nil
            }
        }
        return nil
    }
    
    static func asConfig(config: [String: Any?]) -> Config? {
        if let breezserver = config["breezserver"] as? String,
           let mempoolspaceUrl = config["mempoolspaceUrl"] as? String,
           let workingDir = config["workingDir"] as? String,
           let networkStr = config["network"] as? String,
           let paymentTimeoutSec = config["paymentTimeoutSec"] as? UInt32,
           let maxfeePercent = config["maxfeePercent"] as? Double {
            let defaultLspId = config["defaultLspId"] as? String
            let apiKey = config["apiKey"] as? String
            if let nodeConfigObj = config["nodeConfig"] as? [String: Any?] {
                let nodeConfig = asNodeConfig(nodeConfig: nodeConfigObj)
                if nodeConfig == nil {
                    return nil
                }
                do {
                    var network = try asNetwork(network: networkStr)
                    return Config(breezserver: breezserver, mempoolspaceUrl: mempoolspaceUrl, workingDir: workingDir, network: network, paymentTimeoutSec: paymentTimeoutSec, defaultLspId: defaultLspId, apiKey: apiKey, maxfeePercent: maxfeePercent, nodeConfig: nodeConfig!)
                } catch {}
            }
        }
        
        return nil
    }

    static func asCheckMessageRequest(reqData: [String: Any?]) -> CheckMessageRequest? {
        if let message = reqData["message"] as? String,
           let signature = reqData["signature"] as? String,
           let pubkey = reqData["pubkey"] as? String {
            return CheckMessageRequest(message: message, pubkey: pubkey, signature: signature)
        }

        return nil
    }

     static func asSignMessageRequest(reqData: [String: Any?]) -> SignMessageRequest? {
        if let message = reqData["message"] as? String {
            return SignMessageRequest(message: message)
        }

        return nil
    }
    
    static func asLnUrlAuthRequestData(reqData: [String: Any]) -> LnUrlAuthRequestData? {
        if let k1 = reqData["k1"] as? String,
           let domain = reqData["domain"] as? String,
           let url = reqData["url"] as? String {
            let action = reqData["action"] as? String
            return LnUrlAuthRequestData(k1: k1, action: action, domain: domain, url: url)
        }
        
        return nil
    }
    
    static func asLnUrlPayRequestData(reqData: [String: Any]) -> LnUrlPayRequestData? {
        if let callback = reqData["callback"] as? String,
           let minSendable = reqData["minSendable"] as? UInt64,
           let maxSendable = reqData["maxSendable"] as? UInt64,
           let metadataStr = reqData["metadataStr"] as? String,
           let commentAllowed = reqData["commentAllowed"] as? UInt16,
           let domain = reqData["domain"] as? String {
            let lnAddress = reqData["lnAddress"] as? String
            return LnUrlPayRequestData(callback: callback, minSendable: minSendable, maxSendable: maxSendable, metadataStr: metadataStr, commentAllowed: commentAllowed, domain: domain, lnAddress: lnAddress)
        }
        
        return nil
    }
    
    static func asLnUrlWithdrawRequestData(reqData: [String: Any]) -> LnUrlWithdrawRequestData? {
        if let callback = reqData["callback"] as? String,
           let k1 = reqData["k1"] as? String,
           let defaultDescription = reqData["defaultDescription"] as? String,
           let minWithdrawable = reqData["minWithdrawable"] as? UInt64,
           let maxWithdrawable = reqData["maxWithdrawable"] as? UInt64 {
            return LnUrlWithdrawRequestData(callback: callback, k1: k1, defaultDescription: defaultDescription, minWithdrawable: minWithdrawable, maxWithdrawable: maxWithdrawable)
        }
        
        return nil
    }

    static func asGreenlightCredentials(reqData: [String: Any]) -> GreenlightCredentials? {
        if let deviceKey = reqData["deviceKey"] as? [UInt8],
           let deviceCert = reqData["deviceCert"] as? [UInt8] {
            return GreenlightCredentials(deviceKey: deviceKey, deviceCert: deviceCert)
        }
        
        return nil
    }

    
    static func asPaymentTypeFilter(filter: String) throws -> PaymentTypeFilter {
        switch(filter) {
        case "sent": return PaymentTypeFilter.sent
        case "received": return PaymentTypeFilter.received
        case "all": return PaymentTypeFilter.all
        default: throw SdkError.Generic(message: "Invalid filter")
        }
    }
    
    static func asNetwork(network: String) throws -> Network {
        switch(network) {
        case "bitcoin": return Network.bitcoin
        case "regtest": return Network.regtest
        case "signet": return Network.signet
        case "testnet": return Network.testnet
        default: throw SdkError.Generic(message: "Invalid network")
        }
    }
    
    static func asOpenChannelFeeRequest(reqData: [String: Any]) -> OpenChannelFeeRequest? {
        if let amountMsat = reqData["amountMsat"] as? UInt64 {
            let expiry = reqData["expiry"] as? UInt64
            return OpenChannelFeeRequest(amountMsat: amountMsat, expiry: expiry)
        }
        
        return nil
    }

    static func asOpeningFeeParams(reqData: [String: Any]) -> OpeningFeeParams? {
        if let minMsat = reqData["minMsat"] as? UInt64,
           let proportional = reqData["proportional"] as? UInt32,
           let validUntil = reqData["validUntil"] as? String,
           let maxIdleTime = reqData["maxIdleTime"] as? UInt32,
           let maxClientToSelfDelay = reqData["maxClientToSelfDelay"] as? UInt32,
           let promise = reqData["promise"] as? String {
            return OpeningFeeParams(minMsat: minMsat, proportional: proportional, validUntil: validUntil, maxIdleTime: maxIdleTime, maxClientToSelfDelay: maxClientToSelfDelay, promise: promise)
        }
        
        return nil
    }

    static func asReverseSwapFeesRequest(reqData: [String: Any?]) -> ReverseSwapFeesRequest {
        let sendAmountSat = reqData["sendAmountSat"] as? UInt64
        return ReverseSwapFeesRequest(sendAmountSat: sendAmountSat)
    }
    
    static func asReceivePaymentRequest(reqData: [String: Any?]) -> ReceivePaymentRequest? {
        if let amountSats = reqData["amountSats"] as? UInt64,
           let description = reqData["description"] as? String
        {
            let preimage = reqData["preimage"] as? [UInt8]
            let openingFeeParamsMap = reqData["openingFeeParams"] as? [String: Any]
            let openingFeeParams = (openingFeeParamsMap == nil ? nil : asOpeningFeeParams(reqData: openingFeeParamsMap!))
            let useDescriptionHash = reqData["useDescriptionHash"] as? Bool
            let expiry = reqData["expiry"] as? UInt64
            let cltv = reqData["cltv"] as? UInt32

            return ReceivePaymentRequest(amountSats: amountSats, description: description, preimage: preimage, openingFeeParams: openingFeeParams, useDescriptionHash: useDescriptionHash, expiry: expiry, cltv: cltv)
        }
        
        return nil
    }
    
    static func asReceiveOnchainRequest(reqData: [String: Any?]) -> ReceiveOnchainRequest {
        let openingFeeParamsMap = reqData["openingFeeParams"] as? [String: Any]
        let openingFeeParams = (openingFeeParamsMap == nil ? nil : asOpeningFeeParams(reqData: openingFeeParamsMap!))
        return ReceiveOnchainRequest(openingFeeParams: openingFeeParams)
    }
    
    static func asBuyBitcoinRequest(reqData: [String: Any?]) -> BuyBitcoinRequest? {
        do {
            if let provider = reqData["provider"] as? String {
                let buyBitcoinProvider = try asBitcoinProvider(provider: provider)
                let openingFeeParamsMap = reqData["openingFeeParams"] as? [String: Any]
                let openingFeeParams = (openingFeeParamsMap == nil ? nil : asOpeningFeeParams(reqData: openingFeeParamsMap!))
                return BuyBitcoinRequest(provider: buyBitcoinProvider, openingFeeParams: openingFeeParams)
            }
        } catch {}

        return nil
    }
    
    static func dictionaryOf(backupStatus: BackupStatus) -> [String: Any?] {
        return [
            "backedUp": backupStatus.backedUp,
            "lastBackupTime": backupStatus.lastBackupTime,
        ]
    }
    
    static func dictionaryOf(aesSuccessActionDataDecrypted: AesSuccessActionDataDecrypted) -> [String: Any] {
        return [
            "type": "aes",
            "description": aesSuccessActionDataDecrypted.description,
            "plaintext": aesSuccessActionDataDecrypted.plaintext,
        ]
    }
    
    static func dictionaryOf(bitcoinAddressData: BitcoinAddressData) -> [String: Any?] {
        return [
            "address": bitcoinAddressData.address,
            "network": self.valueOf(network: bitcoinAddressData.network),
            "amountSat": bitcoinAddressData.amountSat,
            "label": bitcoinAddressData.label,
            "message": bitcoinAddressData.message,
        ]
    }

    static func dictionaryOf(checkMessageResponse: CheckMessageResponse) -> [String: Any] {
        return [
            "isValid": checkMessageResponse.isValid,
        ]
    }
    
    static func dictionaryOf(closedChannelPaymentDetails: ClosedChannelPaymentDetails) -> [String: Any] {
        return [
            "type": "closed_channel",
            "shortChannelId": closedChannelPaymentDetails.shortChannelId,
            "state": valueOf(channelState: closedChannelPaymentDetails.state),
            "fundingTxid": closedChannelPaymentDetails.fundingTxid
        ]
    }
    
    static func dictionaryOf(greenlightNodeConfig: GreenlightNodeConfig) -> [String: Any?] {
        let optionalCredentials = (greenlightNodeConfig.partnerCredentials == nil ? nil : dictionaryOf(greenlightCredentials: greenlightNodeConfig.partnerCredentials!))
        return ["partnerCredentials": optionalCredentials, "inviteCode": greenlightNodeConfig.inviteCode]
    }
    
    static func dictionaryOf(nodeConfig: NodeConfig) -> [String: Any] {
        switch(nodeConfig) {
        case let .greenlight(config):
            return ["type": "greenlight", "config": dictionaryOf(greenlightNodeConfig: config)]
        }
    }
    
    static func dictionaryOf(config: Config) -> [String: Any?] {
        return [
            "breezserver": config.breezserver,
            "mempoolspaceUrl": config.mempoolspaceUrl,
            "workingDir": config.workingDir,
            "network": valueOf(network: config.network),
            "paymentTimeoutSec": config.paymentTimeoutSec,
            "defaultLspId": config.defaultLspId,
            "apiKey": config.apiKey,
            "maxfeePercent": config.maxfeePercent,
            "nodeConfig": dictionaryOf(nodeConfig: config.nodeConfig)
        ]
    }
    
    static func dictionaryOf(currencyInfo: CurrencyInfo) -> [String: Any?] {
        return [
            "name": currencyInfo.name,
            "fractionSize": currencyInfo.fractionSize,
            "spacing": currencyInfo.spacing,
            "symbol": dictionaryOf(symbol: currencyInfo.symbol),
            "uniqSymbol": dictionaryOf(symbol: currencyInfo.uniqSymbol),
            "localizedName": arrayOf(localizedNames: currencyInfo.localizedName),
            "localeOverrides": arrayOf(localeOverrides: currencyInfo.localeOverrides)
        ]
    }
    
    static func dictionaryOf(fiatCurrency: FiatCurrency) -> [String: Any] {
        return [
            "id": fiatCurrency.id,
            "info": dictionaryOf(currencyInfo: fiatCurrency.info)
        ]
    }
    
    static func dictionaryOf(greenlightCredentials: GreenlightCredentials) -> [String: Any] {
        return [
            "deviceKey": greenlightCredentials.deviceKey,
            "deviceCert": greenlightCredentials.deviceCert
        ]
    }
    
    static func dictionaryOf(inputType: InputType) -> [String: Any?] {
        switch(inputType) {
        case let .bitcoinAddress(address):
            return ["type": "bitcoinAddress", "data": dictionaryOf(bitcoinAddressData: address)]
        case let .bolt11(invoice):
            return ["type": "bolt11", "data": dictionaryOf(lnInvoice: invoice)]
        case let .lnUrlAuth(data):
            return ["type": "lnUrlAuth", "data": dictionaryOf(lnUrlAuthRequestData: data)]
        case let .lnUrlError(data):
            return ["type": "lnUrlError", "data": dictionaryOf(lnUrlErrorData: data)]
        case let .lnUrlPay(data):
            return ["type": "lnUrlPay", "data": dictionaryOf(lnUrlPayRequestData: data)]
        case let .lnUrlWithdraw(data):
            return ["type": "lnUrlWithdraw", "data": dictionaryOf(lnUrlWithdrawRequestData: data)]
        case let .nodeId(nodeId):
            return ["type": "nodeId", "data": nodeId]
        case let .url(url):
            return ["type": "url", "data": url]
        }
    }
    
    static func dictionaryOf(invoicePaidDetails: InvoicePaidDetails) -> [String: Any?] {
        return [
            "paymentHash": invoicePaidDetails.paymentHash,
            "bolt11": invoicePaidDetails.bolt11
        ]
    }
    
    static func dictionaryOf(paymentFailedData: PaymentFailedData) -> [String: Any?] {
        return [
            "error": paymentFailedData.error,
            "bolt11": paymentFailedData.invoice == nil ? nil : dictionaryOf(lnInvoice: paymentFailedData.invoice!),
            "nodeId": paymentFailedData.nodeId
        ]
    }
    
    static func dictionaryOf(lnInvoice: LnInvoice) -> [String: Any?] {
        return [
            "bolt11": lnInvoice.bolt11,
            "payeePubkey": lnInvoice.payeePubkey,
            "paymentHash": lnInvoice.paymentHash,
            "description": lnInvoice.description,
            "descriptionHash": lnInvoice.descriptionHash,
            "amountMsat": lnInvoice.amountMsat,
            "timestamp": lnInvoice.timestamp,
            "expiry": lnInvoice.expiry,
            "routingHints": self.arrayOf(routeHints: lnInvoice.routingHints),
            "paymentSecret": lnInvoice.paymentSecret
        ]
    }
    
    static func dictionaryOf(lnPaymentDetails: LnPaymentDetails) -> [String: Any?] {
        return [
            "type": "ln",
            "paymentHash": lnPaymentDetails.paymentHash,
            "label": lnPaymentDetails.label,
            "destinationPubkey": lnPaymentDetails.destinationPubkey,
            "paymentPreimage": lnPaymentDetails.paymentPreimage,
            "keysend": lnPaymentDetails.keysend,
            "bolt11": lnPaymentDetails.bolt11,
            "lnurlSuccessAction": dictionaryOf(successActionProcessed: lnPaymentDetails.lnurlSuccessAction),
            "lnurlMetadata": lnPaymentDetails.lnurlMetadata,
            "lnAddress": lnPaymentDetails.lnAddress
        ]
    }
    
    static func dictionaryOf(lnUrlAuthRequestData: LnUrlAuthRequestData) -> [String: Any?] {
        return [
            "k1": lnUrlAuthRequestData.k1,
            "action": lnUrlAuthRequestData.action,
            "domain": lnUrlAuthRequestData.domain,
            "url": lnUrlAuthRequestData.url
        ]
    }
    
    static func dictionaryOf(lnUrlErrorData: LnUrlErrorData) -> [String: Any] {
        return ["reason": lnUrlErrorData.reason]
    }
    
    static func dictionaryOf(lnUrlPayRequestData: LnUrlPayRequestData) -> [String: Any?] {
        return [
            "callback": lnUrlPayRequestData.callback,
            "minSendable": lnUrlPayRequestData.minSendable,
            "maxSendable": lnUrlPayRequestData.maxSendable,
            "metadataStr": lnUrlPayRequestData.metadataStr,
            "commentAllowed": lnUrlPayRequestData.commentAllowed,
            "domain": lnUrlPayRequestData.domain,
            "lnAddress": lnUrlPayRequestData.lnAddress
        ]
    }
    
    static func dictionaryOf(lnUrlCallbackStatus: LnUrlCallbackStatus) -> [String: Any] {
        switch(lnUrlCallbackStatus) {
        case .ok:
            return ["status": "ok"]
        case let .errorStatus(data):
            var response: [String: Any] = ["status": "error"]
            response.merge(dictionaryOf(lnUrlErrorData: data)) {(_,new) in new}
            return response
        }
    }
    
    static func dictionaryOf(lnUrlPayResult: LnUrlPayResult) -> [String: Any?] {
        switch(lnUrlPayResult) {
        case let .endpointSuccess(data):
            return [
                "type": "endpointSuccess",
                "data": dictionaryOf(successActionProcessed: data)
            ]
        case let .endpointError(data):
            return [
                "type": "endpointError",
                "data": dictionaryOf(lnUrlErrorData: data)
            ]
        }
    }
    
    static func dictionaryOf(lnUrlWithdrawRequestData: LnUrlWithdrawRequestData) -> [String: Any] {
        return [
            "callback": lnUrlWithdrawRequestData.callback,
            "k1": lnUrlWithdrawRequestData.k1,
            "defaultDescription": lnUrlWithdrawRequestData.defaultDescription,
            "minWithdrawable": lnUrlWithdrawRequestData.minWithdrawable,
            "maxWithdrawable": lnUrlWithdrawRequestData.maxWithdrawable,
        ]
    }
    
    static func dictionaryOf(localeOverride: LocaleOverrides) -> [String: Any?] {
        return [
            "locale": localeOverride.locale,
            "spacing": localeOverride.spacing,
            "symbol": dictionaryOf(symbol: localeOverride.symbol)
        ]
    }
    
    static func dictionaryOf(localizedName: LocalizedName) -> [String: Any] {
        return [
            "locale": localizedName.locale,
            "name": localizedName.name
        ]
    }
    
    static func dictionaryOf(lspInformation: LspInformation) -> [String: Any?] {
        return [
            "id": lspInformation.id,
            "name": lspInformation.name,
            "widgetUrl": lspInformation.widgetUrl,
            "pubkey": lspInformation.pubkey,
            "host": lspInformation.host,
            "channelCapacity": lspInformation.channelCapacity,
            "targetConf": lspInformation.targetConf,
            "baseFeeMsat": lspInformation.baseFeeMsat,
            "feeRate": lspInformation.feeRate,
            "timeLockDelta": lspInformation.timeLockDelta,
            "minHtlcMsat": lspInformation.minHtlcMsat,
            "lspPubkey": lspInformation.lspPubkey,
            "openingFeeParamsList": dictionaryOf(openingFeeParamsMenu: lspInformation.openingFeeParamsList)
        ]
    }

    static func dictionaryOf(openChannelFeeResponse: OpenChannelFeeResponse) -> [String: Any] {
        return [
            "feeMsat": openChannelFeeResponse.feeMsat,
            "usedFeeParams": dictionaryOf(openingFeeParams: openChannelFeeResponse.usedFeeParams)
        ]
    }

    static func dictionaryOf(openingFeeParams: OpeningFeeParams?) -> [String: Any]? {
        if openingFeeParams != nil {
            return [
                "minMsat": openingFeeParams!.minMsat,
                "proportional": openingFeeParams!.proportional,
                "validUntil": openingFeeParams!.validUntil,
                "maxIdleTime": openingFeeParams!.maxIdleTime,
                "maxClientToSelfDelay": openingFeeParams!.maxClientToSelfDelay,
                "promise": openingFeeParams!.promise
            ]
        }

        return nil
    }

    static func dictionaryOf(openingFeeParamsMenu: OpeningFeeParamsMenu) -> [String: Any] {
        return [
            "values": arrayOf(openingFeeParamsValues: openingFeeParamsMenu.values)
        ]
    }
    
    static func dictionaryOf(messageSuccessActionData: MessageSuccessActionData) -> [String: Any] {
        return [
            "type": "message",
            "message": messageSuccessActionData.message
        ]
    }

    static func dictionaryOf(receivePaymentResponse: ReceivePaymentResponse) -> [String: Any?] {
        return [
            "lnInvoice": dictionaryOf(lnInvoice: receivePaymentResponse.lnInvoice),
            "openingFeeParams": dictionaryOf(openingFeeParams: receivePaymentResponse.openingFeeParams),
            "openingFeeMsat": receivePaymentResponse.openingFeeMsat
        ]
    }

    static func dictionaryOf(buyBitcoinResponse: BuyBitcoinResponse) -> [String: Any?] {
        return [
            "url": buyBitcoinResponse.url,
            "openingFeeParams": dictionaryOf(openingFeeParams: buyBitcoinResponse.openingFeeParams)
        ]
    }

    static func dictionaryOf(nodeState: NodeState) -> [String: Any] {
        return [
            "id": nodeState.id,
            "blockHeight": nodeState.blockHeight,
            "channelsBalanceMsat": nodeState.channelsBalanceMsat,
            "onchainBalanceMsat": nodeState.onchainBalanceMsat,
            "utxos": arrayOf(unspentTransactionOutputs: nodeState.utxos),
            "maxPayableMsat": nodeState.maxPayableMsat,
            "maxReceivableMsat": nodeState.maxReceivableMsat,
            "maxSinglePaymentAmountMsat": nodeState.maxSinglePaymentAmountMsat,
            "maxChanReserveMsats": nodeState.maxChanReserveMsats,
            "connectedPeers": nodeState.connectedPeers,
            "inboundLiquidityMsats": nodeState.inboundLiquidityMsats
        ]
    }
    
    static func dictionaryOf(payment: Payment) -> [String: Any?] {
        return [
            "id": payment.id,
            "paymentType": payment.paymentType,
            "paymentTime": payment.paymentTime,
            "amountMsat": payment.amountMsat,
            "feeMsat": payment.feeMsat,
            "pending": payment.pending,
            "description": payment.description,
            "details": dictionaryOf(paymentDetails: payment.details),
        ]
    }

    static func dictionaryOf(backupFailedData: BackupFailedData) -> [String: Any?] {
        return [
            "error": backupFailedData.error
        ]
    }
    
    static func dictionaryOf(paymentDetails: PaymentDetails) -> [String: Any?] {
        switch(paymentDetails) {
        case let .closedChannel(data):
            return dictionaryOf(closedChannelPaymentDetails: data)
        case let .ln(data):
            return dictionaryOf(lnPaymentDetails: data)
        }
    }
    
    static func dictionaryOf(rate: Rate) -> [String: Any] {
        return [
            "coin": rate.coin,
            "value": rate.value
        ]
    }
    
    static func dictionaryOf(recommendedFees: RecommendedFees) -> [String: Any] {
        return [
            "fastestFee": recommendedFees.fastestFee,
            "halfHourFee": recommendedFees.halfHourFee,
            "hourFee": recommendedFees.hourFee,
            "economyFee": recommendedFees.economyFee,
            "minimumFee": recommendedFees.minimumFee
        ]
    }
    
    static func dictionaryOf(routeHint: RouteHint) -> [String: Any] {
        return ["hops": self.arrayOf(routeHintHops: routeHint.hops)]
    }
    
    static func dictionaryOf(routeHintHop: RouteHintHop) -> [String: Any?] {
        return [
            "srcNodeId": routeHintHop.srcNodeId,
            "shortChannelId": routeHintHop.shortChannelId,
            "feesBaseMsat": routeHintHop.feesBaseMsat,
            "feesProportionalMillionths": routeHintHop.feesProportionalMillionths,
            "cltvExpiryDelta": routeHintHop.cltvExpiryDelta,
            "htlcMinimumMsat": routeHintHop.htlcMinimumMsat,
            "htlcMaximumMsat": routeHintHop.htlcMaximumMsat
        ]
    }

    static func dictionaryOf(signMessageResponse: SignMessageResponse) -> [String: Any] {
        return [
            "signature": signMessageResponse.signature,
        ]
    }
    
    static func dictionaryOf(successActionProcessed: SuccessActionProcessed?) -> [String: Any]? {
        switch(successActionProcessed) {
        case let .aes(data):
            return dictionaryOf(aesSuccessActionDataDecrypted: data)
        case let .message(data):
            return dictionaryOf(messageSuccessActionData: data)
        case let .url(data):
            return dictionaryOf(urlSuccessActionData: data)
        case .none:
            return nil
        }
    }
    
    static func dictionaryOf(symbol: Symbol?) -> [String: Any?]? {
        if symbol != nil {
            return [
                "grapheme": symbol?.grapheme,
                "template": symbol?.template,
                "rtl": symbol?.rtl,
                "position": symbol?.position
            ]
        }
        
        return nil
    }
    
    static func dictionaryOf(swapInfo: SwapInfo) -> [String: Any?] {
        return [
            "bitcoinAddress": swapInfo.bitcoinAddress,
            "createdAt": swapInfo.createdAt,
            "lockHeight": swapInfo.lockHeight,
            "paymentHash": swapInfo.paymentHash,
            "preimage": swapInfo.preimage,
            "privateKey": swapInfo.privateKey,
            "publicKey": swapInfo.publicKey,
            "swapperPublicKey": swapInfo.swapperPublicKey,
            "script": swapInfo.script,
            "bolt11": swapInfo.bolt11,
            "paidSats": swapInfo.paidSats,
            "unconfirmedSats": swapInfo.unconfirmedSats,
            "confirmedSats": swapInfo.confirmedSats,
            "status": valueOf(swapStatus: swapInfo.status),
            "refundTxIds": swapInfo.refundTxIds,
            "unconfirmedTxIds": swapInfo.unconfirmedTxIds,
            "confirmedTxIds": swapInfo.confirmedTxIds,
            "minAllowedDeposit": swapInfo.minAllowedDeposit,
            "maxAllowedDeposit": swapInfo.maxAllowedDeposit,
            "lastRedeemError": swapInfo.lastRedeemError,
            "channelOpeningFees": dictionaryOf(openingFeeParams: swapInfo.channelOpeningFees)
        ]
    }

    static func dictionaryOf(reverseSwapPairInfo: ReverseSwapPairInfo) -> [String: Any] {
        return [
            "min": reverseSwapPairInfo.min,
            "max": reverseSwapPairInfo.max,
            "feesHash": reverseSwapPairInfo.feesHash,
            "feesPercentage": reverseSwapPairInfo.feesPercentage,
            "feesLockup": reverseSwapPairInfo.feesLockup,
            "feesClaim": reverseSwapPairInfo.feesClaim,
            "totalEstimatedFees": reverseSwapPairInfo.totalEstimatedFees
        ]
    }

    static func dictionaryOf(reverseSwapInfo: ReverseSwapInfo) -> [String: Any] {
        return [
            "id": reverseSwapInfo.id,
            "claimPubkey": reverseSwapInfo.claimPubkey,
            "onchainAmountSat": reverseSwapInfo.onchainAmountSat,
            "status": valueOf(reverseSwapStatus: reverseSwapInfo.status)
        ]
    }
    
    static func dictionaryOf(unspentTransactionOutput: UnspentTransactionOutput) -> [String: Any] {
        return [
            "txid": unspentTransactionOutput.txid,
            "outnum": unspentTransactionOutput.outnum,
            "amountMillisatoshi": unspentTransactionOutput.amountMillisatoshi,
            "address": unspentTransactionOutput.address,
            "reserved": unspentTransactionOutput.reserved,
            "reservedToBlock": unspentTransactionOutput.reservedToBlock,
        ]
    }
    
    static func dictionaryOf(urlSuccessActionData: UrlSuccessActionData) -> [String: Any] {
        return [
            "type": "url",
            "description": urlSuccessActionData.description,
            "url": urlSuccessActionData.url,
        ]
    }
    
    static func valueOf(channelState: ChannelState) -> String {
        switch(channelState) {
        case .pendingOpen: return "pendingOpen"
        case .opened: return "opened"
        case .pendingClose: return "pendingClose"
        case .closed: return "closed"
        }
    }
    
    static func valueOf(network: Network) -> String {
        switch(network) {
        case .bitcoin: return "bitcoin"
        case .regtest: return "regtest"
        case .signet: return "signet"
        case .testnet: return "testnet"
        }
    }
    
    static func valueOf(swapStatus: SwapStatus) -> String {
        switch(swapStatus) {
        case .initial: return "initial"
        case .expired: return "expired"
        }
    }

    static func valueOf(reverseSwapStatus: ReverseSwapStatus) -> String {
        switch(reverseSwapStatus) {
        case .initial: return "initial"
        case .inProgress: return "in_progress"
        case .cancelled: return "cancelled"
        case .completedSeen: return "completed_seen"
        case .completedConfirmed: return "completed_confirmed"
        }
    }
}
