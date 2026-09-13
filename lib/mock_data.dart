// ── Mock data — single source of truth for the prototype ─────────────────

class MockScrap {
  static const String material = 'Copper Wire';
  static const double defaultWeightKg = 12.0;
  static const double ratePerKg = 600.0;

  static double estimatedValue(double kg) => kg * ratePerKg;
}

class MockRecyclers {
  static const List<RecyclerData> all = [
    // ── Copper ─────────────────────────────────────────────
    RecyclerData(
      id: 'CU-A',
      name: 'GreenLoop Metals',
      authorized: true,
      ratePerKg: 600,
      distanceKm: 2.4,
      pickupAvailable: true,
      acceptsMaterial: 'Copper Wire',
      isBestMatch: false,
    ),
    RecyclerData(
      id: 'CU-B',
      name: 'EcoMetal Recycler',
      authorized: true,
      ratePerKg: 585,
      distanceKm: 1.7,
      pickupAvailable: false,
      acceptsMaterial: 'Copper Wire',
      isBestMatch: false,
    ),

    // ── Aluminium ───────────────────────────────────────────
    RecyclerData(
      id: 'AL-A',
      name: 'Metro Aluminium Recovery',
      authorized: true,
      ratePerKg: 180,
      distanceKm: 2.3,
      pickupAvailable: true,
      acceptsMaterial: 'Aluminium',
      isBestMatch: false,
    ),

    // ── Brass ───────────────────────────────────────────────
    RecyclerData(
      id: 'BR-A',
      name: 'Circular Brass Works',
      authorized: true,
      ratePerKg: 420,
      distanceKm: 2.7,
      pickupAvailable: true,
      acceptsMaterial: 'Brass',
      isBestMatch: false,
    ),

    // ── Iron ────────────────────────────────────────────────
    RecyclerData(
      id: 'IR-A',
      name: 'Green Iron Recycling',
      authorized: true,
      ratePerKg: 35,
      distanceKm: 1.8,
      pickupAvailable: true,
      acceptsMaterial: 'Iron',
      isBestMatch: false,
    ),
    // ── PCB / E-Waste ──────────────────────────────────────
    RecyclerData(
      id: 'PCB-A',
      name: 'E-Cycle Recovery',
      authorized: true,
      ratePerKg: 260,
      distanceKm: 2.1,
      pickupAvailable: true,
      acceptsMaterial: 'PCB / E-Waste',
      isBestMatch: false,
    ),
    RecyclerData(
      id: 'PCB-B',
      name: 'Urban E-Waste Recycler',
      authorized: true,
      ratePerKg: 250,
      distanceKm: 1.4,
      pickupAvailable: false,
      acceptsMaterial: 'PCB / E-Waste',
      isBestMatch: false,
    ),
    RecyclerData(
      id: 'PCB-C',
      name: 'Circular Tech Recycling',
      authorized: true,
      ratePerKg: 255,
      distanceKm: 3.2,
      pickupAvailable: true,
      acceptsMaterial: 'PCB / E-Waste',
      isBestMatch: false,
    ),

    // ── Battery ─────────────────────────────────────────────
    RecyclerData(
      id: 'BAT-A',
      name: 'SafeCell Recycling',
      authorized: true,
      ratePerKg: 100,
      distanceKm: 2.8,
      pickupAvailable: true,
      acceptsMaterial: 'Battery',
      isBestMatch: false,
    ),
    RecyclerData(
      id: 'BAT-B',
      name: 'Eco Battery Recovery',
      authorized: true,
      ratePerKg: 95,
      distanceKm: 1.9,
      pickupAvailable: false,
      acceptsMaterial: 'Battery',
      isBestMatch: false,
    ),
    RecyclerData(
      id: 'BAT-C',
      name: 'GreenCell Recycler',
      authorized: true,
      ratePerKg: 98,
      distanceKm: 3.5,
      pickupAvailable: true,
      acceptsMaterial: 'Battery',
      isBestMatch: false,
    ),

    // ── Metal scrap ─────────────────────────────────────────
    RecyclerData(
      id: 'MET-A',
      name: 'Metro Metal Works',
      authorized: true,
      ratePerKg: 42,
      distanceKm: 2.2,
      pickupAvailable: true,
      acceptsMaterial: 'Metal Scrap',
      isBestMatch: false,
    ),

    // ── Mobile phones ───────────────────────────────────────
    RecyclerData(
      id: 'MOB-A',
      name: 'ReTech Electronics',
      authorized: true,
      ratePerKg: 125,
      distanceKm: 2.6,
      pickupAvailable: true,
      acceptsMaterial: 'Mobile Phone',
      isBestMatch: false,
    ),
  ];

