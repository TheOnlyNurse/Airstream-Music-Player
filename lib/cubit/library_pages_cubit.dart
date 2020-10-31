/// External Packages
import 'package:bloc/bloc.dart';

class LibraryPagesCubit extends Cubit<int> {
  LibraryPagesCubit() : super(0);

  void pageIndex(int index) => emit(index);
}
