import {NativeModules} from 'react-native';

const {MidtransModule} = NativeModules;

const PAYMENT_TYPE_LIST = [
  'CREDIT_CARD',
  'BANK_TRANSFER',
  'BANK_TRANSFER_BCA',
  'BANK_TRANSFER_MANDIRI',
  'BANK_TRANSFER_PERMATA',
  'BANK_TRANSFER_BNI',
  'BANK_TRANSFER_OTHER',
  'GO_PAY',
  'BCA_KLIKPAY',
  'KLIKBCA',
  'MANDIRI_CLICKPAY',
  'MANDIRI_ECASH',
  'EPAY_BRI',
  'CIMB_CLICKS',
  'INDOMARET',
  'KIOSON',
  'GIFT_CARD_INDONESIA',
  'INDOSAT_DOMPETKU',
  'TELKOMSEL_CASH',
  'XL_TUNAI',
  'DANAMON_ONLINE'
];

export default {
  checkOut: function (optionConect: ?object,
                      transRequest: ?object,
                      itemDetails: ?object,
                      creditCardOptions: ?object,
                      mapUserDetail: ?object,
                      optionColorTheme: ?object,
                      optionFont: ?object,
                      resultCheckOut) {
    if(transRequest.paymentType) {
      let index = PAYMENT_TYPE_LIST.indexOf(transRequest.paymentType);
      if(index === -1) {
        throw new Error('invalid payment method');
      }
      transRequest.paymentType = index;
    }

    MidtransModule.checkOut(
      optionConect,
      transRequest,
      itemDetails,
      creditCardOptions,
      mapUserDetail,
      optionColorTheme,
      optionFont,
      resultCheckOut);
  },
};