  static List<RecyclerData> rankedForMaterial(String material) {
    final matches = all
        .where((r) => r.acceptsMaterial == material)
        .toList();

    matches.sort((a, b) {
      // 1. Higher price
      if (a.ratePerKg != b.ratePerKg) {
        return b.ratePerKg.compareTo(a.ratePerKg);
      }

      // 2. Pickup available
      if (a.pickupAvailable != b.pickupAvailable) {
        return a.pickupAvailable ? -1 : 1;
      }

      // 3. Nearest recycler
      return a.distanceKm.compareTo(b.distanceKm);
    });

    return matches;
  }
}

class RecyclerData {
  final String id;
  final String name;
  final bool authorized;
  final int ratePerKg;
  final double distanceKm;
  final bool pickupAvailable;
  final String acceptsMaterial;
  final bool isBestMatch;

  const RecyclerData({
    required this.id,
    required this.name,
    required this.authorized,
    required this.ratePerKg,
    required this.distanceKm,
    required this.pickupAvailable,
    required this.acceptsMaterial,
    required this.isBestMatch,
  });
}

class MockPrices {
  static const List<PriceEntry> all = [
    PriceEntry(material: 'Copper Wire',  ratePerKg: 600, trend: 1),
    PriceEntry(material: 'Aluminium',    ratePerKg: 180, trend: 0),
    PriceEntry(material: 'Brass',        ratePerKg: 420, trend: 1),
    PriceEntry(material: 'Iron',         ratePerKg: 35,  trend: -1),
    PriceEntry(material: 'PCB Boards',   ratePerKg: 250, trend: 0),
    PriceEntry(material: 'Lead Battery', ratePerKg: 95,  trend: -1),
  ];
}

class PriceEntry {
  final String material;
  final int ratePerKg;
  final int trend; // 1 = up, 0 = stable, -1 = down

  const PriceEntry({
    required this.material,
    required this.ratePerKg,
    required this.trend,
  });
}

// ── Transaction model ────────────────────────────────────────────────────

class HandoverTransaction {
  final String receiptId;
  final String material;
  final double weightKg;
  final double ratePerKg;
  final double amount;
  final String recyclerName;
  final DateTime timestamp;
  final bool syncedOnline;

  const HandoverTransaction({
    required this.receiptId,
    required this.material,
    required this.weightKg,
    required this.ratePerKg,
    required this.amount,
    required this.recyclerName,
    required this.timestamp,
    required this.syncedOnline,
  });

  factory HandoverTransaction.seed({
    required String receiptId,
    required String material,
    required double weightKg,
    required double ratePerKg,
    required String recyclerName,
    required DateTime timestamp,
    bool syncedOnline = true,
  }) {
    return HandoverTransaction(
      receiptId: receiptId,
      material: material,
      weightKg: weightKg,
      ratePerKg: ratePerKg,
      amount: weightKg * ratePerKg,
      recyclerName: recyclerName,
      timestamp: timestamp,
      syncedOnline: syncedOnline,
    );
  }
}

// ── Per-material mock rates ──────────────────────────────────────────────────

/// Returns the mock rate (₹/kg) for a given display label.
double rateForMaterial(String displayLabel) {
  const rates = {
    // TFLite / manual labels
    'Copper Wire': 600.0,
    'Aluminium': 180.0,
    'Brass': 420.0,
    'Iron': 35.0,
    'PCB / E-Waste': 250.0,
    'Battery': 95.0,
    // Backend display_name values
    'PCB': 250.0,
    'Metal Scrap': 40.0,
    'Mobile Phone': 120.0,
  };
  return rates[displayLabel] ?? 0.0;
}

// ── Selectable materials for manual override ─────────────────────────────────

/// All materials available for manual selection (picker bottom sheet).
const List<String> allSelectableMaterials = [
  'Copper Wire',
  'Aluminium',
  'Brass',
  'Iron',
  'PCB / E-Waste',
  'Battery',
  'Metal Scrap',
  'Mobile Phone',
];
