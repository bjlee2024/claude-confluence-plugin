# Claude Confluence Plugin

Claude Code 에서 Confluence 를 CLI 로 연동하는 플러그인입니다.

## 의존성

- [confluence-cli](https://github.com/bjlee2024/confluence-cli) (`npm install -g confluence-cli`)

## 설치

```bash
# 1. confluence-cli 설치
npm install -g confluence-cli

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
