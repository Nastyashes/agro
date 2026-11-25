import 'package:agro/model/my_price/my_price_order_meta.dart';
import 'package:agro/model/new_models_bids/add_banner/add_banner_model.dart';
import 'package:agro/model/new_models_bids/bids_contacts_model.dart';
import 'package:agro/model/new_models_bids/bids_item_model.dart';
import 'package:agro/server/api/api.dart';
import 'package:agro/server/api/api_client.dart';

class BidsPage {
  const BidsPage({required this.items, this.total, this.userfield});

  final List<BidItem> items;

  /// Total on the server, if it said; used for "load more".
  final int? total;

  /// User flags (ads state) the backend piggybacks on list responses.
  final Map<String, dynamic>? userfield;
}

class OrderView {
  const OrderView({this.item, this.myPrice});

  /// Full order when the response describes one.
  final BidItem? item;

  /// "My price" meta when only that part is present.
  final MyPriceOrderMeta? myPrice;
}

class BidContact {
  const BidContact({
    this.phone,
    this.company,
    this.name,
    this.email,
    required this.contacts,
  });

  final String? phone, company, name, email;
  final BidContacts contacts;
}

enum OpenContactStatus { opened, insufficient, failed }

class OpenContactResult {
  const OpenContactResult(this.status, {this.contact, this.message});

  final OpenContactStatus status;
  final BidContact? contact;

  /// Server text for insufficient/failed.
  final String? message;
}

class CarrierResult {
  const CarrierResult({required this.ok, required this.message});

  final bool ok;
  final String message;
}

enum AnalysisStatus { ordered, insufficient, failed }

class AnalysisResult {
  const AnalysisResult(
    this.status, {
    this.balanceAfter,
    this.balance,
    this.price,
    this.message,
  });

  final AnalysisStatus status;
  final String? balanceAfter, balance, price, message;
}

/// Bid lists, order details and paid actions on a bid.
class BidsRepository {
  BidsRepository([Api? api]) : _api = api ?? Api();

  final Api _api;

  /// "All bids" tab, with optional text search.
  Future<BidsPage> search({
    String? query,
    required int limit,
    required int offset,
  }) async {
    final data = await _map(
        _api.traider.searchBids(search: query, limit: limit, offset: offset));
    if (data['status'] == '-') {
      throw ApiException(
        ApiErrorKind.badResponse,
        statusCode: 200,
        cause: data['error']?.toString() ?? 'searchBids failed',
      );
    }
    return BidsPage(
      items: BidsResponse.fromJson(data).bids,
      total: _int(data['bids_total']),
      userfield: _userfield(data),
    );
  }

  /// "Fresh bids" tab (free tariff).
  Future<BidsPage> fresh({required int limit, required int offset}) async {
    final data =
        await _map(_api.traider.getAllBids(limit: limit, offset: offset));
    return BidsPage(
      items: BidsResponse.fromJson(data).bidsFresh,
      total: _int(data['bids_fresh_total']),
      userfield: _userfield(data),
    );
  }

  Future<AdBannerModel?> feedBanner() => _api.traider.getAdBanner();

  Future<OrderView> view(int orderId) async {
    final data = (await _api.traider.getOrder(orderId: orderId)).data;
    final item = BidItem.fromOrderView(data);
    if (item != null) return OrderView(item: item);

    final myPrice = data is Map ? data['my_price'] : null;
    return OrderView(
      myPrice: myPrice is Map
          ? MyPriceOrderMeta.fromJson(Map<String, dynamic>.from(myPrice))
          : null,
    );
  }

  /// Whether an ad must be watched before a free contact opens.
  Future<OpenContactsAdResponse> contactAd(int orderId) =>
      _api.traider.openContactsAd(orderId: orderId);

  /// Opens (and may charge for) the farmer's contact.
  Future<OpenContactResult> openContact(int orderId) async {
    final data = await _map(_api.traider.openBidContact(orderId: orderId));
    final message = data['message']?.toString();
    final status = data['status'];

    if (status == 'insufficient') {
      return OpenContactResult(OpenContactStatus.insufficient,
          message: message);
    }
    final payload = data['payload'];
    if (status != '+' || payload is! Map) {
      return OpenContactResult(OpenContactStatus.failed, message: message);
    }

    final p = Map<String, dynamic>.from(payload);
    return OpenContactResult(
      OpenContactStatus.opened,
      contact: BidContact(
        phone: p['phone']?.toString(),
        company: p['company']?.toString(),
        name: p['name']?.toString(),
        email: p['email']?.toString(),
        contacts: BidContacts.fromJson(p),
      ),
    );
  }

  /// Sends the request to the carrier dispatcher bot.
  Future<CarrierResult> orderCarrier() async {
    final data = await _map(_api.traider.orderCarrier());
    return CarrierResult(
      ok: data['status'] == true,
      message: data['message']?.toString() ?? '',
    );
  }

  /// Orders a paid analysis of the bid.
  Future<AnalysisResult> orderAnalysis(int orderId) async {
    final data = await _map(_api.traider.orderAnalysis(orderId: orderId));
    final status = data['status']?.toString();
    if (status == '+') {
      return AnalysisResult(AnalysisStatus.ordered,
          balanceAfter: data['balance_after']?.toString());
    }
    if (status == 'insufficient') {
      return AnalysisResult(AnalysisStatus.insufficient,
          balance: data['balance']?.toString(),
          price: data['price']?.toString());
    }
    return AnalysisResult(AnalysisStatus.failed,
        message: data['message']?.toString());
  }

  static Future<Map<String, dynamic>> _map(Future<ApiAnswer> call) async {
    final data = (await call).data;
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  static int? _int(dynamic value) => int.tryParse('${value ?? ''}');

  static Map<String, dynamic>? _userfield(Map<String, dynamic> data) {
    final value = data['userfield'];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }
}
