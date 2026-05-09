import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/home_repository.dart';

class GetSearchSuggestionsUseCase extends UseCase<List<String>, NoParams> {
  final HomeRepository _repository;
  GetSearchSuggestionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      _repository.getSearchSuggestions();
}
