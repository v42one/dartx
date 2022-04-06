Pub Tidy

[![pub package](https://img.shields.io/pub/v/pubtidy.svg)](https://pub.dev/packages/pubtidy)

Package Layout is following https://dart.dev/tools/pub/package-layout

```
lib/
    src/
        a/
        b/
    a.dart # generated with `export` files under `src/a/` 
    b.dart # generated with `export` files under `src/b/`
```

* only generate entry file for the first level under `lib/src/`, all sub paths will be included.
* path starts with `_` as private will be excluded.

Or flutter layout

```
lib/
    domain/
        a/
        a.dart # generated with `export` files under `domain/a/` 
    view/
        a/
        a.dart # generated with `export` files under `view/a/` 
    main.dart        
```