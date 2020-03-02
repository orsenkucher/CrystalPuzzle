import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nothing/bloc/feed/bloc.dart';
import 'package:nothing/bloc/id/bloc.dart';
import 'package:nothing/bloc/questions/bloc.dart';
import 'package:nothing/bloc/summary/bloc.dart';
import 'package:nothing/bloc/test.dart';
import 'package:nothing/bloc/validation/bloc.dart';
import 'package:nothing/bloc/history/bloc.dart';
import 'package:nothing/color/scheme.dart';
import 'package:nothing/delegate/delegate.dart';
import 'package:nothing/repository/questions.dart';
import 'package:nothing/tools/orientation.dart';
import 'package:nothing/ui/home.dart';

void main() async {
  await _hydrateAsync();
  if (Platform.isIOS) SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(const App());
}

Future _hydrateAsync() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await NothingBlocDelegate.build();
}

class App extends StatelessWidget with PortraitLock {
  const App();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _nestBlocs(
      MaterialApp(
        title: 'NOTHING 2',
        theme: ThemeData(
          fontFamily: 'Gilroy',
        ),
        home: NothingScheme(
          child: Home(),
        ),
        color: NothingScheme.app,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Widget _nestBlocs(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TestBloc>(
          create: (context) => TestBloc(),
        ),
        BlocProvider<IdBloc>(
          create: (context) => IdBloc(),
        ),
        BlocProvider<ValidationBloc>(
          create: (context) => ValidationBloc(),
        ),
        BlocProvider<SummaryBloc>(
          create: (context) => SummaryBloc(
            validation: BlocProvider.of<ValidationBloc>(context),
          ),
        ),
        BlocProvider<QuestionsBloc>(
          create: (context) => QuestionsBloc(
            summaryBloc: BlocProvider.of<SummaryBloc>(context),
            idBloc: BlocProvider.of<IdBloc>(context),
            repo: CloudQuestionsRepo(), // CloudQuestionsRepo LocalQuestionsRepo
          ),
        ),
        BlocProvider<FeedBloc>(
          create: (context) => FeedBloc(
            questionsBloc: BlocProvider.of<QuestionsBloc>(context),
            validationBloc: BlocProvider.of<ValidationBloc>(context),
          ),
        ),
        BlocProvider<HistoryBloc>(
          create: (context) => HistoryBloc(
            validation: BlocProvider.of<ValidationBloc>(context),
          ),
        ),
      ],
      child: child,
    );
  }
}
