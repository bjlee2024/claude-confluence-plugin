---
name: confluence-init
description: Confluence CLI 초기 설정. confluence-cli 설치 확인 및 인증 설정을 진행합니다.
user-invocable: true
when_to_use: "confluence init, confluence 설정, confluence 세팅, confluence setup, 컨플루언스 설정, 컨플루언스 초기화"
---

# Confluence CLI 초기 설정

이 스킬은 `confluence-cli` 도구의 설치 및 인증 설정을 수행합니다.

## 절차

### 1단계: confluence-cli 설치 확인

```bash
which confluence 2>/dev/null || command -v confluence 2>/dev/null
```

위 명령어로 `confluence` CLI가 설치되어 있는지 확인합니다.

**미설치인 경우:**

사용자에게 다음 안내를 제공합니다:

```
confluence-cli 가 설치되어 있지 않습니다. 설치하시겠습니까?

설치 명령어:
  npm install -g @bjlee2024/confluence-cli

※ Node.js 18+ 및 npm 이 필요합니다.
```

AskUserQuestion 도구로 설치 동의를 받은 후 실행합니다:

```bash
npm install -g @bjlee2024/confluence-cli
```

### 2단계: 기존 설정 확인

```bash
confluence stats 2>&1
```

정상 응답이 오면 이미 설정이 완료된 상태입니다. 사용자에게 현재 설정 상태를 알려줍니다.

### 3단계: 인증 설정

기존 설정이 없거나 재설정이 필요한 경우, AskUserQuestion 도구로 다음 정보를 수집합니다:

1. **Confluence 도메인** (예: `company.atlassian.net`)
2. **인증 방식** (`basic` 또는 `bearer`)
3. **이메일** (basic auth 인 경우)
4. **API 토큰** (Atlassian API Token)

수집한 정보로 non-interactive init 실행:

```bash
confluence init \
  --domain "<domain>" \
  --api-path "/wiki/rest/api" \
  --auth-type "<auth-type>" \
  --email "<email>" \
  --token "<token>"
```

### 4단계: 설정 검증

```bash
confluence spaces
```

스페이스 목록이 정상적으로 반환되면 설정 완료를 알립니다.

## 환경변수 대안

CLI 설정 대신 환경변수를 사용할 수도 있음을 안내합니다:

```bash
export CONFLUENCE_DOMAIN="your-domain.atlassian.net"
export CONFLUENCE_API_TOKEN="your-api-token"
export CONFLUENCE_EMAIL="your.email@example.com"
export CONFLUENCE_API_PATH="/wiki/rest/api"
export CONFLUENCE_AUTH_TYPE="basic"
```

## 주의사항

- API 토큰은 절대 코드에 하드코딩하지 않습니다.
- `.env` 파일에 저장하는 경우 `.gitignore` 에 반드시 추가합니다.
- `confluence init` 은 `~/.confluencerc` 또는 로컬 `.confluencerc` 에 설정을 저장합니다.
