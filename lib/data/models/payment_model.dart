// ============================================================
// payment_model.dart
// Model untuk Core API Midtrans (VA, QRIS, GoPay/ShopeePay)
// Letakkan di: lib/data/models/payment_model.dart
// ============================================================

// ── Enum metode pembayaran ─────────────────────────────────
enum PaymentMethodType {
  bcaVa,
  bniVa,
  briVa,
  mandiriVa,
  qris,
  gopay,
  shopeepay,
}

extension PaymentMethodTypeExt on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.bcaVa:     return 'BCA Virtual Account';
      case PaymentMethodType.bniVa:     return 'BNI Virtual Account';
      case PaymentMethodType.briVa:     return 'BRI Virtual Account';
      case PaymentMethodType.mandiriVa: return 'Mandiri Virtual Account';
      case PaymentMethodType.qris:      return 'QRIS';
      case PaymentMethodType.gopay:     return 'GoPay';
      case PaymentMethodType.shopeepay: return 'ShopeePay';
    }
  }

  String get paymentType {
    switch (this) {
      case PaymentMethodType.bcaVa:
      case PaymentMethodType.bniVa:
      case PaymentMethodType.briVa:
      case PaymentMethodType.mandiriVa:
        return 'bank_transfer';
      case PaymentMethodType.qris:
        return 'qris';
      case PaymentMethodType.gopay:
        return 'gopay';
      case PaymentMethodType.shopeepay:
        return 'shopeepay';
    }
  }

  String? get bank {
    switch (this) {
      case PaymentMethodType.bcaVa:     return 'bca';
      case PaymentMethodType.bniVa:     return 'bni';
      case PaymentMethodType.briVa:     return 'bri';
      case PaymentMethodType.mandiriVa: return 'mandiri';
      default:                          return null;
    }
  }

  bool get isVa => bank != null;
  bool get isEwallet =>
      this == PaymentMethodType.gopay || this == PaymentMethodType.shopeepay;
}

// ── Base class ─────────────────────────────────────────────
abstract class PaymentResult {
  final String orderId;
  final double grossAmount;
  final DateTime expiredAt;
  final String status;
  final PaymentMethodType methodType;

  const PaymentResult({
    required this.orderId,
    required this.grossAmount,
    required this.expiredAt,
    required this.status,
    required this.methodType,
  });

  bool get isExpired => DateTime.now().isAfter(expiredAt);

  Duration get timeRemaining {
    final rem = expiredAt.difference(DateTime.now());
    return rem.isNegative ? Duration.zero : rem;
  }
}

// ── Virtual Account ────────────────────────────────────────
class VaPaymentResult extends PaymentResult {
  final String vaNumber;
  final String bank;

  const VaPaymentResult({
    required this.vaNumber,
    required this.bank,
    required super.orderId,
    required super.grossAmount,
    required super.expiredAt,
    required super.status,
    required super.methodType,
  });

  factory VaPaymentResult.fromJson(Map<String, dynamic> json) {
    // Midtrans response untuk bank_transfer:
    //   BCA/BNI/BRI → va_numbers: [{ "bank": "bri", "va_number": "xxx" }]
    //   Mandiri      → bill_key + biller_code (tidak pakai va_numbers)
    String bank     = '';
    String vaNumber = '';

    final vaNumbers = json['va_numbers'] as List? ?? [];
    if (vaNumbers.isNotEmpty) {
      bank     = vaNumbers[0]['bank']?.toString() ?? '';
      vaNumber = vaNumbers[0]['va_number']?.toString() ?? '';
    }

    // Mandiri pakai bill_key + biller_code
    if (bank.isEmpty && json['bill_key'] != null) {
      bank     = 'mandiri';
      vaNumber = '${json["biller_code"] ?? ""} ${json["bill_key"] ?? ""}'.trim();
    }

    // Fallback
    if (bank.isEmpty)     bank     = json['bank']?.toString() ?? '';
    if (vaNumber.isEmpty) vaNumber = json['va_number']?.toString() ?? '';

    return VaPaymentResult(
      vaNumber    : vaNumber,
      bank        : bank,
      orderId     : json['order_id']?.toString() ?? '',
      grossAmount : double.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0,
      expiredAt   : _parseExpired(json),
      status      : json['transaction_status']?.toString() ?? 'pending',
      methodType  : _bankToMethodType(bank),
    );
  }

