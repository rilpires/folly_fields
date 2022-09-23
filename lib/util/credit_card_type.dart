// ignore_for_file: always_specify_types

import 'package:flutter/foundation.dart';

///
///
/// https://github.com/braintree/credit-card-type/blob/main/src/lib/card-types.ts
///
enum CreditCardType {
  /// Visa
  visa(
    name: 'Visa',
    mask: '#### #### #### #### ###',
    lengths: [16, 18, 19],
    code: CreditCardCode('CVV', [3]),
    patterns: {
      Range(4),
    },
  ),

  /// Mastercard
  mastercard(
    name: 'Mastercard',
    mask: '#### #### #### ####',
    lengths: [16],
    code: CreditCardCode('CVC', [3]),
    patterns: {
      Range(51, 55),
      Range(2221, 2229),
      Range(223, 229),
      Range(23, 26),
      Range(270, 271),
      Range(2720),
    },
  ),

  /// American Express
  amex(
    name: 'American Express',
    mask: '#### ###### #####',
    lengths: [15],
    code: CreditCardCode('CID', [4]),
    patterns: {
      Range(34),
      Range(37),
    },
  ),

  /// Diners Club
  dinersclub(
    name: 'Diners Club',
    mask: '#### ###### #########',
    lengths: [14, 16, 19],
    code: CreditCardCode('CVV', [3]),
    patterns: {
      Range(300, 305),
      Range(36),
      Range(38),
      Range(39),
    },
  ),

  /// Discover
  discover(
    name: 'Discover',
    mask: '#### #### #### #### ###',
    lengths: [16, 19],
    code: CreditCardCode('CID', [3]),
    patterns: {
      Range(6011),
      Range(644, 649),
      Range(65),
    },
  ),

  /// JCB
  jcb(
    name: 'JCB',
    mask: '#### #### #### #### ###',
    lengths: [16, 17, 18, 19],
    code: CreditCardCode('CVV', [3]),
    patterns: {
      Range(2131),
      Range(1800),
      Range(3528, 3589),
    },
  ),

  /// UnionPay
  unionpay(
    name: 'UnionPay',
    mask: '#### #### #### #### ###',
    lengths: [14, 15, 16, 17, 18, 19],
    code: CreditCardCode('CVN', [3]),
    patterns: {
      Range(620),
      Range(62100, 62182),
      Range(62184, 62187),
      Range(62185, 62197),
      Range(62200, 62205),
      Range(622010, 622999),
      Range(622018),
      Range(62207, 62209),
      Range(623, 626),
      Range(6270),
      Range(6272),
      Range(6276),
      Range(627700, 627779),
      Range(627781, 627799),
      Range(6282, 6289),
      Range(6291),
      Range(6292),
      Range(810),
      Range(8110, 8131),
      Range(8132, 8151),
      Range(8152, 8163),
      Range(8164, 8171),
    },
    checkLuhn: false,
  ),

  /// Maestro
  maestro(
    name: 'Maestro',
    mask: '#### #### #### #### ###',
    lengths: [12, 13, 14, 15, 16, 17, 18, 19],
    code: CreditCardCode('CVC', [3]),
    patterns: {
      Range(493698),
      Range(500000, 504174),
      Range(504176, 506698),
      Range(506779, 508999),
      Range(56, 59),
      Range(63),
      Range(67),
      Range(6),
    },
  ),

  /// Elo
  elo(
    name: 'Elo',
    mask: '#### #### #### ####',
    lengths: [16],
    code: CreditCardCode('CVE', [3]),
    patterns: {
      Range(401178),
      Range(401179),
      Range(438935),
      Range(457631),
      Range(457632),
      Range(431274),
      Range(451416),
      Range(457393),
      Range(504175),
      Range(506699, 506778),
      Range(509000, 509999),
      Range(627780),
      Range(636297),
      Range(636368),
      Range(650031, 650033),
      Range(650035, 650051),
      Range(650405, 650439),
      Range(650485, 650538),
      Range(650541, 650598),
      Range(650700, 650718),
      Range(650720, 650727),
      Range(650901, 650978),
      Range(651652, 651679),
      Range(655000, 655019),
      Range(655021, 655058),
    },
  ),

