# Confluence-CLI vs Atlassian MCP 비교 분석

> 테스트 일자: 2026-02-25
> 대상 환경: meditcompany.atlassian.net
> 테스트 도구: confluence-cli v1.20.1 (npm), Atlassian MCP (plugin, claude.ai)

---

## 1. 개요

Claude Code 환경에서 Confluence 데이터에 접근하는 두 가지 방법을 실측 비교합니다.

| 방법 | 설명 |
|------|------|
| **confluence-cli** | Node.js 기반 CLI 도구. Bash 를 통해 Confluence REST API 를 직접 호출 |
| **Atlassian MCP** | MCP(Model Context Protocol) 서버를 통한 Confluence API 호출. plugin 버전과 claude.ai 버전 존재 |

---

## 2. 접근성 및 인증

| 항목 | confluence-cli | Atlassian MCP (plugin) | Atlassian MCP (claude.ai) |
|------|---------------|----------------------|--------------------------|
| 인증 방식 | API Token (`~/.confluencerc`) | OAuth (plugin 인증) | OAuth (claude.ai 인증) |
| IP 제한 | 없음 (직접 API 호출) | 없음 | **차단됨** (IP 권한 오류) |
| 초기 설정 | `confluence init` 필요 | `/plugin` 명령으로 인증 | 자동 |
| 토큰 관리 | 수동 (로컬 파일) | 자동 (OAuth 갱신) | 자동 (OAuth 갱신) |

### 참고: claude.ai Atlassian MCP 제한

테스트 시 claude.ai 의 Atlassian MCP 는 다음 오류를 반환했습니다:

```
"You don't have permission to connect from this IP address.
 Please ask your organization admin for access."
```

사내 IP 제한 정책에 의해 차단되므로, 실제 사용 가능한 MCP 는 **plugin 버전**만 해당합니다.

---

## 3. 기능 범위 비교

### 3.1 읽기 (Read-Only)

| 기능 | confluence-cli | Atlassian MCP |
|------|---------------|--------------|
| 페이지 읽기 | `read`, `info` | `getConfluencePage` |
| 검색 (텍스트) | `search "<query>"` | `searchConfluenceUsingCql` |
| 검색 (CQL) | `search --cql "<cql>"` | `searchConfluenceUsingCql` |
| 스페이스 목록 | `spaces` | `getConfluenceSpaces` |
| 하위 페이지 | `children` (재귀, 트리) | `getConfluencePageDescendants` |
| 댓글 조회 | `comments` | `getFooterComments`, `getInlineComments` |
| 첨부파일 목록 | `attachments` | **미지원** |
| 속성 조회 | `property-list`, `property-get` | **미지원** |
| 내보내기 | `export` (HTML/첨부파일) | **미지원** |
| 통계 | `stats` | **미지원** |

### 3.2 쓰기 (Write)

| 기능 | confluence-cli | Atlassian MCP |
|------|---------------|--------------|
| 페이지 생성 | `create`, `create-child` | `createConfluencePage` |
| 페이지 수정 | `update` | `updateConfluencePage` |
| 페이지 삭제 | `delete` | **미지원** |
| 페이지 이동 | `move` | **미지원** |
| 페이지 트리 복사 | `copy-tree` | **미지원** |
| 댓글 작성 | `comment` | `createFooterComment`, `createInlineComment` |
| 댓글 삭제 | `comment-delete` | **미지원** |
| 첨부파일 업로드 | `attachment-upload` | **미지원** |
| 첨부파일 삭제 | `attachment-delete` | **미지원** |
| 속성 설정/삭제 | `property-set`, `property-delete` | **미지원** |

### 3.3 기능 커버리지 요약

- **confluence-cli**: 23개 명령어 (읽기 12개 + 쓰기 11개)
- **Atlassian MCP**: 9개 도구 (읽기 6개 + 쓰기 3개)
- **CLI 전용 기능**: 첨부파일, 속성, 이동, 복사, 내보내기, 삭제

---

## 4. 실측 성능 비교

동일 Confluence 인스턴스(meditcompany.atlassian.net)에 대해 동일 작업을 수행한 결과입니다.

### 4.1 스페이스 목록 조회

| 항목 | confluence-cli | Atlassian MCP (plugin) |
|------|---------------|----------------------|
| 명령 | `confluence spaces` | `getConfluenceSpaces` |
| 응답 시간 | **1.5초** | 2~3초 |
| 결과 건수 | 전체 (페이지네이션 내장) | 25건 (기본값) |
| 출력 형식 | `KEY - 이름` 텍스트 | JSON (id, key, name, type, links 등) |
| 출력 크기 | ~5KB | ~15KB |

### 4.2 검색 ("AI" 키워드)

| 항목 | confluence-cli | Atlassian MCP (plugin) |
|------|---------------|----------------------|
| 명령 | `confluence search "AI" --limit 5` | `searchConfluenceUsingCql` (CQL: `type=page AND title ~ "AI"`) |
| 응답 시간 | **0.6초** | 2~3초 |
| 결과 건수 | 5건 (limit 지정) | 25건 (기본값) |
| 출력 형식 | 제목 + 본문 미리보기 | JSON (title, summary, space, author, links 등) |
| 출력 크기 | ~2KB | ~20KB |

### 4.3 페이지 읽기 (pageId: 131154)

