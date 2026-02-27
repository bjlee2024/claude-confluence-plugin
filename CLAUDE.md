# Claude Atlassian Plugin

Confluence CLI (`confluence-cli`) + Jira CLI (`jira-cli`) 연동 플러그인입니다.

## 사용 가능한 스킬

- `/atlassian-init` — Confluence CLI + Jira CLI 통합 설치 및 인증 설정
- `/confluence` — Confluence 페이지 읽기, 검색, 생성, 수정, 삭제
- `/jira` — Jira 이슈 조회, 생성, 수정, 삭제, 스프린트/에픽/보드 관리

## 헌법 (Constitution) - 절대 규칙

### Confluence 변경 작업 시 사용자 확인 필수

Confluence 데이터를 생성, 수정, 삭제하는 모든 명령은 **반드시 실행 전에 사용자 확인**을 받아야 합니다.

**확인이 필요한 명령어:**

| 분류 | 명령어 |
|------|--------|
| 생성 | `create`, `create-child`, `copy-tree`, `comment`, `property-set` |
| 수정 | `update`, `move`, `attachment-upload` |
| 삭제 | `delete`, `comment-delete`, `attachment-delete`, `property-delete` |

**확인 없이 실행 가능한 명령어 (읽기 전용):**

`read`, `info`, `find`, `search`, `spaces`, `children`, `comments`, `attachments`, `property-list`, `property-get`, `export`, `stats`

### Jira 변경 작업 시 사용자 확인 필수

Jira 데이터를 생성, 수정, 삭제하는 모든 명령은 **반드시 실행 전에 사용자 확인**을 받아야 합니다.

**확인이 필요한 명령어:**

| 분류 | 명령어 |
|------|--------|
| 생성 | `issue create`, `issue clone`, `epic create` |
| 수정 | `issue edit`, `issue assign`, `issue move`, `issue link` |
| 삭제 | `issue delete` |
| 댓글 | `issue comment add` |
| 스프린트/에픽 변경 | `sprint add`, `epic add` |

**확인 없이 실행 가능한 명령어 (읽기 전용):**

`issue list`, `issue view`, `sprint list`, `epic list`, `board list`, `project list`, `open`, `me`

### 확인 프로토콜

1. 실행할 정확한 명령어를 보여줍니다
2. 해당 명령이 무엇을 하는지 설명합니다
3. 영향 범위 (대상 페이지/스페이스 또는 이슈/프로젝트)를 명시합니다
4. 위험도와 되돌리기 가능 여부를 안내합니다
5. AskUserQuestion 으로 명시적 승인을 받습니다
6. 승인 후에만 명령을 실행합니다

### NEVER

- 사용자 확인 없이 생성/수정/삭제 명령 실행 금지
- 이전 승인을 근거로 새로운 변경 작업 자동 승인 금지
- `--yes` 플래그로 확인 프롬프트 우회 금지
- 여러 변경 작업을 한번의 승인으로 일괄 처리 금지