  /// Mir
  mir(
    name: 'Mir',
    mask: '#### #### #### #### ###',
    lengths: [16, 17, 18, 19],
    code: CreditCardCode('CVP2', [3]),
    patterns: {
      Range(2200, 2204),
    },
  ),

  /// Hiper
  hiper(
    name: 'Hiper',
    mask: '#### #### #### ####',
    lengths: [16],
    code: CreditCardCode('CVC', [3]),
    patterns: {
      Range(637095),
      Range(63737423),
      Range(63743358),
      Range(637568),
      Range(637599),
      Range(637609),
      Range(637612),
    },
  ),

  /// Hipercard
  hipercard(
    name: 'Hipercard',
    mask: '#### #### #### ####',
    lengths: [16],
    code: CreditCardCode('CVC', [3]),
    patterns: {
      Range(606282),
    },
  ),

  /// Unknown
  unknown(
    name: 'Unknown',
    mask: '#### #### #### #### ###',
    lengths: [12, 13, 14, 15, 16, 17, 18, 19],
    code: CreditCardCode('CVV', [3, 4]),
    patterns: {},
    checkLuhn: true,
  );

  ///
  ///
  ///
  final String name;
  final String mask;
  final List<int> lengths;
  final CreditCardCode code;
  final Set<Range> patterns;
  final bool checkLuhn;

  ///
  ///
  ///
  const CreditCardType({
    required this.name,
    required this.mask,
    required this.lengths,
    required this.code,
    required this.patterns,
    this.checkLuhn = true,
  });

  ///
  ///
  ///
  bool validLength(String ccNum) => lengths.contains(clearNum(ccNum).length);

  ///
  ///
  ///
  bool validNumber(String ccNum) {
    if (!checkLuhn) {
      return true;
    }

    if (ccNum.length < 2) {
      return false;
    }

    ccNum = ccNum.replaceAll(RegExp(r'\D'), '');

    int len = ccNum.length;
    int p = len % 2;
    int sum = 0;

    try {
      for (int i = ccNum.length - 1; i >= 0; i--) {
        int d = int.parse(ccNum[i]);

        if (i % 2 == p) {
          d *= 2;
          if (d > 9) {
            d -= 9;
          }
        }

        sum += d;
      }

      return sum % 10 == 0;
    } on Exception catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
      return false;
    }
  }

  ///
  ///
  ///
  bool cvvCheck(String cvv) =>
      code.size.contains(cvv.length) &&
      code.size.contains(clearNum(cvv).length);

  ///
  ///
  ///
  static String clearNum(String ccNum) => ccNum.replaceAll(RegExp(r'\D'), '');

  ///
  ///
  ///
  static CreditCardType detectType(String ccNum) {
    ccNum = clearNum(ccNum);

    for (CreditCardType type in CreditCardType.values) {
      for (Range range in type.patterns) {
        if (range.isValid(ccNum)) {
          return type;
        }
      }
    }

    return CreditCardType.unknown;
  }
}

///
///
///
class CreditCardCode {
  final String name;
  final List<int> size;

  ///
  ///
  ///
  const CreditCardCode(this.name, this.size);
}

///
///
///
class Range {
  final int initialValue;
  final int? finalValue;

  const Range(this.initialValue, [this.finalValue]);

  ///
  ///
  ///
  bool isValid(String ccNum) {
    int qtd = initialValue.toString().length;

    if (ccNum.length < qtd) {
      return false;
    }

    int? ccInt = int.tryParse(ccNum.substring(0, qtd));

    if (ccInt == null) {
      return false;
    }

    if (finalValue == null) {
      return ccInt == initialValue;
    } else {
      return ccInt >= initialValue && ccInt <= finalValue!;
    }
  }
}