| 항목 | confluence-cli | Atlassian MCP (plugin) |
|------|---------------|----------------------|
| 명령 | `confluence read 131154 --format markdown` | `getConfluencePage` (markdown) |
| 응답 시간 | **0.4초** | 1~2초 |
| 출력 형식 | 깔끔한 마크다운 | JSON (body + 메타데이터) |
| 출력 크기 | ~0.5KB | ~2KB |

### 4.4 성능 요약

| 작업 | CLI 속도 | MCP 속도 | CLI 우위 |
|------|----------|----------|----------|
| 스페이스 목록 | 1.5초 | 2~3초 | ~2배 |
| 검색 | 0.6초 | 2~3초 | ~4배 |
| 페이지 읽기 | 0.4초 | 1~2초 | ~3배 |

---

## 5. 토큰 효율 비교

Claude Code 환경에서는 컨텍스트 윈도우(토큰) 사용량이 중요한 비용 요소입니다.

| 항목 | confluence-cli | Atlassian MCP |
|------|---------------|--------------|
| 출력 형식 | 간결한 텍스트/마크다운 | 구조화된 JSON |
| 메타데이터 | 최소 (필요 시 `info`로 별도 조회) | 항상 포함 (author, links, avatarUrls 등) |
| 토큰 사용량 (검색 5건) | ~500 토큰 | ~3,000 토큰 |
| 토큰 사용량 (스페이스) | ~1,000 토큰 | ~4,000 토큰 |
| 후처리 필요 | 없음 (사람/LLM 친화적) | JSON 파싱 필요 |

**결론**: 동일 정보를 얻는 데 CLI 가 MCP 대비 **3~6배 적은 토큰**을 사용합니다.

---

## 6. 장단점 비교

### 6.1 confluence-cli 장점

- 빠른 응답 속도 (직접 REST API 호출)
- 토큰 효율적인 출력 (간결한 텍스트)
- 넓은 기능 범위 (첨부파일, 속성, 이동, 복사, 내보내기)
- CQL 및 텍스트 검색 모두 지원
- `--format markdown` 으로 LLM 친화적 출력
- 재귀 하위 페이지 탐색 (`children --recursive --format tree`)

### 6.2 confluence-cli 단점

- 초기 설정 필요 (`confluence init`, API Token 발급)
- Bash 실행 환경 필요 (claude.ai 웹에서 사용 불가)
- Confluence 전용 (Jira 미지원)
- Node.js 런타임 의존

### 6.3 Atlassian MCP 장점

- OAuth 기반 자동 인증 (토큰 관리 불필요)
- Jira + Confluence 통합 (하나의 인증으로 양쪽 사용)
- 구조화된 JSON 출력 (프로그래밍적 활용)
- MCP 프로토콜 표준 (다른 MCP 도구와 통합 용이)
- 인라인 댓글 생성 지원

### 6.4 Atlassian MCP 단점

- 느린 응답 속도 (MCP 프로토콜 오버헤드)
- 높은 토큰 사용량 (JSON 메타데이터)
- 제한된 기능 범위 (9개 도구)
- 첨부파일, 속성, 삭제, 이동, 복사, 내보내기 미지원
- IP 제한 환경에서 claude.ai 버전 사용 불가

---

## 7. 권장 사용 전략

### 시나리오별 권장 도구

| 시나리오 | 권장 도구 | 이유 |
|----------|----------|------|
| 일상 Confluence 읽기/검색 | **confluence-cli** | 빠르고 토큰 효율적 |
| 페이지 생성/수정 | **confluence-cli** | 마크다운 파일 기반 워크플로우 |
| 첨부파일/속성 관리 | **confluence-cli** | MCP 미지원 |
| 페이지 트리 복사/이동 | **confluence-cli** | MCP 미지원 |
| Jira 이슈 관리 | **jira-cli** | 빠르고 JQL 지원, 로컬 실행 |
| claude.ai 웹 환경 | **Atlassian MCP** | CLI 접근 불가 (단, IP 제한 확인 필요) |
| 구조화 데이터 필요 시 | **Atlassian MCP** | JSON 출력으로 파싱 용이 |

### 하이브리드 전략

> **참고**: v2.0.0 부터 `jira-cli` 가 추가되어 Jira 작업도 CLI 로 수행 가능합니다.

두 도구를 함께 사용하면 각각의 장점을 최대화할 수 있습니다:

1. **Confluence 작업** -> `confluence-cli` (속도, 토큰 효율, 넓은 기능)
2. **Jira 작업** -> `jira-cli` (속도, JQL 지원, 로컬 실행으로 IP 제한 없음)
3. **Jira + Confluence 연계** -> `jira-cli` 로 이슈 확인 후 `confluence-cli` 로 문서 작업
4. **claude.ai 웹 환경** -> `Atlassian MCP` (CLI 접근 불가 시 대안)

---

## 8. 테스트 환경

| 항목 | 값 |
|------|-----|
| Confluence 인스턴스 | meditcompany.atlassian.net |
| Cloud ID | `3efb5595-45fd-4b1c-b846-409125d4af63` |
| confluence-cli | `@bjlee2024/confluence-cli` (npm) |
| Atlassian MCP (plugin) | `mcp__plugin_atlassian_atlassian__*` |
| Atlassian MCP (claude.ai) | `mcp__claude_ai_Atlassian__*` (IP 차단) |
| 테스트 머신 | macOS (darwin), Apple Silicon |
| Claude Code 모델 | claude-opus-4-6 |
