class Application {
  final String? id;
  final String? status;
  final String? userId;
  final String? operId;
  final String? sphereId;
  final String? productId;
  final String? productTitle;
  final String? orderTitle;
  final String? amount;
  final String? amountType;
  final String? regionId;
  final String? opt1Id;
  final String? year;
  final String? deliveryType;
  final String? paymentType;
  final String? paymentForm;
  final DateTime? created;
  final bool? started;
  final DateTime? dateEnd;
  final String? views;
  final String? alias;
  final String? comment;
  final String? createdHuman;
  final String? endingHuman;
  final String? regionTitle;
  final String? deliveryHuman;

  Application({
    this.id,
    this.status,
    this.userId,
    this.operId,
    this.sphereId,
    this.productId,
    this.productTitle,
    this.orderTitle,
    this.amount,
    this.amountType,
    this.regionId,
    this.opt1Id,
    this.year,
    this.deliveryType,
    this.paymentType,
    this.paymentForm,
    this.created,
    this.started,
    this.dateEnd,
    this.views,
    this.alias,
    this.comment,
    this.createdHuman,
    this.endingHuman,
    this.regionTitle,
    this.deliveryHuman,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String?,
      status: json['status'] as String?,
      userId: json['user_id'] as String?,
      operId: json['oper_id'] as String?,
      sphereId: json['sphere_id'] as String?,
      productId: json['product_id'] as String?,
      productTitle: json['product_title'] as String?,
      orderTitle: json['order_title'] as String?,
      amount: json['amount'] as String?,
      amountType: json['amount_type'] as String?,
      regionId: json['region_id'] as String?,
      opt1Id: json['opt1_id'] as String?,
      year: json['year'] as String?,
      deliveryType: json['delivery_type'] as String?,
      paymentType: json['payment_type'] as String?,
      paymentForm: json['payment_form'] as String?,
      created: json['created'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(json['created'])! * 1000)
          : null,
      started: json['started'] != null ? json['started'] == "1" : null,
      dateEnd: json['date_end'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(json['date_end'])! * 1000)
          : null,
      views: json['views'] as String?,
      alias: json['alias'] as String?,
      comment: json['comment'] as String?,
      createdHuman: json['created_human'] as String?,
      endingHuman: json['ending_human'] as String?,
      regionTitle: json['region_title'] as String?,
      deliveryHuman: json['delivery_human'] as String?,
    );
  }
}

List<Application> parseApplications(List<dynamic> jsonList) {
  return jsonList.map((json) => Application.fromJson(json)).toList();
}
