class ApiEndpoints {
  // static const String baseUrl = 'http://10.0.2.2:5000';
  static const String baseUrl = 'https://api-quiosque.igorpolegato.com.br';
  static const String _v1 = '/v1';

  static String get api => '$baseUrl$_v1';

  // Items
  static String get items => '$api/items';
  static String itemById(int id) => '$api/items/$id';
  static String get createItem => '$api/items/new';

  // Categories
  static String get categories => '$api/categories';
  static String get createCategory => '$api/categories/new';
  static String categoryItems(int id) => '$api/categories/items?category=$id';

  // Customers
  static String get createCustomer => '$api/customers/new';
  static String get customers => '$api/customers';

  // Orders
  static String get createOrder => '$api/orders/new';
  static String get orders => '$api/orders';
  static String get pendingOrders => '$api/orders/pendings';
  static String ordersByCustomer(int customerId) =>
      '$api/orders/customer?customer=$customerId';
  static String orderById(int id) => '$api/orders/$id';
}
