# cloudnative-observability

このリポジトリは、**Cloud Native × Observability プロジェクトのルートリポジトリ** です。
プロジェクト前提の方針を管理し、子リポジトリへのポータルの役割を果たします。

## 全体構成
- [cloudnative-observability-infra](../cloudnative-observability-infra)
  Terraformによるインフラコード
- [cloudnative-observability-operator](../cloudnative-observability-operator)
  Kubernetes Operator(Go実装)
- [cloudnative-observability-monitoring](../cloudnative-observability-monitoring)
  Helm Charts / Prometheus / Grafana ダッシュボード
- [cloudnative-observability-app](../cloudnative-observability-app)
  gRPCベースのアプリケーション(Go)
- [cloudnative-observability-proto](../cloudnative-observability-proto)
  Bufを用いたprotobuf定義(Go module)
  - Module: `github.com/shtsukada/cloudnative-observability-proto`
  - Current tag: `v0.1.1`
  - Go import: `github.com/shtsukada/cloudnative-observability-proto/gen/go/observability/grpcburner/v1`

## このリポジトリの役割
- プロジェクト全体の共通設定を記述
  - `.github/` ワークフロー、ISSUE/Pull Requestテンプレート
  - Renovate/Dependabot設定
  - コーディング規約(`.editorconfig`,`.gitattributes`)
- 全体ドキュメント管理
  - プロジェクト概要
  - コントリビューションガイドライン
  - セキュリティポリシー

## ドキュメント
- [CONTRIBUTING.md](CONTRIBUTING.md) — コントリビューション方法
- [SECURITY.md](SECURITY.md) — セキュリティポリシー
- [docs/contracts.md](docs/contracts.md) — 子リポとの契約仕様

## リリースフロー
- [release-please](https://github.com/googleapis/release-please) により、Conventional Commits に基づきリリースを自動化
- ルートリポでは主に **ポリシー/ドキュメントの更新** をバージョン管理
