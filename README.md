# Claude Confluence Plugin

Claude Code 에서 Confluence 를 CLI 로 연동하는 플러그인입니다.

## 왜 MCP 가 아닌 CLI 을 사용해야 하는가?

[MCP 와 CLI 비교](docs/confluence-cli-vs-atlassian-mcp.md)

## 의존성

- [@bjlee2024/confluence-cli](https://github.com/bjlee2024/confluence-cli) (`npm install -g @bjlee2024/confluence-cli`)

## 설치

```bash
# 1. confluence-cli 설치
npm install -g @bjlee2024/confluence-cli

# 2. 플러그인 스킬 등록 (아래 중 택 1)

# 방법 A: 글로벌 설치 (모든 프로젝트에서 사용)
cp skills/*.md ~/.claude/skills/

# 방법 B: 프로젝트별 설치
cp skills/*.md .claude/skills/
```

## 사용법

### 초기 설정

```
/confluence-init
```

`confluence-cli` 미설치 시 자동 설치를 안내하고, `confluence init` 으로 인증 설정을 진행합니다.

### Confluence 작업

```
/confluence
```

페이지 읽기, 검색, 생성, 수정, 삭제 등 모든 Confluence 작업을 수행합니다.

## 헌법 (Constitution)

이 플러그인은 **생성/수정/삭제 작업 시 반드시 사용자 확인을 요구**합니다:

- `create`, `create-child`, `copy-tree` (생성)
- `update`, `move` (수정)
- `delete`, `comment-delete`, `attachment-delete`, `property-delete` (삭제)
- `attachment-upload` (첨부파일 업로드)

읽기 전용 명령어는 확인 없이 실행됩니다:

- `read`, `info`, `find`, `search`, `spaces`, `children`
- `comments`, `attachments`, `property-list`, `property-get`
- `export`, `stats`


## 간헐적 MCP 접속 불가 원인
 접속 경로의 차이 때문에 발생                                                                                                                                                                                                                                                             
                                                                                                                                     
  ┌───────────────────────────┬────────────────────────────┬────────┐                                                                                
  │           방식            │          접속 IP           │  결과  │            
  ├───────────────────────────┼────────────────────────────┼────────┤
  │ confluence-cli            │ 본인 PC/회사 네트워크 IP   │ 허용됨 │
  ├───────────────────────────┼────────────────────────────┼────────┤
  │ Atlassian MCP (claude.ai) │ Anthropic 클라우드 서버 IP │ 차단됨 │
  └───────────────────────────┴────────────────────────────┴────────┘

  Atlassian MCP는 Anthropic의 서버에서 Confluence API를 호출하기 때문에, 회사 Atlassian 관리자가 IP allowlist를 설정해둔 경우 차단됩니다.

  해결 방법

  1. Atlassian IP Allowlist에 Anthropic IP 추가 (권장)

  Atlassian 관리자가 다음 경로에서 설정:
  - admin.atlassian.com → 조직 선택 → Security → IP allowlisting
  - Anthropic의 MCP 서버 IP 대역을 허용 목록에 추가

  문제: Anthropic이 공식적으로 MCP 서버의 IP 대역을 공개하지 않을 수 있어, 관리자에게 확인이 필요합니다.

  2. IP Allowlist 비활성화 (조직 정책에 따라)

  보안 정책이 허용한다면 IP allowlist를 해제하거나 완화할 수 있지만, 보안팀 승인이 필요합니다.

  3. 로컬 MCP 서버 사용 (가장 현실적)

  Atlassian의 IP 제한을 변경할 수 없다면, 로컬에서 실행되는 MCP 서버를 사용하면 본인 IP로 접속하므로 차단되지 않습니다. 현재 이미 confluence-cli가 잘 동작하고 있으니, 지금처럼 CLI 기반으로 사용하는 것이 가장 현실적입니다.

  요약

  ┌─────────────────────────────────┬───────────────────────────┬──────────────┐
  │              방법               │          난이도           │  보안 영향   │
  ├─────────────────────────────────┼───────────────────────────┼──────────────┤
  │ Anthropic IP를 allowlist에 추가 │ 관리자 권한 필요          │ 외부 IP 허용 │
  ├─────────────────────────────────┼───────────────────────────┼──────────────┤
  │ IP allowlist 해제               │ 관리자 권한 + 보안팀 승인 │ 높음         │
  ├─────────────────────────────────┼───────────────────────────┼──────────────┤
  │ CLI 계속 사용 (현재 방식)       │ 없음                      │ 없음         │
  └─────────────────────────────────┴───────────────────────────┴──────────────┘

  결론적으로, 회사 Atlassian 관리자에게 IP allowlist 설정 확인 및 Anthropic IP 허용 요청을 하거나, 현재처럼 confluence-cli를 통해 사용하는 것이 가장 실용적인 방안
