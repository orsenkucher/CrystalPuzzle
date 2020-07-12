import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'ignitor.freezed.dart';

@freezed
abstract class Ignitable<S> with _$Ignitable<S> {
  factory Ignitable.ignited(S payload) = Ignited<S>;
  factory Ignitable.pending(S payload) = Pending<S>;
}

abstract class IgnitedBloc<Event, State> extends HydratedBloc<Event, Ignitable<State>> {
  IgnitedBloc(State initialPayload) : super(Ignitable.pending(initialPayload)) {
    ignition(state.payload);
  }

  void ignition(State paylaod);
  State get payload => state.payload;

  dynamic payloadToJson(State payload);
  State payloadFromJson(dynamic json);
  Stream<State> mapEventToPayload(Event event);

  @override
  @nonVirtual
  Stream<Ignitable<State>> mapEventToState(Event event) {
    return mapEventToPayload(event).map((pl) => Ignitable.ignited(pl));
  }

  @override
  @nonVirtual
  Map<String, dynamic> toJson(Ignitable<State> state) {
    return {
      'payload': payloadToJson(state.payload),
      'runtimeType': state.when(
        ignited: (_) => 'ignited',
        pending: (_) => 'pending',
      ),
    };
  }

  @override
  @nonVirtual
  Ignitable<State> fromJson(Map<String, dynamic> json) {
    final pl = payloadFromJson(json['payload']);
    // final pl = payloadFromJson(Map<String, dynamic>.from(json['payload']));
    switch (json['runtimeType'] as String) {
      case 'ignited':
        return Ignitable.ignited(pl);
      case 'pending':
        return Ignitable.pending(pl);
      default:
        throw FallThroughError();
    }
  }
}