  static PaymentMethodType _bankToMethodType(String bank) {
    switch (bank.toLowerCase()) {
      case 'bca':     return PaymentMethodType.bcaVa;
      case 'bni':     return PaymentMethodType.bniVa;
      case 'bri':     return PaymentMethodType.briVa;
      case 'mandiri': return PaymentMethodType.mandiriVa;
      default:        return PaymentMethodType.bcaVa;
    }
  }
}

// ── QRIS ───────────────────────────────────────────────────
class QrisPaymentResult extends PaymentResult {
  final String qrCodeUrl;
  final String qrString;

  const QrisPaymentResult({
    required this.qrCodeUrl,
    required this.qrString,
    required super.orderId,
    required super.grossAmount,
    required super.expiredAt,
    required super.status,
    required super.methodType,
  });

  factory QrisPaymentResult.fromJson(Map<String, dynamic> json) {
    // Midtrans QRIS response:
    // {
    //   "qr_string": "00020101...",
    //   "actions": [
    //     { "name": "generate-qr-code", "url": "https://api.midtrans.com/..." }
    //   ]
    // }
    final actions = json['actions'] as List? ?? [];
    String qrUrl  = '';

    for (final a in actions) {
      if (a['name']?.toString() == 'generate-qr-code') {
        qrUrl = a['url']?.toString() ?? '';
        break;
      }
    }

    return QrisPaymentResult(
      qrCodeUrl   : qrUrl,
      qrString    : json['qr_string']?.toString() ?? '',
      orderId     : json['order_id']?.toString() ?? '',
      grossAmount : double.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0,
      expiredAt   : _parseExpired(json),
      status      : json['transaction_status']?.toString() ?? 'pending',
      methodType  : PaymentMethodType.qris,
    );
  }
}

// ── E-Wallet (GoPay / ShopeePay) ──────────────────────────
class EwalletPaymentResult extends PaymentResult {
  final String deeplinkUrl;
  final String qrCodeUrl;

  const EwalletPaymentResult({
    required this.deeplinkUrl,
    required this.qrCodeUrl,
    required super.orderId,
    required super.grossAmount,
    required super.expiredAt,
    required super.status,
    required super.methodType,
  });

  factory EwalletPaymentResult.fromJson(
      Map<String, dynamic> json, PaymentMethodType type) {
    // Midtrans GoPay/ShopeePay response:
    // {
    //   "actions": [
    //     { "name": "generate-qr-code",  "url": "https://..." },
    //     { "name": "deeplink-redirect", "url": "gojek://..." }
    //   ]
    // }
    final actions = json['actions'] as List? ?? [];
    String deeplink = '';
    String qrUrl    = '';

    for (final a in actions) {
      final name = a['name']?.toString() ?? '';
      if (name == 'deeplink-redirect') deeplink = a['url']?.toString() ?? '';
      if (name == 'generate-qr-code')  qrUrl    = a['url']?.toString() ?? '';
    }

    return EwalletPaymentResult(
      deeplinkUrl : deeplink,
      qrCodeUrl   : qrUrl,
      orderId     : json['order_id']?.toString() ?? '',
      grossAmount : double.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0,
      expiredAt   : _parseExpired(json),
      status      : json['transaction_status']?.toString() ?? 'pending',
      methodType  : type,
    );
  }
}

// ── Helper ─────────────────────────────────────────────────
DateTime _parseExpired(Map<String, dynamic> json) {
  final raw = json['expiry_time'] ?? json['expired_at'];
  if (raw != null) {
    return DateTime.tryParse(raw.toString())?.toLocal() ?? _defaultExpired();
  }
  return _defaultExpired();
}

DateTime _defaultExpired() => DateTime.now().add(const Duration(hours: 24));

// ── Factory utama ──────────────────────────────────────────
PaymentResult parsePaymentResult(Map<String, dynamic> json) {
  final type = json['payment_type']?.toString() ?? '';

  switch (type) {
    case 'bank_transfer':
      return VaPaymentResult.fromJson(json);
    case 'qris':
      return QrisPaymentResult.fromJson(json);
    case 'gopay':
      return EwalletPaymentResult.fromJson(json, PaymentMethodType.gopay);
    case 'shopeepay':
      return EwalletPaymentResult.fromJson(json, PaymentMethodType.shopeepay);
    default:
      throw Exception('Tipe pembayaran tidak dikenal: $type');
  }
}