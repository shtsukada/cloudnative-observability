# 📋 共通ルール・契約一覧表（初期版）

## 1. Git 運用ルール
| 項目 | 内容 | 備考 |
|------|------|------|
| ブランチ運用 | `main`（保護）+ `feature/*` + `hotfix/*` | mainは直接push禁止、PR必須 |
| コミットメッセージ | `feat: `, `fix: `, `docs: `, `chore: `, `ci: ` | Conventional Commits形式 |
| PRテンプレート | タイトル・概要・テスト結果・動作確認手順・関連Issue | 全リポ共通 `.github/pull_request_template.md` |
| Issueテンプレート | Bug Report / Feature Request / Task | `.github/ISSUE_TEMPLATE` 配下に共通化 |
| タグ命名規則 | `v<MAJOR>.<MINOR>.<PATCH>`（例：`v1.2.3`） | `:latest` 禁止 |

---

## 2. CI/CD 共通設定
| 項目 | 内容 | 備考 |
|------|------|------|
| Lint/Format | Go → golangci-lint / Terraform → terraform fmt/validate / Helm → helm lint | `.github/workflows/lint.yml` |
| テスト | Go → `go test -v ./...` / Helm → kubeconform | |
| Build | Go/Docker → `docker buildx build --platform linux/amd64` | `CGO_ENABLED=0 GOOS=linux GOARCH=amd64` |
| Release | `release-please` による自動タグ & GitHub Release作成 | operator/app/protoに適用 |
| kindスモークテスト | mainブランチNightlyでinfra/operator/monitoring/app連携 | 軽量valuesを利用 |

---

## 3. コンテナ・Helm共通仕様
| 項目 | 内容 | 備考 |
|------|------|------|
| イメージ名 | `ghcr.io/<org>/<repo>` | docker.io利用時は`<dockerhub_user>/<repo>` |
| タグ | SemVer / 固定タグ必須 | `latest`禁止 |
| Helm Chart命名 | `<repo>-chart` | Chart.yamlの`name` |
| valuesキー共通化 | `image.repository` / `image.tag` / `resources` / `securityContext` | infra/operator/appで共通 |
| Secret名契約 | Slack通知：`slack-webhook` / OTLP endpoint：`otel-collector` | monitoring/operator共通 |

---

## 4. Observability 契約
| 項目 | 内容 | 備考 |
|------|------|------|
| メトリクス | `/metrics` path、portは `8080` | ServiceMonitorで統一 |
| ログ | zap JSON形式（UTC、trace_id含む） | Loki経由Grafana表示 |
| トレース | OTLP gRPCポート4317 / trace_id→ログ連携 | Tempo経由Grafana表示 |
| Namespace分離 | `grpc-app` / `monitoring` / `argocd` | PodSecurity(restricted)適用 |

---

## 5. Terraform / Infra 契約
| 項目 | 内容 | 備考 |
|------|------|------|
| バージョン | Terraform 1.9系 / AWS Provider ~> 5 | `.terraform-version`設定 |
| 環境分割 | dev / stg / prd のvar/overlaysで管理 | |
| Backend | S3+DynamoDB / KMS暗号化 | state直適用禁止（CI経由） |
| ArgoCD AppProject | ソースリポは固定URL（全5リポ） | main固定タグ参照 |

---

## 6. kind用軽量構成
| 項目 | 内容 | 備考 |
|------|------|------|
| monitoring values | retention短縮 / replica=1 / scrape間隔30s | |
| app/operator | 負荷低減モード有効化 | 短時間で疎通確認用 |
| ingress | kindではNodePort/port-forward利用 | |

---

## 7. ドキュメント共通仕様
| 項目 | 内容 | 備考 |
|------|------|------|
| README最小項目 | 一行ミッション / 成果物 / 契約 / Quickstart / MVP+Plus / NFR抜粋 / 受け入れ基準 / スコープ外 / CIステータス | サマリ#7準拠 |
| ライセンス | MIT（全リポ共通） | |
| 貢献ガイド | CONTRIBUTING.md にIssue/PRルール記載 | |
| 図の形式 | PNG/SVG（Mermaid可）、`docs/`配下に置く | |

---

## 8. Secrets管理ルール
| 項目 | 内容 | 備考 |
|------|------|------|
| Sealed Secrets | `sealed-secrets` namespace / RSA key管理 | |
| 命名規則 | `<app>-<purpose>`（例：`monitoring-slack-webhook`） | |
| 管理方法 | dev/stg/prdごとに暗号化 | ArgoCD経由適用 |

---

## 📌運用開始時の最初のタスク
1. GitHub上に5リポ空作成（READMEに5分割構成を明記）
2. この共通ルール表を全リポに`/docs/contracts.md`として配置
3. `.github/`以下のCI・Issue/PRテンプレを全リポに複製
4. kind用軽量valuesを`infra`と`monitoring`に追加
5. Secrets命名契約をSealed Secrets YAMLで作成
