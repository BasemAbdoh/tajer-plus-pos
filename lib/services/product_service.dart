class ProductService {


  static double calculatePurchasePrice(double packPurchasePrice, int packQuantity) {
    if (packQuantity <= 0) {
      throw ArgumentError('packQuantity must be greater than zero');
    }
    if (packPurchasePrice < 0) {
      throw ArgumentError('packPurchasePrice cannot be negative');
    }
    return packPurchasePrice / packQuantity;
  }
  //  ----------------- دالة حساب اجمالي سعر البيع-------
  static double calculateTotalSalPricr(double salePrice, int packQuantity) {
    if (packQuantity <= 0) {
      throw ArgumentError('packQuantity must be greater than zero');
    }
    if (salePrice < 0) {
      throw ArgumentError('packPurchasePrice cannot be negative');
    }
    return salePrice * packQuantity;
  }
  //---------------------------------

  //------------- دالة حساب الفائدة ---------------
  static double calculateProfitPrice(double packPurchasePrice, double totalSalePrice) {
    if (totalSalePrice <= 0) {
      throw ArgumentError('packQuantity must be greater than zero');
    }
    if (packPurchasePrice < 0) {
      throw ArgumentError('packPurchasePrice cannot be negative');
    }
    return totalSalePrice - packPurchasePrice;
  }
  //-----------------------------------

  static bool validateProductFields({
    required String productName,
    required double salePrice,
    // required double totalSalePrice,
    // required double profitPrice,
    required double packPurchasePrice,
    required int packQuantity,
    required DateTime addedDate,
    required String category,
  }) {
    if (productName.isEmpty) return false;
    if (salePrice < 0) return false;
    // if(totalSalePrice < 0) return false;
    // if(profitPrice < 0) return false;
    if (packPurchasePrice < 0) return false;
    if (packQuantity <= 0) return false;
    if (category.isEmpty) return false;
    return true;
  }
}
