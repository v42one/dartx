Pub Tidy

[![pub package](https://img.shields.io/pub/v/pubtidy.svg)](https://pub.dev/packages/pubtidy)

```
lib/
    src/
        a/
            sub/
            sub.dart # generated with `export` files under `src/sub/`
        b/
    a.dart # generated with `export` files under `src/a/` 
    b.dart # generated with `export` files under `src/b/`
```

* path starts with `_` as private will be excluded.
* only generate entry file for the first level under `lib/`.
