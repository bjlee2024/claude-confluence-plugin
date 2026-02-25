---
name: confluence
description: Confluence 페이지 읽기, 검색, 생성, 수정, 삭제 등 모든 작업을 수행합니다. confluence-cli 를 사용합니다.
triggers:
  - "confluence"
  - "컨플루언스"
  - "confluence 페이지"
  - "confluence page"
  - "confluence 검색"
  - "confluence search"
  - "confluence 생성"
  - "confluence 수정"
  - "confluence 삭제"
---

# Confluence 작업 스킬

`confluence-cli` (https://github.com/pchuri/confluence-cli) 를 사용하여 Confluence 작업을 수행합니다.

---

## 헌법 (CONSTITUTION) - 절대 규칙

<constitution>
### 변경 작업 시 사용자 확인 필수

아래 명령어는 **반드시 실행 전에 AskUserQuestion 도구로 사용자 확인을 받아야 합니다.**
확인 없이 실행하는 것은 금지입니다.

#### 생성 (CREATE)
- `confluence create` — 새 페이지 생성
- `confluence create-child` — 하위 페이지 생성
- `confluence copy-tree` — 페이지 트리 복사
- `confluence comment` — 댓글 작성
- `confluence property-set` — 속성 설정

#### 수정 (UPDATE)
- `confluence update` — 페이지 수정
- `confluence move` — 페이지 이동
- `confluence attachment-upload` — 첨부파일 업로드

#### 삭제 (DELETE)
- `confluence delete` — 페이지 삭제
- `confluence comment-delete` — 댓글 삭제
- `confluence attachment-delete` — 첨부파일 삭제
- `confluence property-delete` — 속성 삭제

### 확인 프로토콜

1. 실행할 **정확한 명령어**를 보여줍니다.
2. 해당 명령이 **무엇을 하는지** 한국어로 설명합니다.
3. **영향 범위** (대상 페이지, 스페이스 등)를 명시합니다.
4. **위험도** (데이터 손실, 되돌리기 가능 여부)를 안내합니다.
5. AskUserQuestion 으로 **명시적 승인**을 받습니다.
6. 승인 후에만 명령을 실행합니다.

### 확인 메시지 형식

```
다음 Confluence 작업을 실행하려고 합니다:

  명령어: confluence <command> <args>
  동작: <설명>
  대상: <페이지 ID / 제목 / 스페이스>
  위험도: <낮음|보통|높음>
  되돌리기: <가능|불가능|부분적>

실행하시겠습니까?
```

### 읽기 전용 명령어 (확인 불필요)

다음 명령어는 데이터를 변경하지 않으므로 확인 없이 실행할 수 있습니다:

- `confluence read` — 페이지 내용 읽기
- `confluence info` — 페이지 메타데이터
- `confluence find` — 제목으로 검색
- `confluence search` — 전체 검색
- `confluence spaces` — 스페이스 목록
- `confluence children` — 하위 페이지 목록
- `confluence comments` — 댓글 목록 조회
- `confluence attachments` — 첨부파일 목록
- `confluence property-list` — 속성 목록
- `confluence property-get` — 속성 조회
- `confluence export` — 로컬 내보내기
- `confluence stats` — 통계
- `confluence edit --output` — 로컬 파일로 내보내기
</constitution>

---

## 사전 조건 확인

모든 작업 전에 `confluence-cli` 설치 여부를 확인합니다:

```bash
which confluence 2>/dev/null || command -v confluence 2>/dev/null
```

미설치인 경우 `/confluence-init` 스킬을 안내합니다.

---

## 명령어 레퍼런스

### 페이지 읽기

```bash
# 페이지 ID 로 읽기
confluence read <pageId>
confluence read <pageId> --format markdown

# URL 로 읽기
confluence read "https://domain.atlassian.net/wiki/viewpage.action?pageId=<pageId>"

# 메타데이터 조회
confluence info <pageId>
```

### 검색

```bash
# 제목으로 검색
confluence find "<title>"
confluence find "<title>" --space <SPACEKEY>

# 텍스트 검색 (키워드 기반)
confluence search "<query>"
confluence search "<query>" --limit 10

# CQL 검색 (반드시 --cql 플래그 필요)
confluence search --cql "space=<SPACEKEY>" --limit 10
confluence search --cql "space=<SPACEKEY> AND type=page" --limit 20
confluence search --cql "title=\"<exact title>\"" --limit 5
confluence search --cql "space=<SPACEKEY> AND title~\"<keyword>\"" --limit 10
confluence search --cql "label=\"<label>\" AND type=page" --limit 10

# 스페이스 목록
confluence spaces

# 하위 페이지
confluence children <pageId>
confluence children <pageId> --recursive --format tree
confluence children <pageId> --recursive --max-depth 3 --show-id --show-url
```

> **주의**: `--cql` 플래그 없이 CQL 문법을 사용하면 텍스트 검색으로 처리되어 의도한 결과가 나오지 않습니다.
> `title=`은 페이지 제목만 검색합니다. 스페이스 이름은 `space=<KEY>`로 검색하세요.

### 페이지 생성 (확인 필수)

```bash
# 새 페이지
confluence create "<title>" <SPACEKEY> --content "<content>"
confluence create "<title>" <SPACEKEY> --file ./content.md --format markdown

# 하위 페이지
confluence create-child "<title>" <parentPageId> --content "<content>"
confluence create-child "<title>" <parentPageId> --file ./content.md --format markdown

# 페이지 트리 복사
confluence copy-tree <sourcePageId> <targetParentId> "<new title>"
confluence copy-tree <sourcePageId> <targetParentId> --dry-run  # 미리보기
```

### 페이지 수정 (확인 필수)

```bash
# 제목 변경
confluence update <pageId> --title "<new title>"

# 내용 변경
confluence update <pageId> --content "<new content>"
confluence update <pageId> --file ./updated.md --format markdown

# 제목 + 내용 변경
confluence update <pageId> --title "<new title>" --content "<new content>"

# 페이지 이동
confluence move <pageId> <newParentPageId>
```

### 페이지 삭제 (확인 필수)

```bash
confluence delete <pageId>
```

### 댓글

```bash
# 댓글 목록 (확인 불필요)
confluence comments <pageId>
confluence comments <pageId> --location inline --format markdown

# 댓글 작성 (확인 필수)
confluence comment <pageId> --content "<comment>"
confluence comment <pageId> --location inline --content "<comment>" --inline-selection "<text>"

# 댓글 삭제 (확인 필수)
confluence comment-delete <commentId>
```

### 첨부파일

```bash
# 목록 조회 (확인 불필요)
confluence attachments <pageId>
confluence attachments <pageId> --pattern "*.png" --download --dest ./downloads

# 업로드 (확인 필수)
confluence attachment-upload <pageId> --file ./report.pdf
confluence attachment-upload <pageId> --file ./a.pdf --file ./b.png --comment "v2"

# 삭제 (확인 필수)
confluence attachment-delete <pageId> <attachmentId>
```

### 속성 (메타데이터)

```bash
# 조회 (확인 불필요)
confluence property-list <pageId>
confluence property-get <pageId> <key>

# 설정 (확인 필수)
confluence property-set <pageId> <key> --value '<json>'

# 삭제 (확인 필수)
confluence property-delete <pageId> <key>
```

### 내보내기

```bash
confluence export <pageId> --dest ./exports
confluence export <pageId> --format html --file content.html
```

---

## Mermaid 다이어그램 & Visualize 플러그인

Confluence에서 Mermaid 다이어그램을 렌더링하려면 **Visualize 플러그인**의 `vfcVisualizeMermaid` 매크로를 사용해야 합니다.

> **주의**: `--format markdown`으로 업로드하면 ` ```mermaid ` 코드 블록이 일반 `ac:name="code"` 매크로로 변환되어 **Mermaid가 렌더링되지 않습니다.**

### 문제: Markdown 업로드 시 Mermaid 미렌더링

confluence-cli의 `--format markdown` 변환 과정에서:
- ` ```mermaid ` 코드 블록 → `ac:name="code"` + `language=mermaid` 파라미터로 변환됨
- Confluence의 Visualize 플러그인은 `ac:name="vfcVisualizeMermaid"` 매크로만 인식함
- 결과적으로 Mermaid 코드가 일반 코드 블록으로만 표시됨

### 문제: Storage 형식의 HTML 엔티티 인코딩

Storage 형식으로 변환 시 CDATA 내부에 HTML 엔티티(`&quot;`, `&amp;`, `&lt;`, `&gt;`, `&rarr;` 등)가 남아있으면:
- Mermaid 파서가 엔티티를 인식하지 못해 다이어그램 렌더링 실패
- 코드 블록 내 JSON, 설정 등의 가독성 저하
- Visualize의 "auto resolve" 기능으로 일부 자동 수정되나, 완전하지 않음

### 올바른 Mermaid 업로드 워크플로우

Mermaid 다이어그램이 포함된 문서를 Confluence에 업로드할 때는 아래 절차를 따릅니다:

#### 1단계: Markdown으로 먼저 페이지 생성/수정

```bash
confluence create-child "<title>" <parentId> --file ./doc.md --format markdown
# 또는
confluence update <pageId> --file ./doc.md --format markdown
```

#### 2단계: Storage 형식으로 export

```bash
confluence edit <pageId> --output /tmp/page-storage.html
```

#### 3단계: Python으로 매크로 변환 + HTML 엔티티 디코딩

```python
import re

with open('/tmp/page-storage.html', 'r') as f:
    content = f.read()

def fix_mermaid_block(match):
    block = match.group(0)
    # language=mermaid인 code 블록만 변환
    if 'mermaid' not in block.lower():
        return block

    # CDATA 내 HTML 엔티티 디코딩
    def decode_cdata(m):
        cdata = m.group(1)
        cdata = cdata.replace('&quot;', '"')
        cdata = cdata.replace('&amp;', '&')
        cdata = cdata.replace('&lt;', '<')
        cdata = cdata.replace('&gt;', '>')
        cdata = cdata.replace('&rarr;', '→')
        return '<![CDATA[' + cdata + ']]>'

    # CDATA 디코딩
    block = re.sub(r'<!\[CDATA\[(.*?)\]\]>', decode_cdata, block, flags=re.DOTALL)

    # code 매크로 → vfcVisualizeMermaid 매크로 변환
    block = re.sub(
        r'ac:name="code"',
        'ac:name="vfcVisualizeMermaid"',
        block
    )
    # language 파라미터 → display-options 파라미터 변환
    block = re.sub(
        r'<ac:parameter ac:name="language">mermaid</ac:parameter>',
        '<ac:parameter ac:name="display-options">{:rf "mermaid"}</ac:parameter>',
        block
    )
    return block

# code 블록 매크로를 찾아 변환
pattern = r'<ac:structured-macro[^>]*ac:name="code"[^>]*>.*?</ac:structured-macro>'
content = re.sub(pattern, fix_mermaid_block, content, flags=re.DOTALL)

# 이미 vfcVisualizeMermaid인 블록도 CDATA 엔티티 디코딩
def fix_existing_mermaid(match):
    block = match.group(0)
    def decode_cdata(m):
        cdata = m.group(1)
        cdata = cdata.replace('&quot;', '"')
        cdata = cdata.replace('&amp;', '&')
        cdata = cdata.replace('&lt;', '<')
        cdata = cdata.replace('&gt;', '>')
        cdata = cdata.replace('&rarr;', '→')
        return '<![CDATA[' + cdata + ']]>'
    return re.sub(r'<!\[CDATA\[(.*?)\]\]>', decode_cdata, block, flags=re.DOTALL)

viz_pattern = r'<ac:structured-macro[^>]*ac:name="vfcVisualizeMermaid"[^>]*>.*?</ac:structured-macro>'
content = re.sub(viz_pattern, fix_existing_mermaid, content, flags=re.DOTALL)

# 일반 code 블록의 CDATA도 엔티티 디코딩 (JSON 코드 스니펫 등)
def fix_code_block(match):
    block = match.group(0)
    def decode_cdata(m):
        cdata = m.group(1)
        cdata = cdata.replace('&quot;', '"')
        cdata = cdata.replace('&amp;', '&')
        cdata = cdata.replace('&lt;', '<')
        cdata = cdata.replace('&gt;', '>')
        return '<![CDATA[' + cdata + ']]>'
    return re.sub(r'<!\[CDATA\[(.*?)\]\]>', decode_cdata, block, flags=re.DOTALL)

code_pattern = r'<ac:structured-macro[^>]*ac:name="code"[^>]*>.*?</ac:structured-macro>'
content = re.sub(code_pattern, fix_code_block, content, flags=re.DOTALL)

with open('/tmp/page-storage-fixed.html', 'w') as f:
    f.write(content)
```

#### 4단계: 수정된 storage 형식으로 업데이트

```bash
confluence update <pageId> --file /tmp/page-storage-fixed.html --format storage
```

### Visualize 매크로 Storage 형식 참조

```xml
<!-- 올바른 형식 (렌더링 됨) -->
<ac:structured-macro ac:name="vfcVisualizeMermaid" ac:schema-version="1">
  <ac:parameter ac:name="display-options">{:rf "mermaid"}</ac:parameter>
  <ac:plain-text-body>
    <![CDATA[graph TB
      A["노드 A"] --> B["노드 B"]
    ]]>
  </ac:plain-text-body>
</ac:structured-macro>

<!-- 잘못된 형식 (렌더링 안됨) -->
<ac:structured-macro ac:name="code" ac:schema-version="1">
  <ac:parameter ac:name="language">mermaid</ac:parameter>
  <ac:plain-text-body>
    <![CDATA[graph TB
      A[&quot;노드 A&quot;] --> B[&quot;노드 B&quot;]
    ]]>
  </ac:plain-text-body>
</ac:structured-macro>
```

### 핵심 체크리스트

- [ ] 매크로명이 `vfcVisualizeMermaid`인지 확인 (`code` ❌)
- [ ] `display-options` 파라미터에 `{:rf "mermaid"}` 설정되었는지 확인
- [ ] CDATA 내부에 `&quot;`, `&amp;`, `&lt;`, `&gt;` 등 HTML 엔티티가 없는지 확인
- [ ] 일반 `code` 블록 (JSON 등)의 CDATA도 HTML 엔티티 디코딩 확인

---

## 워크플로우 예시

### 페이지 내용 확인 후 수정

1. `confluence read <pageId> --format markdown` 로 현재 내용 확인
2. 로컬에서 내용 편집
3. 사용자 확인 후 `confluence update <pageId> --file ./edited.md --format markdown`

### 검색 후 정보 수집

1. `confluence search "<keyword>"` 로 관련 페이지 검색
2. `confluence read <pageId> --format markdown` 로 각 페이지 확인
3. 필요시 `confluence children <pageId> --recursive --format tree` 로 구조 파악

### 새 문서 작성

1. `confluence spaces` 로 대상 스페이스 확인
2. 로컬에서 마크다운 문서 작성
3. 사용자 확인 후 `confluence create "<title>" <SPACEKEY> --file ./doc.md --format markdown`

### Mermaid 다이어그램 포함 문서 업로드

1. 로컬에서 마크다운 문서 작성 (` ```mermaid ` 코드 블록 포함)
2. 사용자 확인 후 `confluence create-child` 또는 `confluence update`로 마크다운 업로드
3. `confluence edit <pageId> --output /tmp/page-storage.html` 로 storage 형식 export
4. Python 스크립트로 `code` → `vfcVisualizeMermaid` 매크로 변환 + CDATA HTML 엔티티 디코딩
5. 사용자 확인 후 `confluence update <pageId> --file /tmp/page-storage-fixed.html --format storage`
6. Confluence에서 다이어그램 렌더링 확인
