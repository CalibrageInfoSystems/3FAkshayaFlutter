import 'dart:convert';

PassbookVendorModel passbookVendorModelFromJson(String str) =>
    PassbookVendorModel.fromJson(json.decode(str));

String passbookVendorModelToJson(PassbookVendorModel data) =>
    json.encode(data.toJson());

class PassbookVendorModel {
  final Result? result;
  final bool? isSuccess;
  final int? affectedRecords;
  final String? endUserMessage;
  final List<dynamic>? validationErrors;
  final dynamic exception;

  PassbookVendorModel({
    this.result,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  factory PassbookVendorModel.fromJson(Map<String, dynamic> json) =>
      PassbookVendorModel(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
        isSuccess: json["isSuccess"],
        affectedRecords: json["affectedRecords"],
        endUserMessage: json["endUserMessage"],
        validationErrors: json["validationErrors"] == null
            ? []
            : List<dynamic>.from(json["validationErrors"]!.map((x) => x)),
        exception: json["exception"],
      );

  Map<String, dynamic> toJson() => {
        "result": result?.toJson(),
        "isSuccess": isSuccess,
        "affectedRecords": affectedRecords,
        "endUserMessage": endUserMessage,
        "validationErrors": validationErrors == null
            ? []
            : List<dynamic>.from(validationErrors!.map((x) => x)),
        "exception": exception,
      };
}

class Result {
  final double? totalQuanitity;
  final double? totalGrAmount;
  final double? totalAdjusted;
  final double? totalAmount;
  final double? totalBalance;
  final List<PaymentResponce>? paymentResponce;

  Result({
    this.totalQuanitity,
    this.totalGrAmount,
    this.totalAdjusted,
    this.totalAmount,
    this.totalBalance,
    this.paymentResponce,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        totalQuanitity: json["totalQuanitity"]?.toDouble(),
        totalGrAmount: json["totalGRAmount"]?.toDouble(),
        totalAdjusted: json["totalAdjusted"]?.toDouble(),
        totalAmount: json["totalAmount"]?.toDouble(),
        totalBalance: json["totalBalance"]?.toDouble(),
        paymentResponce: json["paymentResponce"] == null
            ? []
            : List<PaymentResponce>.from(json["paymentResponce"]!
                .map((x) => PaymentResponce.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalQuanitity": totalQuanitity,
        "totalGRAmount": totalGrAmount,
        "totalAdjusted": totalAdjusted,
        "totalAmount": totalAmount,
        "totalBalance": totalBalance,
        "paymentResponce": paymentResponce == null
            ? []
            : List<dynamic>.from(paymentResponce!.map((x) => x.toJson())),
      };
}

class PaymentResponce {
  final String? cardCode;
  final String? cardName;
  final String? uVillage;
  final String? uMandal;
  final String? uFHname;
  final String? bankName;
  final String? bankAccount;
  final String? branch;
  final DateTime? refDate;
  final double? quantity;
  final String? memo;
  final double? obAmount;
  final double? amount;
  final double? adhocRate;
  final double? invoiceRate;
  final double? ob;
  final double? cb;
  final double? gRAmount;
  final double? adjusted;
  final double? balance;

  PaymentResponce({
    this.cardCode,
    this.cardName,
    this.uVillage,
    this.uMandal,
    this.uFHname,
    this.bankName,
    this.bankAccount,
    this.branch,
    this.refDate,
    this.quantity,
    this.memo,
    this.obAmount,
    this.amount,
    this.adhocRate,
    this.invoiceRate,
    this.ob,
    this.cb,
    this.gRAmount,
    this.adjusted,
    this.balance,
  });

  factory PaymentResponce.fromJson(Map<String, dynamic> json) =>
      PaymentResponce(
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        uVillage: json["u_village"],
        uMandal: json["u_mandal"],
        uFHname: json["u_FHname"],
        bankName: json["bankName"],
        bankAccount: json["bank_Account"],
        branch: json["branch"],
        refDate:
            json["refDate"] == null ? null : DateTime.parse(json["refDate"]),
        quantity: json["quantity"]?.toDouble(),
        memo: json["memo"],
        obAmount: json["obAmount"]?.toDouble(),
        amount: json["amount"]?.toDouble(),
        adhocRate: json["adhoc_Rate"]?.toDouble(),
        invoiceRate: json["invoice_Rate"]?.toDouble(),
        ob: json["ob"]?.toDouble(),
        cb: json["cb"]?.toDouble(),
        gRAmount: json["gR_Amount"]?.toDouble(),
        adjusted: json["adjusted"]?.toDouble(),
        balance: json["balance"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "cardCode": cardCode,
        "cardName": cardName,
        "u_village": uVillage,
        "u_mandal": uMandal,
        "u_FHname": uFHname,
        "bankName": bankName,
        "bank_Account": bankAccount,
        "branch": branch,
        "refDate": refDate?.toIso8601String(),
        "quantity": quantity,
        "memo": memo,
        "obAmount": obAmount,
        "amount": amount,
        "adhoc_Rate": adhocRate,
        "invoice_Rate": invoiceRate,
        "ob": ob,
        "cb": cb,
        "gR_Amount": gRAmount,
        "adjusted": adjusted,
        "balance": balance,
      };
}
