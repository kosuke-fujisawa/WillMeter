# AGENTS.md

このファイルは、このリポジトリでCodexが作業する際のガイダンスを提供します。

## 共通開発方針

プロジェクト概要、アーキテクチャ、TDD + DDDの開発手法、品質基準、開発コマンドについては、リポジトリ直下の `CLAUDE.md` を参照し、同じ方針に従ってください。

## Codex向けルール

- ユーザーへの応答、コードコメント、技術文書は日本語を優先する
- 実装前に既存テストとレイヤー構成を確認し、ドメインロジックをUI層へ置かない
- コード変更はTDDのRed-Green-Refactorサイクルで進める
- ユーザーの未コミット変更や無関係な差分を保持する
- コミット前に、変更範囲に応じてSwiftLint、Unit Test、Buildを実行する
- Codexから`xcodebuild`を実行する場合は、起動ディスクの空き容量逼迫を避けるため、すべてのコマンドに`-derivedDataPath "/Volumes/T7 Shield/DerivedData"`を指定する
- GitHub Actionsの重いBuild/Testを新設する場合は、既存ワークフローとの重複を確認する
