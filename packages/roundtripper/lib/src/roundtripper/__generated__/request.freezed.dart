// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of '../request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$RequestTearOff {
  const _$RequestTearOff();

  _Request<T> call<T>(
      {required String method,
      required Uri uri,
      Map<String, dynamic>? headers,
      T? body,
      Stream<List<int>>? requestBody}) {
    return _Request<T>(
      method: method,
      uri: uri,
      headers: headers,
      body: body,
      requestBody: requestBody,
    );
  }
}

/// @nodoc
const $Request = _$RequestTearOff();

/// @nodoc
mixin _$Request<T> {
  String get method => throw _privateConstructorUsedError;
  Uri get uri => throw _privateConstructorUsedError;
  Map<String, dynamic>? get headers => throw _privateConstructorUsedError;
  T? get body => throw _privateConstructorUsedError;
  Stream<List<int>>? get requestBody => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RequestCopyWith<T, Request<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestCopyWith<T, $Res> {
  factory $RequestCopyWith(Request<T> value, $Res Function(Request<T>) then) =
      _$RequestCopyWithImpl<T, $Res>;
  $Res call(
      {String method,
      Uri uri,
      Map<String, dynamic>? headers,
      T? body,
      Stream<List<int>>? requestBody});
}

/// @nodoc
class _$RequestCopyWithImpl<T, $Res> implements $RequestCopyWith<T, $Res> {
  _$RequestCopyWithImpl(this._value, this._then);

  final Request<T> _value;
  // ignore: unused_field
  final $Res Function(Request<T>) _then;

  @override
  $Res call({
    Object? method = freezed,
    Object? uri = freezed,
    Object? headers = freezed,
    Object? body = freezed,
    Object? requestBody = freezed,
  }) {
    return _then(_value.copyWith(
      method: method == freezed
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      uri: uri == freezed
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as Uri,
      headers: headers == freezed
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      body: body == freezed
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as T?,
      requestBody: requestBody == freezed
          ? _value.requestBody
          : requestBody // ignore: cast_nullable_to_non_nullable
              as Stream<List<int>>?,
    ));
  }
}

/// @nodoc
abstract class _$RequestCopyWith<T, $Res> implements $RequestCopyWith<T, $Res> {
  factory _$RequestCopyWith(
          _Request<T> value, $Res Function(_Request<T>) then) =
      __$RequestCopyWithImpl<T, $Res>;
  @override
  $Res call(
      {String method,
      Uri uri,
      Map<String, dynamic>? headers,
      T? body,
      Stream<List<int>>? requestBody});
}

/// @nodoc
class __$RequestCopyWithImpl<T, $Res> extends _$RequestCopyWithImpl<T, $Res>
    implements _$RequestCopyWith<T, $Res> {
  __$RequestCopyWithImpl(_Request<T> _value, $Res Function(_Request<T>) _then)
      : super(_value, (v) => _then(v as _Request<T>));

  @override
  _Request<T> get _value => super._value as _Request<T>;

  @override
  $Res call({
    Object? method = freezed,
    Object? uri = freezed,
    Object? headers = freezed,
    Object? body = freezed,
    Object? requestBody = freezed,
  }) {
    return _then(_Request<T>(
      method: method == freezed
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      uri: uri == freezed
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as Uri,
      headers: headers == freezed
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      body: body == freezed
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as T?,
      requestBody: requestBody == freezed
          ? _value.requestBody
          : requestBody // ignore: cast_nullable_to_non_nullable
              as Stream<List<int>>?,
    ));
  }
}

/// @nodoc

class _$_Request<T> extends _Request<T> {
  _$_Request(
      {required this.method,
      required this.uri,
      this.headers,
      this.body,
      this.requestBody})
      : super._();

  @override
  final String method;
  @override
  final Uri uri;
  @override
  final Map<String, dynamic>? headers;
  @override
  final T? body;
  @override
  final Stream<List<int>>? requestBody;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Request<T> &&
            const DeepCollectionEquality().equals(other.method, method) &&
            const DeepCollectionEquality().equals(other.uri, uri) &&
            const DeepCollectionEquality().equals(other.headers, headers) &&
            const DeepCollectionEquality().equals(other.body, body) &&
            const DeepCollectionEquality()
                .equals(other.requestBody, requestBody));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(method),
      const DeepCollectionEquality().hash(uri),
      const DeepCollectionEquality().hash(headers),
      const DeepCollectionEquality().hash(body),
      const DeepCollectionEquality().hash(requestBody));

  @JsonKey(ignore: true)
  @override
  _$RequestCopyWith<T, _Request<T>> get copyWith =>
      __$RequestCopyWithImpl<T, _Request<T>>(this, _$identity);
}

abstract class _Request<T> extends Request<T> {
  factory _Request(
      {required String method,
      required Uri uri,
      Map<String, dynamic>? headers,
      T? body,
      Stream<List<int>>? requestBody}) = _$_Request<T>;
  _Request._() : super._();

  @override
  String get method;
  @override
  Uri get uri;
  @override
  Map<String, dynamic>? get headers;
  @override
  T? get body;
  @override
  Stream<List<int>>? get requestBody;
  @override
  @JsonKey(ignore: true)
  _$RequestCopyWith<T, _Request<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
