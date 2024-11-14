# media-proxy-rs
## misskey/cherrypick用メディアプロキシのrust実装
機能的には互換性を維持しつつ、apngとavif対応に  
ほとんどの画像読み書きに[image crate v0.25.2](https://crates.io/crates/image/0.25.2)を使用しています

## 設定ファイル
環境変数`MEDIA_PROXY_CONFIG_PATH`を設定する事でファイルの場所を指定できます  
デフォルト値は`$(pwd)/config.json`です  
十分に強力なマシンでは`encode_avif`を`true`に変更することでAVIFエンコードを利用する事ができます

## target support
- [x] x86_64-unknown-linux-musl
- [x] aarch64-unknown-linux-musl
- [x] armv7-unknown-linux-musleabihf
- [x] arm-unknown-linux-musleabihf
- [x] i686-unknown-linux-musl
- [ ] riscv64gc-unknown-linux-musl

## ビルド(x64/aarch64 Docker)
Dockerを使用する場合はbuildxとqemuによるクロスコンパイルが利用できます  
ビルド対象プラットフォームはtarget supportの項目を参照してください
Dockerビルドで生成されるバイナリはmuslとstdc++に依存します
1. `git clone --recursive https://github.com/yojo-art/media-proxy-rs && cd media-proxy-rs`
2. `docker build -t media-proxy-rs .`

## ビルド(x64 Debian系)
この方法では`x86_64-unknown-linux-gnu`向けにビルドします  
musl系とは異なる共有ライブラリを必要とする場合があります
1. https://www.rust-lang.org/ja/tools/install に従ってrustをインストール
2. `apt-get install -y meson ninja-build pkg-config nasm git clang cmake`
3. `git clone --recursive https://github.com/yojo-art/media-proxy-rs && cd media-proxy-rs`
4. `cargo build --release`

#License
このプロジェクトのライセンスはLICENSEファイルに従います
依存関係にLGPLv3のプロジェクトを含むため、ビルド済バイナリはLGPLv3で配布されます
