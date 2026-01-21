import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/ai_ticket_analysis_dto.dart';
import '../../domain/services/ai_ticket_service_interface.dart';

class AiTicketService implements AiTicketServiceInterface {
  AiTicketService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<String, AiTicketAnalysisDto>> analyzeDescription(
    String description,
  ) async {
    try {
      if (description.trim().isEmpty) {
        return const Left('Description cannot be empty');
      }

      final analysis = await _apiClient.analyzeTicketDescription(description);
      return Right(analysis);
    } on Exception catch (e) {
      return Left('Failed to analyze description: ${e.toString()}');
    } catch (e) {
      return Left('Failed to analyze description: ${e.toString()}');
    }
  }
}
