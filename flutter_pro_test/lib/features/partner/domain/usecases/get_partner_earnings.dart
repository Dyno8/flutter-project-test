import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/partner_earnings.dart';
import '../repositories/partner_job_repository.dart';

/// Use case for getting partner earnings
class GetPartnerEarnings implements UseCase<PartnerEarnings, GetPartnerEarningsParams> {
  final PartnerJobRepository repository;

  GetPartnerEarnings(this.repository);

  @override
  Future<Either<Failure, PartnerEarnings>> call(GetPartnerEarningsParams params) async {
    return await repository.getPartnerEarnings(params.partnerId);
  }
}

class GetPartnerEarningsParams {
  final String partnerId;

  GetPartnerEarningsParams({required this.partnerId});
}

/// Use case for getting earnings by date range
class GetEarningsByDateRange implements UseCase<List<DailyEarning>, GetEarningsByDateRangeParams> {
  final PartnerJobRepository repository;

  GetEarningsByDateRange(this.repository);

  @override
  Future<Either<Failure, List<DailyEarning>>> call(GetEarningsByDateRangeParams params) async {
    return await repository.getEarningsByDateRange(
      params.partnerId,
      params.startDate,
      params.endDate,
    );
  }
}

class GetEarningsByDateRangeParams {
  final String partnerId;
  final DateTime startDate;
  final DateTime endDate;

  GetEarningsByDateRangeParams({
    required this.partnerId,
    required this.startDate,
    required this.endDate,
  });
}
