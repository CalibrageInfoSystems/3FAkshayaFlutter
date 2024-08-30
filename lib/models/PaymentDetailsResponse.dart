class PaymentDetailsResponse {
  final double totalQuantity;
  final double totalGRAmount;
  final double totalAdjusted;
  final double totalAmount;
  final double totalBalance;
  final List<PaymentResponse> paymentResponce;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;

  PaymentDetailsResponse({
    required this.totalQuantity,
    required this.totalGRAmount,
    required this.totalAdjusted,
    required this.totalAmount,
    required this.totalBalance,
    required this.paymentResponce,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.validationErrors,
    this.exception,
  });

  factory PaymentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsResponse(
      totalQuantity: json['totalQuanitity'] as double,
      totalGRAmount: json['totalGRAmount'] as double,
      totalAdjusted: json['totalAdjusted'] as double,
      totalAmount: json['totalAmount'] as double,
      totalBalance: json['totalBalance'] as double,
      paymentResponce: (json['paymentResponce'] as List)
          .map((i) => PaymentResponse.fromJson(i))
          .toList(),
      isSuccess: json['isSuccess'] as bool,
      affectedRecords: json['affectedRecords'] as int,
      endUserMessage: json['endUserMessage'] as String,
      validationErrors: json['validationErrors'] as List<dynamic>,
      exception: json['exception'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuanitity': totalQuantity,
      'totalGRAmount': totalGRAmount,
      'totalAdjusted': totalAdjusted,
      'totalAmount': totalAmount,
      'totalBalance': totalBalance,
      'paymentResponce': paymentResponce.map((i) => i.toJson()).toList(),
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}

class PaymentResponse {
  final String cardCode;
  final String cardName;
  final String village;
  final String mandal;
  final String fhName;
  final String bankName;
  final String bankAccount;
  final String branch;
  final DateTime refDate;
  final double quantity;
  final String memo;
  final double obAmount;
  final double amount;
  final double adhocRate;
  final double invoiceRate;
  final double ob;
  final double cb;
  final double grAmount;
  final double adjusted;
  final double balance;

  PaymentResponse({
    required this.cardCode,
    required this.cardName,
    required this.village,
    required this.mandal,
    required this.fhName,
    required this.bankName,
    required this.bankAccount,
    required this.branch,
    required this.refDate,
    required this.quantity,
    required this.memo,
    required this.obAmount,
    required this.amount,
    required this.adhocRate,
    required this.invoiceRate,
    required this.ob,
    required this.cb,
    required this.grAmount,
    required this.adjusted,
    required this.balance,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      cardCode: json['cardCode'] as String,
      cardName: json['cardName'] as String,
      village: json['u_village'] as String,
      mandal: json['u_mandal'] as String,
      fhName: json['u_FHname'] as String,
      bankName: json['bankName'] as String,
      bankAccount: json['bank_Account'] as String,
      branch: json['branch'] as String,
      refDate: DateTime.parse(json['refDate'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      memo: json['memo'] as String,
      obAmount: (json['obAmount'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      adhocRate: (json['adhoc_Rate'] as num).toDouble(),
      invoiceRate: (json['invoice_Rate'] as num).toDouble(),
      ob: (json['ob'] as num).toDouble(),
      cb: (json['cb'] as num).toDouble(),
      grAmount: (json['gR_Amount'] as num).toDouble(),
      adjusted: (json['adjusted'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardCode': cardCode,
      'cardName': cardName,
      'u_village': village,
      'u_mandal': mandal,
      'u_FHname': fhName,
      'bankName': bankName,
      'bank_Account': bankAccount,
      'branch': branch,
      'refDate': refDate.toIso8601String(),
      'quantity': quantity,
      'memo': memo,
      'obAmount': obAmount,
      'amount': amount,
      'adhoc_Rate': adhocRate,
      'invoice_Rate': invoiceRate,
      'ob': ob,
      'cb': cb,
      'gR_Amount': grAmount,
      'adjusted': adjusted,
      'balance': balance,
    };
  }
}
