import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nothing/bloc/feed/bloc.dart';
import 'package:nothing/bloc/summary/bloc.dart';
import 'package:nothing/color/scheme.dart';
import 'package:nothing/data/model/question.dart';
import 'package:nothing/ui/cards.dart';

// Bind to dataflow and tune Cards widget
class CardsMaster extends StatelessWidget {
  const CardsMaster({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => BlocBuilder<FeedBloc, Feed>(
        builder: (context, state) => Cards(
          feed: state,
          contentfactory: (ctx, que, anim, dirsgn) =>
              NothingContent(que, anim, dirsgn),
          materialfactory: (ctx, cnt, anim, dirsgn, shadow) =>
              NothingMaterial(cnt, anim, dirsgn, shadow),
          heightFactor: 0.9,
          widthFactor: 0.85,
          stack: 1,
          size: box.biggest,
          onswipe: (context, q, b) {
            print('[${q.id}] ${q.question} -> $b');
            BlocProvider.of<FeedBloc>(context).add(const MoveNext());
            BlocProvider.of<SummaryBloc>(context).add(
              NewAnswer(id: q.id, answer: b),
            );
          },
        ),
      ),
    );
  }
}

class NothingContent extends StatelessWidget {
  final Question question;
  final double dirsgn;
  final Animation<double> animation;

  const NothingContent(this.question, this.animation, this.dirsgn);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: AutoSizeText(
                question.question,
                maxLines: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: NothingScheme.of(context).question,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xfffdcf3c),
              borderRadius: BorderRadius.circular(28),
            ),
            height: 70,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: IconButton(
                      onPressed: () => print("Press"),
                      icon: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: AutoSizeText(
                    "123123",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: NothingScheme.of(context).question,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NothingMaterial extends AnimatedWidget {
  final Widget content;
  final double dirsgn;
  final Shadow shadow;
  final Animation<double> animation;

  const NothingMaterial(
    this.content,
    this.animation,
    this.dirsgn,
    this.shadow, {
    Key key,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final scheme = NothingScheme.of(context);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuad,
    );
    // const borderWidth = 1.5;
    // var borderSide = BorderSide(color: scheme.cardborder, width: borderWidth);
    const borderRadius = const BorderRadius.all(Radius.circular(28));
    // const shcase = {Shadow.min: 0.0, Shadow.tween: 0.0, Shadow.max: 7.0};
    return Material(
      shadowColor: scheme.shadow,
      color: scheme.card,
      // shape: RoundedRectangleBorder(
      //   side: borderSide,
      //   borderRadius: borderRadius,
      // ),
      borderRadius: borderRadius,
      // elevation: shadow == Shadow.tween
      //     ? Tween<double>(
      //         begin: shcase[Shadow.min],
      //         end: shcase[Shadow.max],
      //       ).animate(curved).value
      //     : shcase[shadow],
      // elevation: shcase[shadow],
      child: content,
    );
  }
}

class TextTransition extends AnimatedWidget {
  final Animation<double> controller;
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Animation<Color> color;

  const TextTransition({
    Key key,
    @required this.controller,
    @required this.text,
    @required this.fontSize,
    @required this.fontWeight,
    @required this.color,
  }) : super(key: key, listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color.value,
      ),
    );
  }
}
