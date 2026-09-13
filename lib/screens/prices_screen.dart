import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../mock_data.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final prices = MockPrices.all
        .where((p) =>
            _query.isEmpty ||
            p.material.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _BackBtn(),
        title: Text("Today's Scrap Prices",
            style: AppTypography.sectionHeading),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mintSurface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.mintCard),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Icon(Icons.search_rounded,
                          color: AppColors.mutedGrey, size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search material…',
                          hintStyle: AppTypography.body
                              .copyWith(color: AppColors.mutedGrey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Updated info row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 13, color: AppColors.mutedGrey),
                  const SizedBox(width: 4),
                  Text('Updated today at 9:00 AM',
                      style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Price list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding),
                itemCount: prices.length,
                separatorBuilder: (_, _) => const Divider(
                  color: AppColors.mintCard,
                  height: 1,
                ),
                itemBuilder: (_, i) => _PriceRow(entry: prices[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.entry});
  final PriceEntry entry;

  @override
  Widget build(BuildContext context) {
    final trendColor = entry.trend > 0
        ? AppColors.primaryGreen
        : entry.trend < 0
            ? const Color(0xFFE53E3E)
            : AppColors.mutedGrey;
    final trendIcon = entry.trend > 0
        ? Icons.trending_up_rounded
        : entry.trend < 0
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          CircleIconContainer(
            icon: Icons.recycling_rounded,
            size: 44,
            iconSize: 22,
            backgroundColor: AppColors.mintCard,
            iconColor: AppColors.darkGreen,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              entry.material,
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.nearBlack,
                fontSize: 15,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${entry.ratePerKg}/kg',
                style: AppTypography.sectionHeading.copyWith(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, color: trendColor, size: 13),
                  const SizedBox(width: 2),
                  Text(
                    entry.trend > 0
                        ? 'Up'
                        : entry.trend < 0
                            ? 'Down'
                            : 'Stable',
                    style: AppTypography.caption.copyWith(color: trendColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.mintCard,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkGreen, size: 18),
      ),
    );
  }
}
