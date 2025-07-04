import '../../../../shared/models/service_model.dart';

/// Service catalog with predefined services for CareNow
class ServiceCatalog {
  static const Map<String, String> categories = {
    'elder_care': 'Chăm sóc người già',
    'child_care': 'Chăm sóc trẻ em',
    'pet_care': 'Chăm sóc thú cưng',
    'housekeeping': 'Dọn dẹp nhà cửa',
    'medical_care': 'Chăm sóc y tế',
    'companion_care': 'Chăm sóc đồng hành',
    'disability_care': 'Chăm sóc người khuyết tật',
    'postpartum_care': 'Chăm sóc sau sinh',
  };

  /// Get predefined services for the platform
  static List<ServiceModel> getPredefinedServices() {
    final now = DateTime.now();
    
    return [
      // Elder Care Services
      ServiceModel(
        id: 'elder_care_basic',
        name: 'Chăm sóc người già cơ bản',
        description: 'Hỗ trợ sinh hoạt hàng ngày, đo huyết áp, nhắc uống thuốc',
        category: 'elder_care',
        iconUrl: 'assets/icons/elder_care.png',
        basePrice: 150000,
        durationMinutes: 120,
        requirements: ['Kinh nghiệm chăm sóc người già', 'Kiên nhẫn', 'Tỉ mỉ'],
        benefits: ['Chăm sóc tận tình', 'Theo dõi sức khỏe', 'Hỗ trợ sinh hoạt'],
        isActive: true,
        sortOrder: 1,
        createdAt: now,
      ),
      
      ServiceModel(
        id: 'elder_care_medical',
        name: 'Chăm sóc người già có bệnh lý',
        description: 'Chăm sóc chuyên nghiệp cho người già có bệnh mãn tính',
        category: 'elder_care',
        iconUrl: 'assets/icons/elder_medical.png',
        basePrice: 250000,
        durationMinutes: 180,
        requirements: ['Có chứng chỉ y tế', 'Kinh nghiệm 2+ năm', 'Kỹ năng sơ cứu'],
        benefits: ['Chăm sóc chuyên nghiệp', 'Theo dõi bệnh lý', 'Báo cáo tình trạng'],
        isActive: true,
        sortOrder: 2,
        createdAt: now,
      ),

      // Child Care Services
      ServiceModel(
        id: 'child_care_basic',
        name: 'Trông trẻ cơ bản',
        description: 'Trông nom, chơi cùng trẻ, hỗ trợ ăn uống và vệ sinh',
        category: 'child_care',
        iconUrl: 'assets/icons/child_care.png',
        basePrice: 100000,
        durationMinutes: 180,
        requirements: ['Yêu trẻ em', 'Kiên nhẫn', 'Có kinh nghiệm'],
        benefits: ['Trông nom an toàn', 'Hoạt động vui chơi', 'Chăm sóc tận tình'],
        isActive: true,
        sortOrder: 3,
        createdAt: now,
      ),

      ServiceModel(
        id: 'child_care_newborn',
        name: 'Chăm sóc trẻ sơ sinh',
        description: 'Chăm sóc chuyên nghiệp cho trẻ sơ sinh 0-6 tháng',
        category: 'child_care',
        iconUrl: 'assets/icons/newborn_care.png',
        basePrice: 200000,
        durationMinutes: 240,
        requirements: ['Chứng chỉ chăm sóc trẻ sơ sinh', 'Kinh nghiệm 1+ năm'],
        benefits: ['Chăm sóc chuyên nghiệp', 'Theo dõi phát triển', 'Hỗ trợ bú mẹ'],
        isActive: true,
        sortOrder: 4,
        createdAt: now,
      ),

      // Pet Care Services
      ServiceModel(
        id: 'pet_care_basic',
        name: 'Chăm sóc thú cưng cơ bản',
        description: 'Cho ăn, dắt đi dạo, vệ sinh và chơi cùng thú cưng',
        category: 'pet_care',
        iconUrl: 'assets/icons/pet_care.png',
        basePrice: 80000,
        durationMinutes: 90,
        requirements: ['Yêu động vật', 'Không sợ chó mèo', 'Có kinh nghiệm'],
        benefits: ['Chăm sóc tận tình', 'Vận động đầy đủ', 'Vệ sinh sạch sẽ'],
        isActive: true,
        sortOrder: 5,
        createdAt: now,
      ),

      // Housekeeping Services
      ServiceModel(
        id: 'housekeeping_basic',
        name: 'Dọn dẹp nhà cửa cơ bản',
        description: 'Quét nhà, lau chùi, sắp xếp đồ đạc, vệ sinh phòng tắm',
        category: 'housekeeping',
        iconUrl: 'assets/icons/housekeeping.png',
        basePrice: 120000,
        durationMinutes: 120,
        requirements: ['Tỉ mỉ', 'Cẩn thận', 'Có kinh nghiệm'],
        benefits: ['Nhà cửa sạch sẽ', 'Tiết kiệm thời gian', 'Chuyên nghiệp'],
        isActive: true,
        sortOrder: 6,
        createdAt: now,
      ),

      ServiceModel(
        id: 'housekeeping_deep',
        name: 'Dọn dẹp tổng thể',
        description: 'Dọn dẹp sâu toàn bộ nhà, bao gồm cả những nơi khó tiếp cận',
        category: 'housekeeping',
        iconUrl: 'assets/icons/deep_cleaning.png',
        basePrice: 300000,
        durationMinutes: 300,
        requirements: ['Kinh nghiệm dọn dẹp', 'Sức khỏe tốt', 'Dụng cụ chuyên dụng'],
        benefits: ['Dọn dẹp triệt để', 'Khử trùng toàn diện', 'Nhà như mới'],
        isActive: true,
        sortOrder: 7,
        createdAt: now,
      ),

      // Medical Care Services
      ServiceModel(
        id: 'medical_care_basic',
        name: 'Chăm sóc y tế tại nhà',
        description: 'Đo huyết áp, tiêm thuốc, thay băng, chăm sóc vết thương',
        category: 'medical_care',
        iconUrl: 'assets/icons/medical_care.png',
        basePrice: 300000,
        durationMinutes: 60,
        requirements: ['Bằng y tá/điều dưỡng', 'Kinh nghiệm 2+ năm', 'Giấy phép hành nghề'],
        benefits: ['Chăm sóc chuyên nghiệp', 'Tiện lợi tại nhà', 'An toàn'],
        isActive: true,
        sortOrder: 8,
        createdAt: now,
      ),

      // Companion Care Services
      ServiceModel(
        id: 'companion_care_basic',
        name: 'Chăm sóc đồng hành',
        description: 'Trò chuyện, đọc sách, đi dạo cùng người cao tuổi',
        category: 'companion_care',
        iconUrl: 'assets/icons/companion_care.png',
        basePrice: 100000,
        durationMinutes: 120,
        requirements: ['Giao tiếp tốt', 'Kiên nhẫn', 'Thân thiện'],
        benefits: ['Giảm cô đơn', 'Tinh thần thoải mái', 'Hoạt động xã hội'],
        isActive: true,
        sortOrder: 9,
        createdAt: now,
      ),

      // Postpartum Care Services
      ServiceModel(
        id: 'postpartum_care_basic',
        name: 'Chăm sóc sau sinh',
        description: 'Chăm sóc mẹ và bé sau sinh, hỗ trợ bú mẹ, vệ sinh',
        category: 'postpartum_care',
        iconUrl: 'assets/icons/postpartum_care.png',
        basePrice: 350000,
        durationMinutes: 480,
        requirements: ['Chứng chỉ chăm sóc sau sinh', 'Kinh nghiệm 2+ năm'],
        benefits: ['Chăm sóc chuyên nghiệp', 'Hỗ trợ bú mẹ', 'Theo dõi sức khỏe'],
        isActive: true,
        sortOrder: 10,
        createdAt: now,
      ),
    ];
  }

  /// Get services by category
  static List<ServiceModel> getServicesByCategory(String category) {
    return getPredefinedServices()
        .where((service) => service.category == category)
        .toList();
  }

  /// Get category display name
  static String getCategoryDisplayName(String category) {
    return categories[category] ?? category;
  }

  /// Get all category keys
  static List<String> getAllCategories() {
    return categories.keys.toList();
  }

  /// Get popular services (top 5)
  static List<ServiceModel> getPopularServices() {
    return getPredefinedServices().take(5).toList();
  }

  /// Search services by name or description
  static List<ServiceModel> searchServices(String query) {
    if (query.trim().isEmpty) return getPredefinedServices();
    
    final lowercaseQuery = query.toLowerCase();
    return getPredefinedServices()
        .where((service) =>
            service.name.toLowerCase().contains(lowercaseQuery) ||
            service.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}
