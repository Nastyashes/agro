import 'package:agro/ui/theme/colors.dart';
import 'package:flutter/material.dart';

class ModelTariff {
  final String name;  
  final String price;
  final Color color;
  final List<String> advantages; 
  final List<String> disadvantages; 

 ModelTariff({
    required this.name,
    required this.price,
    required this.color,
    required this.advantages,
    required this.disadvantages,
  });
}



 ModelTariff  bezlimTariff =  ModelTariff(
  name: 'БЕЗЛІМ',  
  price: '0 грн',  
  color: AppColors.tariffFree, 
  advantages: [  
    'Контакти заявок без меж відкриваються',
    'Надходження заявок через 3 години',
    'Зміна налаштувань та перше підключення 500 грн',
  ],
  disadvantages: [ 
    '0 СМС',
    'Без можливості блокування заявки',
    'Заявки в Телеграм не надходять',
    'Відсутні будь-які дані про зацікавленість заявкою',
    'Без публікаціїї логотипу на головній сторінці сайту',
  ],
);
ModelTariff premiumTariff =  ModelTariff(
  name: 'PREMIUM',  
  price: '12 000 грн',  
  color: AppColors.tariffPremium, 
  advantages: [  
    'Контакти заявок одразу відкриті',
    'Надходження заявок через 3 години',
    '500 СМС',
    'Без реклами в додатку',
    'Заявки надходять в Телеграм',
    'Кількість трейдерів, що переглянули заявку',
    'Кількість трейдерів, що відкрили контакт',
    'Зацікавленість в заявці в %',
    'Безкоштовна зміна налаштувань'
  ],
  disadvantages: [ 
    'Без можливості блокування заявки',
    'Без публікаціїї логотипу на головній сторінці сайту',
  ],
);
ModelTariff vipTariff =  ModelTariff(
  name: 'VIP',  
  price: '24 000 грн',  
  color: AppColors.tariffVip, 
  advantages: [  
    'Контакти заявок одразу відкриті',
    'Надходження заявок відразу',
    '1000 СМС',
    'Без реклами в додатку',
    'Заявки надходять в Телеграм',
    'Кількість трейдерів, що переглянули заявку',
    'Кількість трейдерів, що відкрили контакт',
    'Зацікавленість в заявці в %',
    'Блокування заявки',
    'Логотип на головній сторінці сайту',
    'Безкоштовна зміна налаштувань'
  ],
  disadvantages: [],
);