import 'package:agro/model/message/created.dart';
import 'package:agro/model/model_order/bids.dart';
import 'package:agro/model/model_order/model_contact.dart';
import 'package:agro/model/model_order/quality.dart';
import 'package:agro/model/model_order/traider_contact.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ModelOrder extends Created {
  int? id, harvestYear, sphere;
  String? title,
      crop,
      comment,
      region,
      capacity,
      count,
      payForm,
      payment,
      deliveryForm,
      sort,
      vidRabot;
  DateTime? startDate, endDate;
  bool? request, priceAdded;
  ModelContact? contact;
  List<Bid> bids;
  Quality? quality;
  List<TraiderContact> traiderContacts;

  ModelOrder(
      {this.id,
      this.title,
      this.comment,
      this.capacity,
      this.count,
      this.crop,
      this.deliveryForm,
      this.endDate,
      this.harvestYear,
      this.priceAdded,
      this.payForm,
      this.payment,
      this.region,
      this.request,
      this.sort,
      this.startDate,
      this.vidRabot,
      this.contact,
      this.bids = const [],
      this.traiderContacts = const []});
}

extension OrderX on ModelOrder {
  String toText(BuildContext context) {
    if (contact == null) {
      return toTextShort(context);
    } else {
      return toTextFull(contact, context);
    }
  }

  String toTextShort(BuildContext context) {
    return "${context.l.applicationNo}$id ${context.l.from} ${DateFormat('dd.MM.yyyy').format(startDate!)}\n"
        "${context.l.region}: $region\n"
        "${context.l.crop}: $crop\n"
        "${context.l.volume}: $capacity\n"
        "${context.l.harvestYear}: $harvestYear\n"
        "${context.l.formOfPayment}: $payForm\n"
        "${context.l.typeOfDelivery}: $deliveryForm\n"
        "${context.l.comment}: $comment\n";
  }

  String toTextFull(ModelContact? contact, BuildContext context) {
    return "${context.l.applicationNo}$id ${context.l.from} ${DateFormat('dd.MM.yyyy').format(startDate!)}\n"
        "${context.l.region}: $region\n"
        "${context.l.crop}: $crop\n"
        "${context.l.volume}: $capacity\n"
        "${context.l.harvestYear}: $harvestYear\n"
        "${context.l.formOfPayment}: $payForm\n"
        "${context.l.typeOfDelivery}: $deliveryForm\n"
        "${context.l.comment}: $comment\n"
        "${contact?.userName}\n"
        "${context.l.address}: ${contact?.userRegion}\n"
        "${contact?.userDistrict}\n"
        "${contact?.userCity}\n"
        "${context.l.eMail}: ${contact?.userEmail}\n"
        "${context.l.phone}: ${contact?.userPhone}\n";
  }
}
