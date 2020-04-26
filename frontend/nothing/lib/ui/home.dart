import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nothing/hooks/pagecontroller.dart';
import 'package:nothing/model/focusnode.dart';
import 'package:nothing/ui/menu.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nothing/bloc/ad/bloc.dart';
import 'package:nothing/bloc/coin/bloc.dart';
import 'package:nothing/bloc/feed/bloc.dart';
import 'package:nothing/bloc/validation/bloc.dart';
import 'package:nothing/color/scheme.dart';
import 'package:nothing/domain/domain.dart' as domain;
import 'package:nothing/ignitor/ignitor.dart';
import 'package:nothing/model/text.dart';
import 'package:nothing/ui/cointext.dart';
import 'package:nothing/ui/history.dart';
import 'package:nothing/ui/answer.dart';
import 'package:nothing/ui/knob.dart';
import 'package:nothing/ui/label.dart';
import 'package:nothing/ui/question.dart';

// TODO(refactor)
class Home extends HookWidget {
  const Home();

  @override
  Widget build(BuildContext context) {
    final focusNodeModel = FocusNodeModel(useFocusNode());
    final swipeTintController = useAnimationController();
    final pageController = usePageController(initialPage: 1);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => focusNodeModel.refocus(),
      );
      return null;
    });

    return ScopedModel<FocusNodeModel>(
      model: focusNodeModel,
      child: Scaffold(
        backgroundColor: NothingScheme.of(context).background,
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification(swipeTintController),
          child: PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged(context),
            children: () {
              const duration = Duration(milliseconds: 300);
              const curve = Curves.easeInOut;
              void onBack() {
                pageController.animateToPage(1,
                    duration: duration, curve: curve);
              }

              return [
                Menu(onBack),
                _buildMain(context, swipeTintController),
                History(onBack)
              ];
            }(),
          ),
        ),
      ),
    );
  }

  bool Function(ScrollNotification) _onScrollNotification(
    AnimationController swipeTintController,
  ) {
    return (scrollNotification) {
      if (scrollNotification is ScrollUpdateNotification) {
        final metrics = scrollNotification.metrics;
        final offset = (metrics.viewportDimension - metrics.pixels).abs();
        final value = (offset / metrics.viewportDimension).clamp(0.0, 1.0);
        swipeTintController.value = value;
        swipeTintController.notifyListeners();
      }
      return false;
    };
  }

  void Function(int) _onPageChanged(BuildContext context) {
    final focusNodeModel = FocusNodeModel.of(context);
    return (i) {
      switch (i) {
        case 1:
          focusNodeModel.refocus();
          break;
        default:
          focusNodeModel.focusNode.unfocus();
      }
    };
  }

  Widget _buildMain(
    BuildContext context,
    AnimationController swipeTintController,
  ) {
    final textModel = useMemoized(() => TextModel());
    final hintTintController = useAnimationController();
    final textController = useTextEditingController();

    return Container(
      color: NothingScheme.of(context).background,
      child: ScopedModel<TextModel>(
        model: textModel,
        child: Stack(
          children: [
            _buildGame(context),
            _gestureDetector(context),
            _buildTitleKnobs(context),
            _buildHintButtons(context),
            _buildTinter(context, hintTintController),
            if (_showHint) _buildHint(context),
            _buildTinter(context, swipeTintController),
            BlocListener<ValidationBloc, ValidationState>(
              // TODO here
              child: _inputPoint(textModel),
              listener: (context, state) {
                state.maybeWhen(
                  just: (just) => just.maybeMap(
                    orElse: () {
                      textController.clear();
                      textModel.update('');
                    },
                    neutral: (_) {},
                  ),
                  orElse: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IgnorePointer _buildTinter(
    BuildContext context,
    AnimationController controller,
  ) {
    final anim = ColorTween(
      begin: Colors.black.withOpacity(0.0),
      end: Colors.black.withOpacity(0.1),
    ).animate(CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller,
    ));
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Container(
          color: anim.value,
        ),
      ),
    );
  }

  Widget _gestureDetector(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // child: Container(color: Colors.green.withOpacity(0.3)),
          onTap: FocusNodeModel.of(context).refocus,
        ),
      ),
    );
  }

  Widget _inputPoint(TextModel model) {
    return Visibility(
      visible: false,
      maintainState: true,
      child: TextField(
        focusNode: _focusNode,
        controller: _textController,
        enableSuggestions: false,
        autocorrect: false,
        maxLength: 32,
        keyboardAppearance: NothingScheme.of(context).brightness,
        keyboardType: TextInputType.text,
        onSubmitted: (s) async {
          print(s);
          _focusNode.requestFocus();
          if (s.isNotEmpty) {
            context.bloc<ValidationBloc>().add(ValidationEvent.check(s));
          }
          // model.update(s);
          // if (true) {
          //   // clear
          //   _controller.clear();
          //   model.update('');
          //   // Vibrate.feedback(FeedbackType.success);
          // } else {
          //   // dont clear
          //   // Vibrate.feedback(FeedbackType.warning);
          // }
        },
        textInputAction: TextInputAction.go,
        onChanged: (s) {
          model.update(s);
          print(s);
        },
      ),
    );
  }

  var _showHint = false;
  Widget _buildHint(BuildContext context) {
    return SafeArea(child: LayoutBuilder(builder: (context, constraints) {
      final top = labelH + 24; //+ 21 + 28 + 8 + 12;
      double hei = min(
        280,
        constraints.biggest.height - (labelH + ansH + 21 + 28 + 12 + 8),
      );
      hei += labelH + ansH - 20;
      const hor = 20.0;
      return Stack(children: [
        Positioned(
          top: top,
          left: hor,
          right: hor,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: hei,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: BlocBuilder<FeedBloc, Ignitable<FeedState>>(
                          builder: (context, state) => AutoSizeText(
                            state.payload.when(
                              available: (tree) => tree.question.explanation,
                              empty: () => '',
                            ),
                            maxLines: 4,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.bottomCenter,
                    child: FlatButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 36,
                      ),
                      color: NothingScheme.of(context).knob,
                      child: Text('Close', style: TextStyle(fontSize: 16)),
                      onPressed: () {
                        //TODO(hint)
                        setState(() {
                          _showHint = false;
                        });
                        _hintTintController.fling(velocity: -1);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: NothingScheme.of(context).hintBorder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);
    }));
  }

  Widget _buildTitleKnobs(BuildContext context) {
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOut;
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _makeKnob(
            Icons.short_text,
            () => _pageController.animateToPage(0,
                duration: duration, curve: curve),
          ),
          _makeKnob(
            Icons.all_inclusive,
            () => _pageController.animateToPage(2,
                duration: duration, curve: curve),
          ),
        ],
      ),
    );
  }

  Widget _buildHintButtons(BuildContext context) {
    return SafeArea(child: LayoutBuilder(
      builder: (context, constraints) {
        double queH = min(
          280,
          constraints.biggest.height - (labelH + ansH + 21 + 28 + 8 + 12),
        );
        const pad = 8;
        const hor = 40.0;
        final top = queH + labelH + ansH + pad;
        text(String text) =>
            Text(text, style: TextStyle(color: Colors.white, fontSize: 18));
        const ll = {'hint': 'Хинт', 'skip': 'Скип'};
        final cc = {
          'hint': NothingScheme.of(context).hint,
          'skip': NothingScheme.of(context).skip,
        };
        final ii = {'hint': Icons.lightbulb_outline, 'skip': Icons.clear};
        final pp = {
          'hint': () => _hintClick(context),
          'skip': () {},
        };
        final bb = ['hint', 'skip']
            .map(
          (l) => Expanded(
            child: FlatButton(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              color: cc[l],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ii[l],
                    size: 24,
                    color: Colors.white,
                  ),
                  // SizedBox(width: 4),
                  text(ll[l]),
                ],
              ),
              onPressed: pp[l],
              shape: RoundedRectangleBorder(
                borderRadius: NothingScheme.of(context).hintBorder,
              ),
            ),
          ),
        )
            .expand((w) sync* {
          yield w;
          yield const SizedBox(width: 16);
          // yield Container(width: 16, height: 10, color: Colors.red);
        });
        return Stack(
          children: [
            Positioned(
              top: top,
              left: hor,
              right: hor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ...bb,
                  Row(children: [
                    CircleAvatar(
                        backgroundColor: NothingScheme.of(context).knob,
                        foregroundColor: Colors.black,
                        child: Icon(Icons.vpn_key)),
                    SizedBox(width: 4),
                    CoinText(),
                  ]),
                ],
              ),
            ),
          ],
        );
      },
    ));
  }

  // TODO(hint)
  void _hintClick(BuildContext context) async {
    setState(() {
      _showHint = true;
      _hintTintController.fling();
    });
    context.bloc<CoinBloc>().add(CoinEvent.dec(2));
  }

  // InterstitialAd myInterstitial;

  void _createAd() {
    final myInterstitial = InterstitialAd(
      // adUnitId: Platform.isIOS // interstitial ios/android
      //     ? 'ca-app-pub-3169956978186495/7272148845'
      //     : 'ca-app-pub-3169956978186495/2443683360',
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: MobileAdTargetingInfo(),
      listener: (MobileAdEvent event) async {
        // event.
        print("InterstitialAd event is $event");
        if (event == MobileAdEvent.loaded) {
          // await myInterstitial.show(
          //   anchorType: AnchorType.bottom,
          //   anchorOffset: 0.0,
          //   horizontalCenterOffset: 0.0,
          // );
        }
        if (event == MobileAdEvent.closed) {
          print("CLOSED");
          // context.bloc<CoinBloc>().add(CoinEvent.inc(3));
          await myInterstitial.load();
        }
      },
    );
  }

  void _showAd(BuildContext context) async {
    context.bloc<AdBloc>().add(AdEvent.report(domain.AdType.interstitial));
    print('****** Loading new ad');
    final result = await myInterstitial.load();
    if (!result) {
      print('\t ****** Ad did not load');
      return;
    }
    print('****** Loaded ad successfully');
    await myInterstitial.show(
      anchorType: AnchorType.bottom,
      anchorOffset: 0.0,
      horizontalCenterOffset: 0.0,
    );
    // myInterstitial.dispose()
  }

  double labelH = 50;
  double ansH = 72;
  Widget _buildGame(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double queH = min(
            280,
            constraints.biggest.height - (labelH + ansH + 21 + 28 + 8 + 12),
          );
          return Column(children: [
            SizedBox(height: 21),
            SizedBox(child: Label()),
            SizedBox(height: 12),
            SizedBox(height: queH, child: Center(child: Question())),
            SizedBox(height: ansH, child: Answer()),
          ]);
        },
      ),
    );
  }

  Widget _makeKnob(IconData icon, [Function onPress]) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      child: Knob(icon, onPress),
    );
  }
}
