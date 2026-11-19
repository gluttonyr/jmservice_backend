export const PARAMETRE_CODES = {
  DISCUSSION_REFRESH: 'DISCUSSION_REFRESH',
  ANDROID_MIN_VERSION_CODE: 'ANDROID_MIN_VERSION_CODE',
  IOS_MIN_VERSION_CODE: 'IOS_MIN_VERSION_CODE',
  // 1 = deposits closed for every client, whatever the capture state.
  DEPOTS_FERMES: 'DEPOTS_FERMES',
  // 1 = withdrawals closed for every client.
  RETRAITS_FERMES: 'RETRAITS_FERMES',
  // Bookmaker promo code shown to clients (text in valeurTexte). Empty = not shown.
  CODE_PROMO: 'CODE_PROMO',
};

// Value given to CODE_PROMO at startup while it is still empty. Empty until the real code is known.
export const CODE_PROMO_PAR_DEFAUT = '';