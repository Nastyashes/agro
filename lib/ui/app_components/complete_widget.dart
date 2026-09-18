
// ============================================================
// PULL TO REFRESH COMPLETE
// ============================================================

import 'package:agro/vars/helper.dart';
import 'package:flutter/material.dart';

class CompleteWidget extends StatelessWidget {
  const CompleteWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.done,
          color: Colors.grey,
        ),
        const SizedBox(width: 15),
        Text(
          context.l.updateComplete,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
