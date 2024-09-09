class Popup {
  int serviceTypeId;
  double c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30;

  Popup({
    required this.serviceTypeId,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
    required this.c5,
    required this.c6,
    required this.c7,
    required this.c8,
    required this.c9,
    required this.c10,
    required this.c11,
    required this.c12,
    required this.c13,
    required this.c14,
    required this.c15,
    required this.c16,
    required this.c17,
    required this.c18,
    required this.c19,
    required this.c20,
    required this.c21,
    required this.c22,
    required this.c23,
    required this.c24,
    required this.c25,
    required this.c26,
    required this.c27,
    required this.c28,
    required this.c29,
    required this.c30,
  });

  factory Popup.fromJson(Map<String, dynamic> json) {
    return Popup(
      serviceTypeId: json['serviceTypeId'],
      c1: json['c1'],
      c2: json['c2'],
      c3: json['c3'],
      c4: json['c4'],
      c5: json['c5'],
      c6: json['c6'],
      c7: json['c7'],
      c8: json['c8'],
      c9: json['c9'],
      c10: json['c10'],
      c11: json['c11'],
      c12: json['c12'],
      c13: json['c13'],
      c14: json['c14'],
      c15: json['c15'],
      c16: json['c16'],
      c17: json['c17'],
      c18: json['c18'],
      c19: json['c19'],
      c20: json['c20'],
      c21: json['c21'],
      c22: json['c22'],
      c23: json['c23'],
      c24: json['c24'],
      c25: json['c25'],
      c26: json['c26'],
      c27: json['c27'],
      c28: json['c28'],
      c29: json['c29'],
      c30: json['c30'],
    );
  }
}


//
// class Popup {
//   final int serviceTypeId;
//   final String desc;
//   final Map<String, dynamic> costValues;
//
//   Popup({
//     required this.serviceTypeId,
//     required this.desc,
//     required this.costValues,
//   });
//
//   factory Popup.fromJson(Map<String, dynamic> json) {
//     // Extract all c1 to c30 values into a separate map
//     Map<String, dynamic> costValues = {};
//     for (int i = 1; i <= 30; i++) {
//       String key = 'c$i';
//       costValues[key] = json[key] ?? 0.0;
//     }
//
//     return Popup(
//       serviceTypeId: json['serviceTypeId'],
//       desc: json['desc'],
//       costValues: costValues,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'serviceTypeId': serviceTypeId,
//       'desc': desc,
//       ...costValues, // Include all c1 to c30 values
//     };
//   }
// }


// class Popup {
//   int serviceTypeId;
//   String desc;
//   List<double> costs;
//
//   Popup({
//     required this.serviceTypeId,
//     required this.desc,
//     required this.costs,
//   });
//   // factory Popup.fromJson(Map<String, dynamic> json) {
//   //   List<double> costs = [];
//   //   for (int i = 1; i <= 30; i++) {
//   //     costs.add(json['c$i']?.toDouble() ?? 0.0);
//   //   }
//   //   return Popup(
//   //     desc: json['desc'],
//   //     costs: costs, serviceTypeId: json['serviceTypeId'],
//   //   );
//   // }
//
//   factory Popup.fromJson(Map<String, dynamic> json) {
//     final costs = <double>[];
//     for (int i = 1; i <= 30; i++) {
//       costs.add((json['c$i'] as num).toDouble());
//     }
//
//     return Popup(
//       serviceTypeId: json['serviceTypeId'],
//       desc: json['desc'],
//       costs: costs,
//     );
//   }
//   // factory Popup.fromJson(Map<String, dynamic> json) {
//   //   return Popup(
//   //     serviceTypeId: json['serviceTypeId'],
//   //     desc: json['desc'],
//   //     costs: List<double>.from([
//   //       json['c1'],
//   //       json['c2'],
//   //       json['c3'],
//   //       json['c4'],
//   //       json['c5'],
//   //       json['c6'],
//   //       json['c7'],
//   //       json['c8'],
//   //       json['c9'],
//   //       json['c10'],
//   //       json['c11'],
//   //       json['c12'],
//   //       json['c13'],
//   //       json['c14'],
//   //       json['c15'],
//   //       json['c16'],
//   //       json['c17'],
//   //       json['c18'],
//   //       json['c19'],
//   //       json['c20'],
//   //       json['c21'],
//   //       json['c22'],
//   //       json['c23'],
//   //       json['c24'],
//   //       json['c25'],
//   //       json['c26'],
//   //       json['c27'],
//   //       json['c28'],
//   //       json['c29'],
//   //       json['c30'],
//   //     ]),
//   //   );
//   // }
// }
//
// class ApiResponse {
//   List<Popup> listResult;
//   bool isSuccess;
//   int affectedRecords;
//   String endUserMessage;
//   List<dynamic> validationErrors;
//   dynamic exception;
//
//   ApiResponse({
//     required this.listResult,
//     required this.isSuccess,
//     required this.affectedRecords,
//     required this.endUserMessage,
//     required this.validationErrors,
//     this.exception,
//   });
//
//   factory ApiResponse.fromJson(Map<String, dynamic> json) {
//     return ApiResponse(
//       listResult: List<Popup>.from(
//         json['listResult'].map((data) => Popup.fromJson(data)),
//       ),
//       isSuccess: json['isSuccess'],
//       affectedRecords: json['affectedRecords'],
//       endUserMessage: json['endUserMessage'],
//       validationErrors: List<dynamic>.from(json['validationErrors']),
//       exception: json['exception'],
//     );
//   }
// }
