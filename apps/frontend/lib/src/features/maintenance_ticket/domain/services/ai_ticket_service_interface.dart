import 'package:fpdart/fpdart.dart';

import '../../data/dto/ai_ticket_analysis_dto.dart';

abstract class AiTicketServiceInterface {
  Future<Either<String, AiTicketAnalysisDto>> analyzeDescription(
    String description,
  );
}
