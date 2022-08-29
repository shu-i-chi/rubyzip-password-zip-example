# rubyzip gemでパスワード付きZIPを作成する例

[rubyzip gem](https://github.com/rubyzip/rubyzip)を使って、パスワードなし/付きZIPファイルを作成するモジュールの、サンプル実装です。
`ZipGenerator`というモジュールを実装しています。

実装したモジュール・メソッドの詳細は、[[Ruby] rubyzipでパスワード付きZIPファイル（良くないけど）を作成する（Zenn）](https://zenn.dev/shuichi/articles/ruby-rubyzip-password-zip)を確認してください。

（リンク先で説明していますが、まずは[「そもそも**パスワード付きZIPファイルの使用は非推奨！**」](https://zenn.dev/shuichi/articles/ruby-rubyzip-password-zip#%E3%81%BE%E3%81%9A%E3%81%AF%E3%83%91%E3%82%B9%E3%83%AF%E3%83%BC%E3%83%89%E4%BB%98%E3%81%8Dzip%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E4%BD%BF%E7%94%A8%E4%B8%AD%E6%AD%A2%E3%82%92%E6%A4%9C%E8%A8%8E%E3%81%97%E3%82%88%E3%81%86)ということをご認識ください。）

### このリポジトリでできること

* モジュールのサンプル実装の確認（lib/ディレクトリ配下）

  * `ZipGenerator`モジュールを実装しています

* 動作確認サンプルプログラムの確認・実行（example.rb）

  * `ZipGenerator`モジュールの使い方を確認できます

* モジュールのYARDドキュメントの生成・閲覧

  * メソッドの詳細を確認できます

### バージョン

Ruby 3.1.2, rubyzip 2.3で動作確認をしています。

## 目次

* [デプロイ方法](#デプロイ方法)

  * [YARDドキュメントを生成する場合](#YARDドキュメントを生成する場合)

  * [YARDドキュメントを生成しない場合](#YARDドキュメントを生成しない場合)

    * [`bundle install --without`オプションは非推奨](#bundle-install---withoutオプションは非推奨)

* [動作確認サンプルプログラムを実行する](#動作確認サンプルプログラムを実行する)

* [YARDドキュメントを見るには](#yardドキュメントを見るには)

* [ディレクトリ構成](#ディレクトリ構成)

## デプロイ方法

まずは、このGitリポジトリを`git clone`し、クローンされたディレクトリ内に移動します：

```bash
$ git clone https://github.com/shu-i-chi/rubyzip-password-zip-example.git
# （出力は省略）

$ cd rubyzip-password-zip-example/
```

このあと`bundle install`しますが、「YARDドキュメントを生成するか否か」で分岐します：

### YARDドキュメントを生成する場合

特段何のオプションもつけずに`bundle install`してください。

```bash
$ bundle install
# （出力は省略）
```

### YARDドキュメントを生成しない場合

Gemfileにて[YARD](https://github.com/lsegal/yard) gemを`development`グループに指定しています。

というわけで、このグループを除外して`bundle install`するようにします。

```bash
$ bundle config set --local without 'development'
# => .bundle/configファイルが生成され、除外設定が書き込まれる

$ bundle install
```

#### `bundle install --without`オプションは非推奨

将来の変更にて、`bundle install`につけて実行->裏で設定を記憶する系のオプションは、廃止予定です。（BundlerがCLIフラグを記憶しないようになる。）

> The --clean, --deployment, --frozen, --no-prune, --path, --shebang, --system, --without and --with options are deprecated because they only make sense if they are applied to every subsequent bundle install run automatically and that requires bundler to silently remember them. Since bundler will no longer remember CLI flags in future versions, bundle config (see [bundle-config(1)](https://bundler.io/man/bundle-config.1.html)) should be used to apply them permanently.

* [bundle install > OPTIONS（Bundler Docs）](https://bundler.io/man/bundle-install.1.html#OPTIONS)

`bundle config`コマンドで設定を行うようにしましょう。

* [bundle config（Bundler Docs）](https://bundler.io/man/bundle-config.1.html)

## 動作確認サンプルプログラムを実行する

example.rbというファイルが、`ZipGenerator`モジュールを使用するサンプルのプログラムになっています。

トップディレクトリで、以下のようにして実行してください：

```bash
$ bundle exec ruby example.rb
EXAMPLE 1. -- ZipGenerator.get_zip_buffer
 > ZIPファイル [ tmp/zipfile_buffer.zip ] を作成
 > パスワード付きZIPファイル [ tmp/zipfile_buffer_pw.zip ] を作成（パスワード：buffer）

EXAMPLE 2. -- ZipGenerator.get_zip_tempfile
 > ZIPファイル [ tmp/zipfile_tempfile.zip ] を作成
 > パスワード付きZIPファイル [ tmp/zipfile_tempfile_pw.zip ] を作成（パスワード：tempfile）

EXAMPLE 3. -- ZipGenerator.zip_archive
 > ZIPファイル [ tmp/zipfile_file.zip ] を作成
 > パスワード付きZIPファイル [ tmp/zipfile_file_pw.zip ] を作成（パスワード：file）
```

tmp/ディレクトリ配下にZIPファイルが作成されます。

ZIPファイルの解凍をしてみたり、example.rbのZIPファイルのパスワードを変更してみたり、エラーが出るようにしてみたりなどを試してみてください。

## YARDドキュメントを見るには

トップディレクトリで、以下のコマンドを実行します（まとめて`bundle exec yard doc && bundle exec yard server`でもいいです）。

```bash
$ bundle exec yard doc
# doc/ディレクトリ配下にHTMLドキュメントを生成
# （出力は省略）

$ bundle exec yard server
# => Webブラウザで、http://localhost:8808にアクセス
```

Webブラウザで、[http://localhost:8808](http://localhost:8808)にアクセスしてください。

### ポートを変更したい場合

ポートを指定したい場合は、`bundle exec yard server -p <port番号>`のようにしてください。

## ディレクトリ構成

```bash
$ tree -F
.
├── Gemfile
├── Gemfile.lock
├── README.md
├── (doc/) # YARDドキュメントを生成した場合に作成される
├── example.rb # 動作確認サンプルプログラム
├── lib/
│   ├── zip_generator/
│   │   ├── errors.rb     # 例外を定義
│   │   └── file_entry.rb # FileEntry Structを定義
│   └── zip_generator.rb  # ここに各メソッドを定義
└── tmp/ # example.rbが、ZIPファイルに含めるファイルや生成したZIPファイルを、ここに格納
```
