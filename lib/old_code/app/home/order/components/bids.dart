import 'package:agro/old_code/app/home/order/components/offer_item.dart';
import 'package:agro/model/model_order/bids.dart';
import 'package:agro/ui/text/read_text.dart';
import 'package:agro/ui/theme/fonts.dart';
import 'package:agro/ui/utils/date_extensions.dart';
import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

Widget bids(BuildContext context, List<Bid> bids) {
  return Column(
    children: [
      Row(children: [
        Expanded(
            child: readText(
          text: context.l.fertilizerPriceOffers,
          style: AppFonts.body1bold.black,
        )),
        readText(
          text: bids.length.toString(),
          style: AppFonts.title2.grey3,
        )
      ]),
      for (int i = 0; i < bids.length; i++) ...[
        offerItem(
            i + 1,
            DateTime.fromMillisecondsSinceEpoch(bids[i].created ?? 0)
                .formatDateTimeShort(),
            bids[i].priceList.toString(), context)
      ],
      const SizedBox(height: 20)
    ],
  );
}
