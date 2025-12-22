# 共通ルール・契約一覧表（初期版）

## 1. Git 運用ルール
| 項目 | 内容 | 備考 |
|------|------|------|
| ブランチ運用 | `main`（保護）+ `feature/*` + `hotfix/*` | `main` 直push禁止、PR必須 |
| コミット規約 | Conventional Commits（`feat:` `fix:` `docs:` `chore:` `ci:` など） | release-please 連携 |
| PRテンプレ | タイトル/概要/動作確認/関連Issue/チェックリスト | `.github/pull_request_template.md` |
| Issueテンプレ | Bug / Feature / Task | `.github/ISSUE_TEMPLATE/` 配下 |
| タグ規約 | `v<MAJOR>.<MINOR>.<PATCH>`（例：`v1.2.3`） | **`:latest` 禁止** |

---

## 2. CI/CD 共通設定
| 項目 | 内容 | 備考 |
|------|------|------|
| Lint/Format | Go: `golangci-lint` / Terraform: `terraform fmt, validate` / Helm: `helm lint` + `kubeconform`(任意) | 子リポで実施 |
| テスト | Go: `go test -v ./...` / ルール: `promtool check rules` | monitoring で適用 |
| Build | `docker buildx build --platform linux/amd64` | 将来 arm64 追加可 |
| Release | **release-please** による自動タグ/CHANGELOG | 各リポで運用 |
| Nightly | kind で軽量スモーク（root） | `.github/workflows/nightly-kind-smoke.yml` |

---

## 3. コンテナ/Helm 共通仕様
| 項目 | 内容 | 備考 |
|------|------|------|
| イメージ名 | `ghcr.io/<org>/<repo>` | dockerhub 利用時は `<user>/<repo>` |
| タグ | **SemVer固定タグ必須** | `latest` 禁止 |
| Chart命名 | `<repo>-chart` | `Chart.yaml:name` |
| values キー | `image.repository`, `image.tag`, `resources`, `securityContext` | 共通化 |
| Secret命名 | **`<domain>-<purpose>`**（例：`monitoring-slack-webhook`、`observability-otel-endpoint`） | 以前の例示と統一 |

---

## 4. Observability 契約
| 項目 | 内容 | 備考 |
|------|------|------|
| メトリクス | path=`/metrics` / **port=`8080`（既定・valuesで上書き可）** | ServiceMonitor で収集 |
| ログ | zap JSON（UTC, `trace_id` 付与）→ Loki | Grafana で閲覧 |
| トレース | OTLP gRPC `:4317`（env: `OTEL_EXPORTER_OTLP_ENDPOINT`） | Tempo で確認 |
| Namespace | `grpc-app` / `monitoring` / `argocd` | PodSecurity: `restricted` |

---

## 5. gRPC / Proto（API 契約）
| 項目 | 内容 | 備考 |
|------|------|------|
| Go module | `github.com/shtsukada/cloudnative-observability-proto` | proto リポの module |
| 現行タグ | `v0.1.1` | app/operator は **タグ固定**（pseudo-version禁止） |
| Go import | `github.com/shtsukada/cloudnative-observability-proto/gen/go/observability/grpcburner/v1` | `option go_package` に一致させる |
| 生成 | `buf generate`（template: `proto/buf.gen.yaml`） | `gen/` は生成物、手編集禁止 |
| Lint | `buf lint` | 例外ルールは `buf.yaml` 側で管理 |
| Breaking | `buf breaking --against '.git#branch=main,subdir=proto'` | 後方互換性の担保 |

### 追従フロー（契約）
1. proto リポでタグを作成（例: `v0.1.1`）
2. app / operator で `go get ...@v0.1.1` → `go mod tidy` → PR 作成
3. ルートの `README` と `docs/contracts.md` に現行タグを反映

---

## 6. Terraform / Infra 契約
| 項目 | 内容 | 備考 |
|------|------|------|
| バージョン | Terraform **1.9** / AWS Provider `~> 5` | `.terraform-version`（任意） |
| 環境分割 | `dev` / `stg` / `prd` を var/overlays で管理 | |
| Backend | S3 + DynamoDB（Lock）+ KMS | `terraform apply` はCI経由推奨 |
| ArgoCD | **AppProject/アプリ定義は “タグ参照のみ許可”** | `main` 直参照禁止 |

---

## 7. kind 用軽量構成
| 項目 | 内容 | 備考 |
|------|------|------|
| monitoring values | retention短縮 / replica=1 / scrape間隔30s | 例: `values-kind.yaml` |
| app/operator | 負荷軽減モード | 短時間疎通用 |
| ingress | kind では NodePort / port-forward | |

---

## 8. ドキュメント共通仕様
| 項目 | 内容 | 備考 |
|------|------|------|
| README最小項目 | 一行ミッション / 成果物 / 契約 / Quickstart / MVP+Plus / 受け入れ基準 / スコープ外 | 各子リポで採用 |
| ライセンス | MIT（全リポ共通） | |
| 貢献ガイド | `CONTRIBUTING.md` に Issue/PR の流れ | |
| 図表 | PNG/SVG（Mermaid可）、`docs/` 配下 | |

---

## 9. Secrets 管理ルール
| 項目 | 内容 | 備考 |
|------|------|------|
| Sealed Secrets | `sealed-secrets` ns / RSA key管理 | |
| 命名規則 | **`<domain>-<purpose>`**（例：`monitoring-slack-webhook`） | 上記と統一 |
| 環境別管理 | `dev/stg/prd` ごとに暗号化 | ArgoCD 経由適用 |

---

## 運用開始時の最初のタスク
1. GitHub 上に 5 子リポを空で作成（README に5分割構成を明記）
2. 本ファイルを **ルートに置き、必要箇所を子リポ README へ抜粋リンク**
3. `.github/`（Issue/PRテンプレ/Workflows）を子リポへ配布
4. kind 用軽量 values を `infra`/`monitoring` に追加
5. Secrets 命名契約に従い、Sealed Secrets YAML を用意
