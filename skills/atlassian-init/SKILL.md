---
name: atlassian-init
description: Atlassian CLI 통합 초기 설정. confluence-cli 와 jira-cli 설치 확인 및 인증 설정을 한 번에 진행합니다.
user-invocable: true
when_to_use: "atlassian init, atlassian 설정, atlassian setup, confluence init, confluence 설정, confluence 세팅, confluence setup, 컨플루언스 설정, 컨플루언스 초기화, jira init, jira 설정, jira 세팅, jira setup, 지라 설정, 지라 초기화"
---

# Atlassian CLI 통합 초기 설정

이 스킬은 `confluence-cli` 와 `jira-cli` 의 설치 및 인증 설정을 한 번에 수행합니다.
동일한 Atlassian API 토큰으로 두 도구를 모두 설정합니다.

---

## 절차

### 1단계: CLI 도구 설치 확인

두 CLI 도구의 설치 여부를 동시에 확인합니다:

```bash
which confluence 2>/dev/null || command -v confluence 2>/dev/null
which jira 2>/dev/null || command -v jira 2>/dev/null
```

**미설치 도구가 있는 경우:**

사용자에게 미설치 도구 목록을 보여주고 설치 동의를 받습니다:

```
다음 CLI 도구가 설치되어 있지 않습니다:

[confluence-cli 미설치 시]
  confluence-cli: npm install -g @bjlee2024/confluence-cli
  ※ Node.js 18+ 및 npm 필요

[jira-cli 미설치 시]
  jira-cli (택 1):
    macOS/Linux: brew install ankitpokhrel/tap/jira-cli
    Go 사용자:   go install github.com/ankitpokhrel/jira-cli/cmd/jira@latest (Go 1.21+)

설치하시겠습니까?
```

AskUserQuestion 도구로 설치 동의를 받은 후, 미설치 도구만 설치합니다.

### 2단계: 기존 설정 확인

각 도구의 기존 설정 상태를 확인합니다:

```bash
confluence stats 2>&1
jira me 2>&1
```

- **둘 다 정상**: 이미 설정 완료. 현재 상태를 사용자에게 알려주고 종료합니다.
- **하나만 정상**: 정상인 도구는 건너뛰고, 미설정 도구만 3단계로 진행합니다.
- **둘 다 미설정**: 3단계에서 공통 인증 정보를 수집하여 함께 설정합니다.

### 3단계: 공통 인증 정보 수집

AskUserQuestion 도구로 다음 정보를 **한 번만** 수집합니다:

1. **Atlassian 도메인** (예: `company.atlassian.net`)
2. **이메일** (Atlassian 계정 이메일)
3. **API 토큰** (Atlassian API Token)
4. **인증 방식** (`basic` 또는 `bearer` — Confluence 용, 기본값 `basic`)

> **참고**: API 토큰은 https://id.atlassian.com/manage/api-tokens 에서 생성합니다.
> 하나의 토큰으로 Confluence 와 Jira 모두 사용할 수 있습니다.

### 4단계: Confluence 설정

Confluence 설정이 필요한 경우에만 실행합니다.

수집한 정보로 non-interactive init 실행:

```bash
confluence init \
  --domain "<domain>" \
  --api-path "/wiki/rest/api" \
  --auth-type "<auth-type>" \
  --email "<email>" \
  --token "<token>"
```

설정 검증:

```bash
confluence spaces
```

스페이스 목록이 정상적으로 반환되면 Confluence 설정 완료를 알립니다.

### 5단계: Jira 설정

Jira 설정이 필요한 경우에만 실행합니다.

수집한 정보로 config 파일을 자동 생성합니다:

```bash
mkdir -p ~/.config/.jira
cat > ~/.config/.jira/.config.yml << JIRA_CONFIG
installation: cloud
server: https://<domain>
login: <email>
board:
  type: ""
  name: ""
project:
  key: ""
  type: ""
epic:
  name: customfield_10011
  link: customfield_10014
JIRA_CONFIG
```

API 토큰을 현재 세션에 설정합니다:

```bash
export JIRA_API_TOKEN="<api-token>"
```

영구 설정을 위해 shell profile 추가를 안내합니다:

```
JIRA_API_TOKEN 을 shell profile 에 추가하면 매번 설정할 필요가 없습니다:

  # ~/.bashrc, ~/.zshrc, 또는 ~/.config/fish/config.fish 에 추가
  export JIRA_API_TOKEN="<api-token>"
```

설정 검증:

```bash
jira project list
```

프로젝트 목록이 정상적으로 반환되면 Jira 설정 완료를 알립니다.

### 6단계: 최종 결과 요약

설정 완료 후 결과를 요약합니다:

```
=== Atlassian CLI 설정 완료 ===

  도메인: company.atlassian.net
  이메일: user@company.com

  Confluence: ✓ 설정됨 (설정 파일: ~/.confluencerc)
  Jira:       ✓ 설정됨 (설정 파일: ~/.config/.jira/.config.yml)

  사용 가능한 스킬:
    /confluence  — Confluence 페이지 읽기, 검색, 생성, 수정, 삭제
    /jira        — Jira 이슈 조회, 생성, 수정, 삭제, 스프린트/에픽/보드 관리
```

---

## 환경변수 대안

CLI 설정 대신 환경변수를 사용할 수도 있음을 안내합니다:

```bash
# Confluence
export CONFLUENCE_DOMAIN="your-domain.atlassian.net"
export CONFLUENCE_API_TOKEN="your-api-token"
export CONFLUENCE_EMAIL="your.email@example.com"
export CONFLUENCE_API_PATH="/wiki/rest/api"
export CONFLUENCE_AUTH_TYPE="basic"

# Jira
export JIRA_API_TOKEN="your-api-token"  # 동일한 토큰 사용
```

## 설정 파일 위치

| 도구 | 설정 파일 |
|------|----------|
| Confluence | `~/.confluencerc` 또는 프로젝트 로컬 `.confluencerc` |
| Jira | `~/.config/.jira/.config.yml` |

## 주의사항

- API 토큰은 절대 코드에 하드코딩하지 않습니다.
- `.env` 파일에 저장하는 경우 `.gitignore` 에 반드시 추가합니다.
- Confluence 와 Jira 는 동일한 Atlassian API 토큰을 사용할 수 있습니다.
- `jira init` 은 interactive 모드만 지원하므로, config 파일 직접 생성 방식을 사용합니다.
